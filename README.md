# CloudContent Infrastructure

Infraestrutura AWS como código para uma plataforma de conteúdo e labs de aprendizado, usando Terraform na região `ap-northeast-1`.

## Estrutura

| Root module | Responsabilidade |
| --- | --- |
| `bootstrap/state` | Bucket para remote state, com versionamento, criptografia e bloqueio de acesso público |
| `bootstrap/github-oidc` | Federação OIDC e permissões IAM para GitHub Actions |
| `foundation` | Rede, computação, armazenamento e banco de dados da plataforma |
| `labs/compute-ec2-ssm` | EC2 privada administrada via Systems Manager |
| `labs/ansible-ec2-ssm/terraform` | Infraestrutura do experimento Ansible via SSM State Manager |

Cada root possui seu próprio lockfile de providers. Os labs têm states independentes. Execute os comandos Terraform no root correspondente.

## Segurança e automação

- Remote state em S3 com native lockfile.
- Autenticação do GitHub Actions via OIDC + STS, com roles distintas para plan e apply.
- Configuração de conta e bucket da CI por GitHub Variables: `AWS_ACCOUNT_ID`, `TF_STATE_BUCKET` e `TF_STATE_KEY`.
- Instâncias dos labs sem IP público, SSH, bastion ou NAT, com acesso administrativo por SSM e VPC endpoints.
- Senha administrativa do RDS gerenciada pelo serviço; autenticação IAM habilitada.
- States, caches, planos, variáveis locais e arquivos de backend excluídos do Git.

## Configuração local

Use a cadeia padrão de credenciais AWS. Quando necessário, selecione seu profile pelo ambiente com `AWS_PROFILE`; nomes pessoais de profiles não fazem parte do código.

Os backends S3 versionados definem somente região e native lockfile. Forneça bucket, key e profile por `backend.local.tfbackend`, ignorado pelo Git, mantendo os valores do ambiente existente. A opção `encrypt = true` também fica nesse arquivo e é fornecida explicitamente pela CI.

As keys ficam fora do código público. O bootstrap recebe `terraform_foundation_state_key` por `local.auto.tfvars`, ignorado pelo Git, com o mesmo valor usado no backend da foundation. Configure `TF_STATE_KEY` como GitHub Variable do repositório para os workflows de plan e apply; se houver override no environment `production`, mantenha o mesmo valor. Alterar o local da configuração não muda o destino do state.

Os nomes dos recursos existentes fazem parte da configuração funcional. Personalizações precisam ser revisadas quanto a possíveis substituições de recursos.

## Validação

Na raiz do repositório:

```sh
terraform fmt -recursive
```

Para roots já inicializados, execute, por exemplo:

```sh
terraform -chdir=foundation validate
terraform -chdir=labs/compute-ec2-ssm validate
```

A inicialização de backend é uma etapa manual e depende da configuração privada do ambiente. Antes de qualquer operação sobre infraestrutura existente, confira a conta selecionada e o destino do state. Não use migração de state como parte de uma alteração de documentação ou sanitização.
