# --- CONFIGURACIÓN DE PROVEEDOR ---
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/ aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Región por defecto de la demo
}

# Obtener ID de cuenta de AWS actual de forma dinámica
data "aws_caller_identity" "current" {}

# --- 1. TOPIC DE SNS (El Distribuidor) ---
resource "aws_sns_topic" "notificaciones_sns" {
  name = "NotificacionesS3-TF"
}

# --- 2. COLA DE SQS (El Amortiguador) ---
resource "aws_sqs_queue" "cola_procesamiento" {
  name = "ColaProcesamientoS3-TF"
}

# --- 3. SUSCRIPCIÓN DE SQS AL SNS ---
resource "aws_sns_topic_subscription" "sns_to_sqs" {
  topic_arn = aws_sns_topic.notificaciones_sns.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.cola_procesamiento.arn
}

# --- 4. POLÍTICA SQS PARA PERMITIR ENTRADA DESDE SNS ---
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

# --- 5. BUCKET DE S3 (La Ingesta de archivos) ---
resource "aws_s3_bucket" "bucket_ingesta" {
  bucket        = "formatec-ingesta-tf-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # Permite borrar el bucket con archivos adentro durante el destroy de la demo
}

# Notificación del Bucket hacia el SNS
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket     = aws_s3_bucket.bucket_ingesta.id
  depends_on = [aws_sns_topic_policy.sns_policy]

  topic {
    topic_arn     = aws_sns_topic.notificaciones_sns.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

# --- 6. POLÍTICA SNS PARA PERMITIR ENTRADA DESDE S3 ---
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

# --- 7. ROL DE IAM PARA LA LAMBDA ---
resource "aws_iam_role" "rol_lambda" {
  name = "RolEjecucionLambda-TF"

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

# Adjuntar políticas necesarias al rol de la Lambda
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.rol_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sqs_execution" {
  role       = aws_iam_role.rol_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# --- 8. ARCHIVO ZIP Y FUNCIÓN LAMBDA ---
# Generamos el payload.zip dinámicamente desde un archivo local para no requerir compresión externa
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
                print(f"🚀 [TF-PROCESADOR] ¡Nuevo archivo detectado!")
                print(f"📁 Bucket: {s3_info['bucket']['name']}")
                print(f"📄 Archivo: {s3_info['object']['key']}")
                print(f"⚖️ Tamaño: {s3_info['object']['size']} bytes")
    return {'statusCode': 200, 'body': json.dumps('Procesado')}
EOF
    filename = "index.py"
  }
}

resource "aws_lambda_function" "procesador_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "ProcesadorMensajesSQS-TF"
  role             = aws_iam_role.rol_lambda.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# --- 9. CONFIGURAR TRIGGER DE SQS EN LA LAMBDA ---
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.cola_procesamiento.arn
  function_name    = aws_lambda_function.procesador_lambda.arn
  batch_size       = 10
}

# --- OUTPUTS FINALES ---
output "s3_bucket_name" {
  value = aws_s3_bucket.bucket_ingesta.id
}