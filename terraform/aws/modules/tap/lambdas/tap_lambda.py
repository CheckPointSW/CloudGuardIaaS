import boto3
import json
from os import environ

vpc_id = environ['VPC_ID']
az = environ['AZ']
tmt_id = environ['TMT_ID']
tmf_id = environ['TMF_ID']
vni = environ['VNI']
all_eni = environ['ALL_ENI']
tap_blacklist = environ['TAP_BLACKLIST']
tap_whitelist = environ['TAP_WHITELIST']
use_whitelist = environ['USE_WHITELIST']

NITRO_PREFIXES = ['a1', 'c5', 'g4', 'i3en', 'inf1', 'm5', 'p3dn.24xlarge', 'r5', 't3', 'z1d']

ec2_client = boto3.client('ec2')


def get_instance(instance_id):
    return ec2_client.describe_instances(InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]

def is_sensor(instance):
    try:
        instance_tags = instance['Tags']
    except KeyError as e:
        return False
    for tag in instance_tags:
        if tag['Key'] == "CKP_Type" and tag['Value'] == "Sensor":
            return True
    return False

def is_listed_nomirror(instance):
    try:
        instance_tags = instance['Tags']
    except KeyError as e:
        return (use_whitelist == "yes")
    for tag in instance_tags:
        if(use_whitelist == "no"):
            for pair in tap_blacklist.split(':'):
                btag = {'Key': x.split('=')[0], 'Value': x.split('=')[1]}
                if tag == btag:
                    return True
        else:
            for pair in tap_whitelist.split(':'):
                wtag = {'Key': x.split('=')[0], 'Value': x.split('=')[1]}
                if tag == wtag:
                    return False
    return (use_whitelist == "yes")

def is_mirrorable(instance):
    instance_id = instance['InstanceId']
    instance_type = instance['InstanceType']
    instance_az = instance['Placement']['AvailabilityZone']
    if az != "none" and instance_az != az:
        print(f'Instance {instance_id} is from AZ {instance_az} therefore not mirrorable by this TAP.')
        return False
    if is_sensor(instance):
        print(f'Instance {instance_id} is a TAP Sensor.')
        return False
    if is_listed_nomirror(instance):
        print(f'Instance {instance_id} is not listed to be mirrored.')
        return False
    for prefix in NITRO_PREFIXES:
        if instance_type.startswith(prefix):
            return True
    print(f'Instance {instance_id} is of type {instance_type} therefore not mirrorable.')
    return False

def get_instance_tuples(instance):
    instance_tuples = []
    for eni in instance['NetworkInterfaces']:
        instance_tuples.append((instance['InstanceId'], eni['NetworkInterfaceId']))
    return instance_tuples

def get_mirrorable_instance_tuples():
    if az != "none":
        response_instances_in_vpc = ec2_client.describe_instances(Filters = [{'Name': 'vpc-id', 'Values': [vpc_id]}, {'Name': 'availability-zone', 'Values': [az]}])
    else:
        response_instances_in_vpc = ec2_client.describe_instances(Filters = [{'Name': 'vpc-id', 'Values': [vpc_id]}])

    all_instances_in_vpc = []
    for entry in response_instances_in_vpc['Reservations']:
        all_instances_in_vpc.extend(entry['Instances'])

    mirrorable_instance_tuples = []
    for instance in all_instances_in_vpc:
        if is_mirrorable(instance):
            instance_tuples = get_instance_tuples(instance)
            if all_eni == "no":
                instance_tuples = [instance_tuples[0]]
            mirrorable_instance_tuples.extend(instance_tuples)

    return mirrorable_instance_tuples

def create_mirror_sessions(instance_tuples):
    for instance_tuple in instance_tuples:
        instance_id = instance_tuple[0]
        instance_eni = instance_tuple[1]

        tm_sessions = ec2_client.describe_traffic_mirror_sessions(
        Filters = [ {'Name': 'traffic-mirror-filter-id', 'Values': [tmf_id]},
                    {'Name': 'traffic-mirror-target-id', 'Values': [tmt_id]},
                    {'Name': 'network-interface-id', 'Values': [instance_eni]} ])
    
        if not tm_sessions['TrafficMirrorSessions']:
            print(f'Creating TAP for instance {instance_id} ENI {instance_eni}...')
            tap = ec2_client.create_traffic_mirror_session(
                NetworkInterfaceId = instance_eni,
                TrafficMirrorTargetId = tmt_id,
                TrafficMirrorFilterId = tmf_id,
                SessionNumber = 1,
                VirtualNetworkId = int(vni),
                Description = f'TAP {instance_id} VNI {vni}',
                TagSpecifications = [{
                    'ResourceType': 'traffic-mirror-session',
                    'Tags': [ {'Key': 'Name', 'Value': f'tap-session-{instance_id}'} ] 
                }]
            )
            tap_id = tap['TrafficMirrorSession']['TrafficMirrorSessionId']
            if not tap_id:
                print(f'Failed to create TAP for instance {instance_id}: {json.dumps(tap)}')
            else:
                print(f'Created TAP {tap_id} for instance {instance_id}')
        else:
            instance = get_instance(instance_id)
            if is_listed_nomirror(instance):
                tap_session_id = tm_sessions[0]['TrafficMirrorSessionId']
                print(f'Deleting TAP {tap_session_id} for non listed to minitor instance: {instance_id}')
                ec2_client.delete_traffic_mirror_session(TrafficMirrorSessionId=tap_session_id)
            else:
                print(f'Instance {instance_id} already TAPed.')


def lambda_handler(event, context):
    if event.get('detail-type') == 'TAP Deployment':
        print('TAP deployment trigger - Creating Traffic Access Points')
        instance_tuples = get_mirrorable_instance_tuples()
    elif event.get('detail-type') == 'EC2 Instance State-change Notification':
        instance_id = event['detail']['instance-id']
        print(f'TAP EC2 trigger for instance {instance_id}')
        instance = get_instance(instance_id)
        if is_mirrorable(instance):            
            instance_tuples = get_instance_tuples(instance)
        else:
            return
    elif event.get('detail-type') == 'Scheduled Event':
        print('TAP scheduled trigger - Updating Traffic Access Points')
        instance_tuples = get_mirrorable_instance_tuples()
    else:
        return {'statusCode': 400, 'body': json.dumps(f'Unknown event: {event}')}

    create_mirror_sessions(instance_tuples)
