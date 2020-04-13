import boto3
import json
from os import environ


tmt_id = environ['TM_TARGET_ID']
tmf_id = environ['TM_FILTER_ID']
vpc_id = environ['VPC_ID']
gw_id = environ['GW_ID']
vni = environ['VNI']

NITRO_PREFIXES = ['a1', 'c5', 'g4', 'i3en', 'inf1', 'm5', 'p3dn.24xlarge', 'r5', 't3', 'z1d']

ec2_client = boto3.client('ec2')


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
    return ec2_client.describe_instances(InstanceIds=[instance_id])[
        'Reservations'][0]['Instances'][0][
        'NetworkInterfaces'][0]['NetworkInterfaceId']


def get_mirrorable_instance_tuples():
    mirrorable_instances_ids = [instance['InstanceId']
                                for instance in get_all_instances_in_vpc()
                                if is_mirrorable(instance['InstanceType'])
                                and instance['InstanceId'] != gw_id]
    # save instances' (instance_id, instance_eni) list of tuples
    return [(instance_id, get_eth0_eni(instance_id))
            for instance_id in mirrorable_instances_ids]


def get_tap_if_exists(instance_eni):
    tm_sessions = ec2_client.describe_traffic_mirror_sessions(
        Filters=[{'Name': 'traffic-mirror-filter-id', 'Values': [tmf_id]},
                 {'Name': 'traffic-mirror-target-id', 'Values': [tmt_id]},
                 {'Name': 'network-interface-id', 'Values': [instance_eni]}
                 ])['TrafficMirrorSessions']
    return tm_sessions[0]['TrafficMirrorSessionId'] if tm_sessions else None


def get_lambda_blacklist_tags_list():
    if 'TAP_BLACKLIST' in environ:
        lambda_tags_string = environ['TAP_BLACKLIST']
        try:
            return [{'Key': x.split('=')[0], 'Value': x.split('=')[1]}
                    for x in lambda_tags_string.split(':')]
        except IndexError:
            return []
    else:
        return []


def is_instance_blacklisted(instance_id):
    instance_tags = ec2_client.describe_instances(
        InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]['Tags']
    for tag in instance_tags:
        if tag in get_lambda_blacklist_tags_list():
            return True
    return False


def create_mirror_session(instance_id, instance_eni):
    tap_session_id = get_tap_if_exists(instance_eni)
    if tap_session_id:
        if is_instance_blacklisted(instance_id):
            print(f'Deleting TAP {tap_session_id} for blacklisted '
                  f'instance: {instance_id}')
            ec2_client.delete_traffic_mirror_session(
                TrafficMirrorSessionId=tap_session_id)
        else:
            print(f'TAP for instance {instance_id} already exists')
    else:
        if is_instance_blacklisted(instance_id):
            print(f'Skipping blacklisted instance: {instance_id}')
        else:
            tap_id = ec2_client.create_traffic_mirror_session(
                NetworkInterfaceId=instance_eni,
                TrafficMirrorTargetId=tmt_id,
                TrafficMirrorFilterId=tmf_id,
                SessionNumber=1,
                VirtualNetworkId=int(vni),
                Description=f'TAP {instance_id} vni {vni}',
                TagSpecifications=[{
                    'ResourceType': 'traffic-mirror-session',
                    'Tags': [
                        {'Key': 'Name',
                         'Value': f'tap-session-{instance_id}'}]}]
            )['TrafficMirrorSession']['TrafficMirrorSessionId']
            print(f'Created TAP {tap_id} for instance {instance_id}')


def create_mirror_sessions_for_list(instance_tuple_list):
    for instance_tuple in instance_tuple_list:
        create_mirror_session(instance_tuple[0], instance_tuple[1])


def triggered_by_deployment(event):
    return 'deployment_invocation' in event


def triggered_by_ec2_event(event):
    return event.get('detail-type') == 'EC2 Instance State-change Notification'


def triggered_by_scheduled_event(event):
    return event.get('detail-type') == 'Scheduled Event'


def scan_vpc_and_update_tap():
    print('Scanning VPC to update Traffic Access Points')
    create_mirror_sessions_for_list(get_mirrorable_instance_tuples())


def lambda_handler(event, context):
    scan = False
    if triggered_by_deployment(event):
        print('TAP Deployment trigger - Creating Traffic Access Points')
        instances_tuple = get_mirrorable_instance_tuples()
    elif triggered_by_ec2_event(event):
        scan = False
        instance_id = event['detail']['instance-id']
        instance_eni = get_eth0_eni(instance_id)
        if instance_id != gw_id:
            print(f'EC2 Running state trigger - Creating Traffic Access Point '
                  f'for instance {instance_id}')
            instances_tuple = [(instance_id, instance_eni)]
        else:
            return
    elif triggered_by_scheduled_event(event):
        print('Scheduled trigger - updating Traffic Access Points')
        instances_tuple = get_mirrorable_instance_tuples()
    else:
        return {'statusCode': 400,
                'body': json.dumps(f'Unknown event: {event}')}
    create_mirror_sessions_for_list(instances_tuple)
    if scan:
        scan_vpc_and_update_tap()
