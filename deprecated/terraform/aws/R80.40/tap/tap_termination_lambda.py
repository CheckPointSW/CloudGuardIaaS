import boto3
from os import environ

tmt_id = environ['TM_TARGET_ID']
tmf_id = environ['TM_FILTER_ID']

ec2_client = boto3.client('ec2')


def get_mirror_session_ids():
    response_mirror_sessions = ec2_client.describe_traffic_mirror_sessions(
        Filters=[{'Name': 'traffic-mirror-target-id', 'Values': [tmt_id]}])
    return [session['TrafficMirrorSessionId'] for session in
            response_mirror_sessions['TrafficMirrorSessions']]


def delete_mirror_session(mirror_session_id):
    print(f'Deleting mirror session {mirror_session_id}')
    ec2_client.delete_traffic_mirror_session(
        TrafficMirrorSessionId=mirror_session_id)


def lambda_handler(event, context):
    print('Deleting all mirror sessions associated with TAP gateway')
    for session in get_mirror_session_ids():
        delete_mirror_session(session)
