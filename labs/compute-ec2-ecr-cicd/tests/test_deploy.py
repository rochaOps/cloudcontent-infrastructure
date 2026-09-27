"""Offline tests: no subprocess or AWS calls are allowed."""
import importlib.util
import os
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "deploy", Path(__file__).parents[1] / "scripts/deploy.py"
)
deploy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(deploy)
DIGEST = "sha256:" + "a" * 64
ENV = {"IMAGE_DIGEST": DIGEST, "ASSOCIATION_ID": "test",
       "PARAMETER_NAME": "/test", "ECR_REPOSITORY": "test"}


class DeploymentTests(unittest.TestCase):
    def execute(self, status):
        def fake_aws(*args):
            if args[1] == "get-parameter":
                return {"Parameter": {"Value": DIGEST}}
            if args[1] == "describe-association-executions":
                return {"AssociationExecutions": [
                    {"ExecutionId": "old", "CreatedTime": "2000-01-01T00:00:00Z",
                     "Status": "Success"},
                    {"ExecutionId": "new", "CreatedTime": "2099-01-01T00:00:00Z",
                     "Status": status},
                ]}
            return {}
        with patch.dict(os.environ, ENV), patch.object(deploy, "aws", side_effect=fake_aws):
            with patch.object(deploy.time, "monotonic", side_effect=[0, 0, 901]):
                with patch.object(deploy.time, "sleep"):
                    deploy.main()

    def test_successful_new_execution(self):
        self.execute("Success")

    def test_failure_not_masked_by_old_success(self):
        with self.assertRaises(RuntimeError):
            self.execute("Failed")

    def test_pending_times_out(self):
        with self.assertRaises(TimeoutError):
            self.execute("Pending")

    def test_invalid_digest_never_calls_aws(self):
        with patch.dict(os.environ, {**ENV, "IMAGE_DIGEST": "latest"}):
            with patch.object(deploy, "aws") as aws:
                with self.assertRaises(ValueError):
                    deploy.main()
                aws.assert_not_called()


if __name__ == "__main__":
    unittest.main()
