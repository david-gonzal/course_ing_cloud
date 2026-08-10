output "s3_bucket_auditoria"{
    value = aws_s3_bucket.auditoria_ingesta.id
    description = "nombre del bucket"
}

output "lambda_function_arn"{
    value = aws_lambda_function.log_auditoria_processor.arn
    description = "ARN de lambda"
}

output "lambda_funtion_name"{
    value = aws_lambda_function.log_auditoria_processor.function_name
    description = "Nombre de la function"
}