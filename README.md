# CloudContent

## Estrutura

```text
CloudContent/
├── bootstrap/
│   ├── state/          # Criação do bucket de remote state; state local
│   └── github-oidc/    # OIDC e IAM para GitHub Actions; state S3
├── foundation/         # Infraestrutura principal da plataforma; state S3
└── labs/
    └── compute-ec2-ssm/ # Experimento descartável; state S3 independente
```

Cada diretório acima é um root module Terraform independente, com seu próprio
`.terraform.lock.hcl`. Não execute Terraform na raiz do repositório nem em
`bootstrap/`. Não há lab Ansible neste checkout.

## Backends preservados

| Root module | Backend | Bucket | Key | Região | use_lockfile |
| --- | --- | --- | --- | --- | --- |
| `bootstrap/state` | Local | — | `terraform.tfstate` local | provider: `ap-northeast-1` | — |
| `bootstrap/github-oidc` | S3 | `tf-state-881942917814` | `cloudcontent/bootstrap/terraform.tfstate` | `ap-northeast-1` | `true` |
| `foundation` | S3 | `tf-state-881942917814` | `cloudcontent/foundation/terraform.tfstate` | `ap-northeast-1` | `true` |
| `labs/compute-ec2-ssm` | S3 | `tf-state-881942917814` | `cloudcontent/labs/compute-ec2-ssm/terraform.tfstate` | `ap-northeast-1` | `true` |

Em foundation e GitHub OIDC, o bucket continua vazio no bloco HCL e é fornecido
por `backend.local.tfbackend` (ignorado) ou pela variável `TF_STATE_BUCKET` dos
workflows. A tabela reflete os arquivos locais e metadados de inicialização
inspecionados; não houve consulta ao state remoto. Não derive uma nova key do
nome do diretório: a key histórica de OIDC continua contendo `bootstrap`.

`bootstrap/state/terraform.tfstate` e seu backup são o state local dos recursos
que preparam o bucket. Preserve-os fora do Git e mantenha backup seguro. Os
arquivos `.terraform/terraform.tfstate` dos módulos S3 são metadados locais do
backend, não cópias do state remoto dos recursos.

## Validação local

A configuração do ambiente usa o container `terraform-lab`, com o workspace em
`/repo` e providers em `/repo/.terraform-cache`. Execute dentro desse ambiente:

```sh
cd /repo/terraform-labs/CloudContent
terraform fmt -recursive
for root in bootstrap/state bootstrap/github-oidc foundation labs/compute-ec2-ssm; do
  terraform -chdir="$root" validate
done
```

Os caches de inicialização existentes acompanharam os módulos, inclusive o cache
da foundation que ainda estava na raiz. Não foi executado `terraform init`.
Se no seu ambiente for necessário reinicializar, confirme primeiro o bucket e a
key da tabela e use os arquivos locais preservados:

```sh
terraform -chdir=foundation init -backend-config=backend.local.tfbackend
terraform -chdir=bootstrap/github-oidc init -backend-config=backend.local.tfbackend
terraform -chdir=bootstrap/state init
terraform -chdir=labs/compute-ec2-ssm init
```

Esses comandos são condicionais, não uma migração de state. Não use
`-migrate-state` por causa da reorganização. Em um clone novo, recupere o state
local de `bootstrap/state` antes de qualquer operação sobre infraestrutura e
recrie os arquivos locais de backend com os mesmos valores. Nunca aplique esse
módulo como se não existisse state anterior.

## Reorganização deste checkout

Antes:

```text
CloudContent/
├── .terraform/                    # Cache da foundation
├── bootstrap/                     # GitHub OIDC/IAM
├── state-bootstrap/               # Bucket e state local
├── environments/sandbox/foundation/
└── labs/compute-ec2-ssm/
```

Movimentos:

- `bootstrap/*` → `bootstrap/github-oidc/`, incluindo lockfile, variáveis locais,
  configuração local de backend e cache ignorado.
- `state-bootstrap/` → `bootstrap/state/`, incluindo lockfile, state local,
  backup e cache ignorado.
- `environments/sandbox/foundation/` → `foundation/`, incluindo lockfile e
  configuração local de backend.
- `.terraform/` da raiz → `foundation/.terraform/`, apenas como cache local.
- O lab compute permaneceu no mesmo caminho.

Os dois workflows agora executam seus comandos em `foundation/`; o filtro de
push do workflow de apply acompanha `foundation/**`. Roles, região, bucket
configurável e comandos de infraestrutura desses workflows foram preservados.
A ausência de `.gitignore` no workspace foi corrigida restaurando as regras
preexistentes no Git para caches, states, tfvars, planos e configurações locais.
Não havia scripts, Makefiles ou outras referências de filesystem a ajustar no
CloudContent. As keys S3 encontradas nas policies são identidades de state e
foram mantidas.

O checkout já apresentava alterações antes deste trabalho: arquivos da foundation
retirados da raiz e diretórios ainda não rastreados. Esse conteúdo foi preservado;
a reorganização não cria commit nem adiciona artifacts ao índice do Git.

Verificação: 752 arquivos preexistentes (excluindo os dois workflows alterados)
foram comparados por SHA-256 nos caminhos correspondentes, sem mudança de bytes.
Isso inclui todos os `.tf`, lockfiles, states locais, backups, configurações de
backend e arquivos regulares dos caches. Os links absolutos dos providers foram
preservados e dependem do mount `/repo` do container.

Limitação da sessão: Terraform, actionlint e shellcheck não estavam disponíveis
no host; Docker estava inacessível e sudo exigia senha. Portanto `fmt`,
`validate` e validação YAML por ferramenta não puderam ser concluídos aqui.
Execute a validação acima no container antes de usar os workflows.

Nenhum apply, destroy, import, state mv, plan, init ou acesso à AWS foi executado.
Nenhuma infraestrutura AWS e nenhum Terraform state remoto foram alterados.
