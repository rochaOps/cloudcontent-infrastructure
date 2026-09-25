module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.2.1"

  identifier = "cloudcontent-postgres"

  engine                   = "postgres"
  engine_version           = "17"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"

  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "cloudcontent"
  username = "cloudcontent_admin"
  port     = 5432

  manage_master_user_password         = true
  iam_database_authentication_enabled = true

  multi_az            = true
  publicly_accessible = false

  create_db_subnet_group = true
  subnet_ids             = local.database_subnet_ids

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  create_db_parameter_group = false

  backup_retention_period = 7
  copy_tags_to_snapshot   = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  deletion_protection = false
  skip_final_snapshot = true

  tags = merge(local.common_tags, {
    Name = "cloudcontent-postgres"
  })
}