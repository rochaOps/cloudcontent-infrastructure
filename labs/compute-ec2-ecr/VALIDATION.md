# Validação executada — 2026-09-26

O lab foi provisionado e testado na AWS em `ap-northeast-1`. Os recursos permanecem
ativos. Os identificadores de conta, bucket de backend, key, profile e IDs de
recursos foram omitidos deste registro público; consulte os outputs do Terraform
para operar o ambiente.

## Resultados

| Verificação | Resultado observado |
| --- | --- |
| Terraform fmt e validate | Aprovados; warnings de depreciação do módulo VPC upstream |
| Sintaxe Bash do bootstrap | Aprovada |
| Sintaxe Ansible | Aprovada localmente e execução real bem-sucedida na EC2 |
| Primeiro plan/apply | 30 recursos criados; sem alteração de infraestrutura dos outros labs |
| Backend | S3 inicializado com key exclusiva; arquivo local ignorado pelo Git |
| Build Docker | Imagem construída para `linux/amd64` |
| HTTP do container local | HTTP 200 e conteúdo `CloudContent Platform`; container de teste removido |
| ECR | Imagem publicada; scanning no push e lifecycle de dez imagens confirmados |
| Artefato Ansible | ZIP publicado por Terraform, criptografado com AES256 e versionado |
| Rede | EC2 sem IP público, sem ingress, sem NAT/IGW e sem rota default para internet |
| Endpoints | Quatro interfaces com private DNS e um gateway S3, todos disponíveis |
| Metadados EC2 | IMDSv2 obrigatório |
| Bootstrap | `cloud-init` concluído, marcador criado, Ansible e AWS CLI disponíveis |
| Workload | Associação SSM em `Success`; Docker ativo/habilitado; imagem pelo digest esperado |
| Porta do workload | Binding restrito a `127.0.0.1:8080` |
| HTTP na EC2 | HTTP 200 com a página esperada |
| Túnel Session Manager | HTTP 200 validado localmente por port forwarding; sessão de teste encerrada |
| Idempotência | Segunda execução `Success`, `changed=0`, `failed=0` e mesmo ID de container |
| Restart do container | Aplicação voltou a responder HTTP com retry de prontidão |
| Reboot da EC2 | Boot ID mudou; mesmo container voltou automaticamente; Docker ativo/habilitado e HTTP respondendo |
| Recuperação independente do Ansible | Nenhuma nova execução da associação foi necessária entre o teste de idempotência e a recuperação após reboot |
| Plan final | `No changes`, exit code 0 de `-detailed-exitcode` |
| Dados locais | Backend, tfvars, planos e ZIP gerado ignorados pelo Git |

O segundo deploy adicionou a associação SSM após publicar a imagem. Durante a
validação foi corrigido o formato das extra-vars: o documento AWS rejeita `:`;
o Terraform envia o hash sem o prefixo e o playbook recompõe `sha256:`. O ZIP
foi republicado automaticamente com uma nova key de conteúdo.

O teste de restart também mostrou que uma requisição imediatamente após o comando
pode receber reset de conexão enquanto Nginx inicia. O runbook usa retry limitado
com `--retry-all-errors`; o playbook já aguarda prontidão com a tarefa HTTP.

## Ferramentas e limites

Terraform 1.15.9 foi baixado para `/tmp/cloudcontent-tools/terraform`, com SHA256
conferido contra o checksum publicado pela HashiCorp. Nenhuma instalação global
foi feita. Enquanto esse diretório existir, é possível executar os comandos do
runbook com `export PATH="/tmp/cloudcontent-tools:$PATH"`; em outra sessão/máquina,
instale Terraform conforme os pré-requisitos do runbook.

A checagem local usou Ansible Core 2.19; a EC2 instalou Ansible Core 2.15.3 do
repositório do AL2023 e executou o playbook com sucesso. O plugin Session Manager
foi usado a partir de uma extração temporária em
`/tmp/cloudcontent-tools/ssm-plugin/usr/local/sessionmanagerplugin/bin`.
Para usar o túnel nessa máquina sem instalação global, adicione esse diretório
ao `PATH`; em outro ambiente, instale o plugin normalmente.

O módulo `aws-ia/vpc/aws` 4.9.0 gera avisos de atributos depreciados com o provider
AWS 6.66.0. Eles não impediram validate, plan ou apply. Os providers estão fixados
no lockfile; atualizações devem ser revisadas.

Não foram executados destroy, expiração de dez imagens, avaliação dos findings de
vulnerabilidades ou testes de carga/alta disponibilidade. A validação HTTP do
túnel foi feita com cliente HTTP, sem inspeção visual em navegador. A infraestrutura
é um lab de uma única instância e uma AZ; não demonstra disponibilidade de produção.

O passo a passo reproduzível e os resultados esperados ficam no final do
[runbook](README.md#6-validação-final--passo-a-passo).
