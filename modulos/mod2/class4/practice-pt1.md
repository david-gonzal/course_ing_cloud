
[ Cliente ] ──(Sube CSV)──> [ S3 Bucket ]
                                  │
                       (Notificación de Evento)
                                  ▼
                            [ SNS Topic ]
                                  │
                             (Pub / Sub)
                                  ▼
                            [ SQS Queue ]
                                  │
                               (Poll)
                                  ▼
                         [ Lambda Function ]


# Paso a Paso para la Configuración Manual en AWS

## Paso 1: Crear la Cola SQS (El Amortiguador)

Ve al servicio SQS (Simple Queue Service) en la consola de AWS.

Haz clic en Create queue.

Selecciona tipo Standard, nómbrala ColaProcesamientoS3 y deja el resto de valores por defecto. Haz clic en Create queue.

Copia el ARN de la cola (lo necesitarás más adelante).

## Paso 2: Crear el Topic de SNS (El Distribuidor)

Ve al servicio SNS (Simple Notification Service).

Selecciona Topics -> Create topic.

Selecciona tipo Standard, nómbralo NotificacionesS3 y haz clic en Create topic.

Suscribir la Cola SQS al SNS:

Dentro del Topic, haz clic en Create subscription.

En Protocol, selecciona Amazon SQS.

En Endpoint, pega el ARN de tu cola SQS ColaProcesamientoS3.

Haz clic en Create subscription.

Nota de seguridad: Para que SNS pueda escribir en SQS, ve a tu cola en SQS -> pestaña Access policy -> Edit, y añade permisos para que la cola acepte acciones SendMessage desde tu ARN de SNS.

## Paso 3: Crear el S3 Bucket y vincular las alertas

Ve a S3 y haz clic en Create bucket. Nómbralo con un prefijo único (ej: formatec-ingesta-datos-2026).

Ve a la pestaña Properties del Bucket.

Baja hasta la sección Event notifications -> Create event notification.

Nómbrala AlertaArchivoS3, marca la opción All object create events (peticiones PUT/POST).

En la sección de Destination, selecciona SNS Topic y elige tu topic NotificacionesS3. Haz clic en Save changes.

## Paso 4: Crear la Función Lambda y Configurar sus Permisos de IAM

Ve a Lambda -> Create function.

Nómbrala ProcesadorMensajesSQS, selecciona Python 3.11 como Runtime.

En el código de la función (lambda_function.py), pega el siguiente código de procesamiento:

import json

def lambda_handler(event, context):
    # SQS envía los mensajes agrupados en una lista llamada 'Records'
    for record in event['Records']:
        # 1. Extraer el cuerpo del mensaje (body)
        body = json.loads(record['body'])
        
        # 2. Desglosar la estructura del mensaje que vino desde SNS
        if 'Message' in body:
            sns_message = json.loads(body['Message'])
            
            # 3. Extraer la información del archivo subido a S3
            if 'Records' in sns_message:
                s3_info = sns_message['Records'][0]['s3']
                bucket_name = s3_info['bucket']['name']
                file_key = s3_info['object']['key']
                file_size = s3_info['object']['size']
                
                print(f"🚀 [PROCESADOR] ¡Nuevo archivo detectado!")
                print(f"📁 Bucket: {bucket_name}")
                print(f"📄 Archivo: {file_key}")
                print(f"⚖️ Tamaño: {file_size} bytes")
                
    return {
        'statusCode': 200,
        'body': json.dumps('Procesamiento completado con éxito')
    }


Haz clic en Deploy.


## Paso 5 Agregar el Trigger de SQS:

Regresa a la consola de tu Lambda -> pestaña Function overview -> Haz clic en Add trigger.

Selecciona SQS y busca tu cola ColaProcesamientoS3.

Deja los valores por defecto (Batch size: 10) y haz clic en Add.


## ⚠️ ¡PASO CRÍTICO DE SEGURIDAD (IAM)! > Para que el trigger de SQS funcione y la Lambda pueda consumir los mensajes, el rol de ejecución de tu Lambda (ej: ProcesadorMensajesSQS-role-xxxx) debe tener permisos explícitos sobre tu cola de SQS.

Cómo resolverlo de forma manual:

Ve a la pestaña Configuration de tu Lambda -> Permissions -> Haz clic en el nombre del rol bajo Execution role para abrirlo en la consola de IAM.

Haz clic en Add permissions -> Create inline policy (o Attach policies).

En la pestaña JSON, pega la siguiente política de acceso (SQSQueueAccessPolicy), asegurándote de reemplazar el ARN por el de tu propia cola SQS:

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
            ],
            "Resource": "arn:aws:sqs:us-east-1:609898226152:ColaProcesamientoS3"
        }
    ]
}


(Alternativamente, puedes adjuntar la política administrada oficial de AWS llamada AWSLambdaSQSQueueExecutionRole que ya contiene estos permisos de forma genérica).

