# ==========================================
# 1. SEGURIDAD Y LLAVES SSH (Generación Dinámica)
# ==========================================
resource "tls_private_key" "key_generada" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair_aws" {
  key_name   = "pem-lab-terraform"
  public_key = tls_private_key.key_generada.public_key_openssh
}

resource "local_file" "guardar_pem" {
  content         = tls_private_key.key_generada.private_key_pem
  filename        = "${path.module}/pem-lab-terraform.pem"
  file_permission = "0400"
}

# ==========================================
# 2. RED Y GRUPO DE SEGURIDAD
# ==========================================
resource "aws_security_group" "sg_clase" {
  name        = "sg_servidores_web_clase"
  description = "Permitir SSH y trafico Web para Nginx y Apache"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Nginx"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Apache"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# 3. INSTANCIAS EC2 (2 Nodos Web)
# ==========================================
resource "aws_instance" "servidor_nginx" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS us-east-1
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg_clase.id]
  key_name               = aws_key_pair.key_pair_aws.key_name

  tags = {
    Name = "Servidor-Nginx-Web"
    Role = "nginx"
  }
}

resource "aws_instance" "servidor_apache" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS us-east-1
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg_clase.id]
  key_name               = aws_key_pair.key_pair_aws.key_name

  tags = {
    Name = "Servidor-Apache-Web"
    Role = "apache"
  }
}

# ==========================================
# 4. S3 BUCKET PARA EVIDENCIAS DE AUDITORÍA
# ==========================================
resource "aws_s3_bucket" "bucket_ingesta" {
  bucket        = "formatec-auditoria-tf-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket     = aws_s3_bucket.bucket_ingesta.id
  depends_on = [aws_sns_topic_policy.sns_policy]

  topic {
    topic_arn = aws_sns_topic.notificaciones_sns.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# ==========================================
# 5. NOTIFICACIONES (SNS + SQS)
# ==========================================
resource "aws_sns_topic" "notificaciones_sns" {
  name = "NotificacionesAuditoria-TF"
}

resource "aws_sqs_queue" "cola_procesamiento" {
  name = "ColaProcesamientoAuditoria-TF"
}

resource "aws_sns_topic_subscription" "sns_to_sqs" {
  topic_arn = aws_sns_topic.notificaciones_sns.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.cola_procesamiento.arn
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.cola_procesamiento.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.cola_procesamiento.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.notificaciones_sns.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn = aws_sns_topic.notificaciones_sns.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.notificaciones_sns.arn
      }
    ]
  })
}

# ==========================================
# 6. SERVERLESS: AWS LAMBDA
# ==========================================
resource "aws_iam_role" "rol_lambda" {
  name = "RolEjecucionLambdaAuditoria-TF"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.rol_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sqs_execution" {
  role       = aws_iam_role.rol_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_payload.zip"

  source {
    content  = <<EOF
import json

def lambda_handler(event, context):
    for record in event['Records']:
        body = json.loads(record['body'])
        if 'Message' in body:
            sns_message = json.loads(body['Message'])
            if 'Records' in sns_message:
                s3_info = sns_message['Records'][0]['s3']
                print(f"🚀 [AUDITORÍA] ¡Nuevo reporte de cumplimiento recibido!")
                print(f"📁 Bucket S3: {s3_info['bucket']['name']}")
                print(f"📄 Reporte TXT: {s3_info['object']['key']}")
                print(f"⚖️ Tamaño: {s3_info['object']['size']} bytes")
    return {'statusCode': 200, 'body': json.dumps('Procesado')}
EOF
    filename = "index.py"
  }
}

resource "aws_lambda_function" "procesador_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "ProcesadorReportesAuditoria-TF"
  role             = aws_iam_role.rol_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.cola_procesamiento.arn
  function_name    = aws_lambda_function.procesador_lambda.arn
  batch_size       = 10
}