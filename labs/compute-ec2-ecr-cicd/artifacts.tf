data "archive_file" "ansible" {
  type        = "zip"
  source_file = "${path.module}/ansible/playbook.yml"
  output_path = "${path.module}/.generated/cloudcontent-ansible.zip"
}

resource "aws_s3_object" "ansible" {
  bucket = aws_s3_bucket.ansible_artifacts.id
  # A new content-addressed URL also triggers an association update.
  key          = "ansible/${data.archive_file.ansible.output_sha256}/cloudcontent-ansible.zip"
  source       = data.archive_file.ansible.output_path
  source_hash  = data.archive_file.ansible.output_base64sha256
  content_type = "application/zip"

  depends_on = [
    aws_s3_bucket_versioning.ansible_artifacts,
    aws_s3_bucket_server_side_encryption_configuration.ansible_artifacts,
    aws_s3_bucket_public_access_block.ansible_artifacts,
  ]
}
