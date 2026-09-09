import boto3

def eliminar_instancias_sin_tags():
    ec2 = boto3.client('ec2', region_name='us-east-1')

    print("Buscando e identificando instancias EC2 sin etiquetas para su eliminación...")

    # 1. Obtener instancias activas o detenidas
    response = ec2.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running', 'stopped']}]
    )

    to_delete = []

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            # Extraer las llaves de las etiquetas
            tags = {t['Key']: t['Value'] for t in instance.get('Tags', [])}
            
            # Si NO tiene la etiqueta 'CentroDeCostos' (creadas en Acto 1), se marca para eliminar
            if 'CentroDeCostos' not in tags:
                to_delete.append(instance['InstanceId'])

    if not to_delete:
        print("⚠️ No se encontraron instancias sin etiquetas para eliminar.")
        return

    print(f"Recursos encontrados para terminar: {to_delete}")

    # 2. Terminar instancias
    ec2.terminate_instances(InstanceIds=to_delete)
    print("⏳ Solicitud de terminación enviada. Esperando eliminación...")

    # 3. Esperar hasta que se completen las terminaciones
    waiter = ec2.get_waiter('instance_terminated')
    waiter.wait(InstanceIds=to_delete)

    print("🟢 Infraestructura del Acto 1 eliminada exitosamente. La cuenta quedó limpia.")

if __name__ == "__main__":
    eliminar_instancias_sin_tags()