"""Run only after approval, with temporary AWS credentials. Uses AWS CLI v2."""
import json
import os
import re
import subprocess
import time
from datetime import datetime, timezone


def aws(*args):
    result = subprocess.run(
        ["aws", *args, "--output", "json", "--no-cli-pager"],
        check=True, capture_output=True, text=True,
    )
    return json.loads(result.stdout or "{}")


def main():
    digest = os.environ["IMAGE_DIGEST"]
    if not re.fullmatch(r"sha256:[a-f0-9]{64}", digest):
        raise ValueError("Invalid digest")
    association = os.environ["ASSOCIATION_ID"]
    parameter = os.environ["PARAMETER_NAME"]
    aws("ecr", "describe-images", "--repository-name", os.environ["ECR_REPOSITORY"],
        "--image-ids", "imageDigest=" + digest)
    previous = aws("ssm", "get-parameter", "--name", parameter)["Parameter"]["Value"]
    print("Previous digest:", previous, "Desired digest:", digest, flush=True)
    # The writer is serialized by workflow concurrency. Do not deploy manually concurrently.
    aws("ssm", "put-parameter", "--name", parameter, "--type", "String",
        "--value", digest, "--overwrite")
    started = datetime.now(timezone.utc)
    aws("ssm", "start-associations-once", "--association-ids", association)
    deadline = time.monotonic() + 900
    execution_id = None
    while time.monotonic() < deadline:
        executions = aws("ssm", "describe-association-executions",
                         "--association-id", association).get("AssociationExecutions", [])
        for execution in sorted(executions, key=lambda x: x["CreatedTime"]):
            created = datetime.fromisoformat(execution["CreatedTime"].replace("Z", "+00:00"))
            if execution_id is None and created >= started:
                execution_id = execution["ExecutionId"]
            if execution["ExecutionId"] != execution_id:
                continue
            status = execution["Status"]
            print("Execution:", execution_id, "Status:", status, flush=True)
            if status == "Success":
                current = aws("ssm", "get-parameter", "--name", parameter)["Parameter"]["Value"]
                if current != digest:
                    raise RuntimeError("Desired digest changed during deployment")
                return
            if status in {"Failed", "TimedOut", "Cancelled"}:
                raise RuntimeError(f"Deployment failed: {execution}")
        time.sleep(15)
    raise TimeoutError("No successful new association execution within 15 minutes")


if __name__ == "__main__":
    main()
