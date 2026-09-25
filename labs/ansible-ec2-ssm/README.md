# Lab Ansible via SSM

O experimento demonstra o fluxo S3 artifact → SSM State Manager → `AWS-ApplyAnsiblePlaybooks` → Ansible executado na EC2 privada.

O root independente em `terraform/` possui lockfile próprio e tag `Lab = "ansible-ec2-ssm"`. A rede usa endpoints SSM e S3, sem IP público, SSH, bastion ou NAT.

O backend S3 é parcial e o state é independente dos demais labs. Forneça bucket, key e profile por `backend.local.tfbackend`, ignorado pelo Git, preservando os valores do ambiente existente. As credenciais vêm da configuração AWS local ou do ambiente.

A associação permanece desabilitada com `count = 0` até que o artifact esteja disponível. A pasta `ansible/` está reservada para o playbook; antes de habilitar a associação, prepare o ZIP e valide as dependências no managed node sem NAT.
