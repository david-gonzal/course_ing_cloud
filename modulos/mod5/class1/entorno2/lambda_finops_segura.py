import boto3

def lambda_handler():
    ec2 = boto3.client('ec2', region_name='us-east-1')
    
    # 1. Filtrar instancias que estén 'running'
    response = ec2.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
    )
    
    to_stop = []
    
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            tags = {t['Key']: t['Value'] for t in instance.get('Tags', [])}
            
            # LÓGICA FINOPS SEGURA:
            # Solo apaga si tiene explícitamente Entorno=Desarrollo Y HorarioOperativo=Lunes-Viernes
            entorno = tags.get('Entorno')
            horario = tags.get('HorarioOperativo')
            
            if entorno == 'Desarrollo' and horario == 'Lunes-Viernes':
                to_stop.append(instance['InstanceId'])
            elif not tags:
                print(f"⚠️ Alerta de Gobernanza: Instancia {instance['InstanceId']} no tiene tags. Se reporta pero NO se apaga a ciegas.")

    if to_stop:
        print(f"🟢 OTTIMIZACIÓN FINOPS: Apagando entornos no productivos de fin de semana: {to_stop}")
        ec2.stop_instances(InstanceIds=to_stop)
    else:
        print("No hay recursos elegibles para apagado en este momento.")

if __name__ == "__main__":
    lambda_handler()