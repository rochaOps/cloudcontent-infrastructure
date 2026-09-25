## Validação do lab `compute-ec2-ssm`

Objetivo validado:

* EC2 privada sem public IPv4
* sem SSH
* sem bastion
* sem NAT Gateway
* acesso administrativo via AWS Systems Manager Session Manager
* `amazon-ssm-agent` ativo
* `ssm.ap-northeast-1.amazonaws.com` resolvendo para IP privado
* `ssmmessages.ap-northeast-1.amazonaws.com` resolvendo para IP privado
* acesso comum à Internet indisponível
* sessão SSM aberta com sucesso via AWS CLI

Conclusão:

O lab comprovou que uma instância Amazon Linux 2023 em subnet privada pode ser administrada exclusivamente via Systems Manager usando Interface VPC Endpoints e Private DNS, sem depender de acesso público ou NAT.
