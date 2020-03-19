import json
from os import environ

import boto3

tmt_id = environ['TM_TARGET_ID']
tmf_id = environ['TM_FILTER_ID']
vpc_id = environ['VPC_ID']
gw_id = environ['GW_ID']
vni = environ['VNI']

NITRO_PREFIXES = ['a1', 'c5', 'i3en', 'm5', 'p3dn.24xlarge', 'r5', 't3', 'z1d']

ec2_client = boto3.client('ec2')
lambda_client = boto3.client('lambda')


# ------ Get Mirrorable instances ------

def is_mirrorable(instance_type):
    for prefix in NITRO_PREFIXES:
        if instance_type.startswith(prefix):
            return True
    return False


def get_all_instances_in_vpc():
    response_instances_in_vpc = ec2_client.describe_instances(
        Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])
    all_instances_in_vpc = []
    for entry in response_instances_in_vpc['Reservations']:
        all_instances_in_vpc.extend(entry['Instances'])
    return all_instances_in_vpc


def get_eth0_eni(instance_id):
    response_instance = ec2_client.describe_instances(
        InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]
    if response_instance['VpcId'] == vpc_id:
        return response_instance['NetworkInterfaces'][0]['NetworkInterfaceId']
    else:
        return None


def get_mirrorable_instance_tuples():
    mirrorable_instances = [instance for instance in get_all_instances_in_vpc()
                            if is_mirrorable(instance['InstanceType'])]
    for instance in mirrorable_instances:
        if instance['InstanceId'] == gw_id:
            mirrorable_instances.remove(instance)
    # save instances (instanceId, eni) list of tuples
    return [(instance['InstanceId'], get_eth0_eni(instance['InstanceId']))
            for instance in mirrorable_instances]


# ------ Create Traffic access points ------

def get_tap_if_exists(instance_eni):
    traffic_mirror_sessions = ec2_client.describe_traffic_mirror_sessions(
        Filters=[{'Name': 'traffic-mirror-filter-id', 'Values': [tmf_id]},
                 {'Name': 'traffic-mirror-target-id', 'Values': [tmt_id]},
                 {'Name': 'network-interface-id', 'Values': [instance_eni]}])['TrafficMirrorSessions']
    if not traffic_mirror_sessions:
        return ""
    else:
        return traffic_mirror_sessions[0]['TrafficMirrorSessionId']


def get_lambda_blacklist_tags_list():
    if 'TAP_BLACKLIST' in environ:
        lambda_tags_string = environ['TAP_BLACKLIST']
        try:
            tags_list = [{'Key': x.split('=')[0], 'Value': x.split('=')[1]} for x in lambda_tags_string.split(':')]
            return tags_list
        except IndexError:
            return []
    else:
        return []


def is_instance_blacklisted(instance_id):
    blacklist_tags_list = get_lambda_blacklist_tags_list()
    instance_tags = ec2_client.describe_instances(
        InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]['Tags']
    print(f'instance tags = {instance_tags}')
    print(f'lambda blacklist-tags list = {blacklist_tags_list}')
    for tag in instance_tags:
        if tag in blacklist_tags_list:
            return True
    return False


def create_mirror_session(instance_id, instance_eni):
    tap_id = get_tap_if_exists(instance_eni)
    if tap_id:
        if is_instance_blacklisted(instance_id):
            ec2_client.delete_traffic_mirror_session(TrafficMirrorSessionId=tap_id)
        else:
            print(f'TAP for instance {instance_id} exists.')
    else:
        if is_instance_blacklisted(instance_id):
            print(f'Skipping TAP creation for blacklisted instance: {instance_id}')
        else:
            print(f'Creating mirror session for instance {instance_id}')
            ec2_client.create_traffic_mirror_session(
                NetworkInterfaceId=instance_eni,
                TrafficMirrorTargetId=tmt_id,
                TrafficMirrorFilterId=tmf_id,
                SessionNumber=1,
                VirtualNetworkId=int(vni),
                Description=f'TAP {instance_id} vni {vni}',
                TagSpecifications=[{
                    'ResourceType': 'traffic-mirror-session',
                    'Tags': [
                        {'Key': 'Name', 'Value': f'tap-session-{instance_id}'}]}]
            )


def create_mirror_sessions_for_list(instance_tuple_list):
    for instance_tuple in instance_tuple_list:
        instance_id = instance_tuple[0]
        instance_eni = instance_tuple[1]
        create_mirror_session(instance_id, instance_eni)


def triggered_by_deployment(event):
    return 'deployment_invocation' in event


def triggered_by_ec2_event(event):
    if 'detail-type' in event:
        return event['detail-type'] == 'EC2 Instance State-change Notification'
    else:
        return False


def triggered_by_scheduled_event(event):
    if 'detail-type' in event:
        return event['detail-type'] == 'Scheduled Event'
    else:
        return False


def scan_all_instances_in_vpc_for_tap_state():
    """
    this function scans all instances in the VPC and checks whether all
    instances' TAP state is correct
    """
    print('Scanning VPC to validate traffic access points\' status for all relevant instances')
    create_mirror_sessions_for_list(get_mirrorable_instance_tuples())


def lambda_handler(event, context):
    if triggered_by_deployment(event):
        print('TAP deployment - Creating traffic access points')
        instance_tuple_list = get_mirrorable_instance_tuples()
        create_mirror_sessions_for_list(instance_tuple_list)
    elif triggered_by_ec2_event(event):
        instance_id = event['detail']['instance-id']
        instance_eni = get_eth0_eni(instance_id)
        print(f'EC2 Running state trigger - Creating traffic access point for instance {instance_id}')
        if instance_id != gw_id and instance_eni is not None:
            instance_tuple_list = [(instance_id, instance_eni)]
            create_mirror_sessions_for_list(instance_tuple_list)
        else:
            return
    elif triggered_by_scheduled_event(event):
        print('Schedule trigger - Scanning TAP status')
    else:
        return {'statusCode': 400,
                'body': json.dumps(f'Unknown event: {event}')}
    scan_all_instances_in_vpc_for_tap_state()
