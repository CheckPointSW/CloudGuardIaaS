import boto3
from os import environ

tmt_id = environ['TMT_ID']

ec2_client = boto3.client('ec2')

def lambda_handler(event, context):
    print('Deleting all mirror sessions associated with TAP gateway...')

    response_mirror_sessions = ec2_client.describe_traffic_mirror_sessions( Filters = [ {'Name': 'traffic-mirror-target-id', 'Values': [tmt_id]} ] )
    mirror_sessions = response_mirror_sessions['TrafficMirrorSessions']
    for session in mirror_sessions:
        tms_id = session['TrafficMirrorSessionId']
        print(f'Deleting mirror session {tms_id}...')
        ec2_client.delete_traffic_mirror_session(TrafficMirrorSessionId = tms_id)
