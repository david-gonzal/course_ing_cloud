# Laboratorio: Crear infraestrucutra en 2 capas (publico - privado)

## Pasos previos:
    1. Crear "Access key" para un usuario dentro de la consola web 
    2. Instalar "AWS CLI" o de lo contrario usar AWS Cloudshell

## Paso a paso
    1. Ejecutar el login a la API de AWS
        1.a. aws configure -> copiar y pegar los datos de access key - elegir la region - foramto de salida: json
    2. Ejecutar:
        2.a. aws cloudformation validate-template --template-body file://infra.yaml
        2.b. aws cloudformation create-stack --stack-name Lab-FormaTEC-Infra --template-body file://infra.yaml --capabilities CAPABILITY_IAM
        2.c. aws cloudformation describe-stacks --stack-name Lab-FormaTEC-Infra
    3. Validar los comandos ejecutados:
        3.a. Ingreasar a la consola de AWS en la seccion "CloudFormation -> Stacks -> Lab-FormaTEC-Infra" aqui veremos el "Status" de la creacion y sus eventos
        3.b. Para mas detalles ingresar a "CloudTrail -> Event history" y aqui veremos que fue lo ultimo que se le solicito a la API de AWS
        3.c. Tras unos 10 minutos aproximadamente deberiamos ver el "Status" del stack en "CREATE_COMPLETE"
    4. Ingresar a la seccion "EC2 -> Intances -> seleccionar la instancia -> Connect -> seleccionar SSM Session Manager -> se abrira en otra pestaña una consola de linux"
        4.a. Para ejecutar la prueba de conexion a la RDS se debe instalar un cliente de MySQL -> "sudo dnf install mariadb105 -y"
        4.b. Se debe de contar con el archivo .pem de la RDS "curl https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem"
        4.c.mysql -h lab-formatec-infra-mydb...rds.amazonaws.com -P 3306 -u admin -p --ssl-ca=global-bundle.pem --ssl-verify-server-cert (copiar el nombre de la RDS)
        4.d. Se deberia ver el promtp de "MySQL>"

        *Los comandos 4.b y 4.c los encontramos en la seccion "Aurora and RDS -> Databases -> entrando a nuestra RDS"
    5. Validar que no se puede acceder desde nuesta maquina local; repetir los pasos del 4.a al 4.d y nos deberia dar "time out" ya que no esta publica la RDS.