#!/bin/bash
set -euo pipefail

# AL2023 regional repositories are reachable through the S3 gateway endpoint.
# Install only the prerequisites for AWS-ApplyAnsiblePlaybooks here.
for attempt in $(seq 1 12); do
  if dnf install -y ansible-core unzip awscli-2; then
    break
  fi
  if [ "$attempt" -eq 12 ]; then
    echo "Failed to install Ansible prerequisites" >&2
    exit 1
  fi
  sleep 10
done

ansible-playbook --version
aws --version
unzip -v >/dev/null
systemctl enable --now amazon-ssm-agent
install -d -m 0755 /opt/cloudcontent
touch /opt/cloudcontent/bootstrap-ready
