data "aws_caller_identity" "current" {}

#1. Bucket s3
resource "aws_s3_bucket" "auditoria_ingesta"{
    bucket = "auditoria-${data.aws_caller_identity.current.account_id}"
    force_destroy = true
}

#2. Rol IAM
resource "aws_iam_role" "lambda_auditoria_role"{
    name = "role_procesador_auditoria_lambda"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = { Service = "lambda.amazonaws.com"}
        }]
    })
}

#Permisos de logs CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs_policy"{
    role = aws_iam_role.lambda_auditoria_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#Empaquetado automatico de python
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/analizador_registros.zip"

  source {
    content  = <<EOF
import json
import os

def handler(event, context):
    target_bucket = os.environ.get('AUDIT_BUCKET_TARGET')
    env = os.environ.get('ENVIRONMENT')
    
    print(f"🔍 [EVALUACIÓN] Procesando registros de auditoría en el bucket: {target_bucket}")
    print(f"🛠️ Entorno de ejecución: {env}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'status': 'SUCCESS',
            'message': 'Registro de transacciones validado e indexado correctamente',
            'bucket_asociado': target_bucket
        })
    }
EOF
    filename = "app.py"
  }
}

#3 Funtion lambda
resource "aws_lambda_function" "log_auditoria_processor"{
    function_name = "analizador_registros_transacciones"
    role = aws_iam_role.lambda_auditoria_role.arn
    handler = "app.handler"
    filename = data.archive_file.lambda_zip.output_path
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    runtime = "python3.11"

    environment{
        variables = {
            AUDI_BUCKET_TARGET = aws_s3_bucket.auditoria_ingesta.id
            ENVIRONMENT = "evaluacion-dev"
        }
    }
}