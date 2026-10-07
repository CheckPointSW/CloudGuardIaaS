
import json
import boto3
import os
import logging

# Set up structured logging to enable better CloudWatch Insights queries
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def _prm_tag():
    """Return the AWS Marketplace Partner Revenue Measurement (PRM) tag
    entry to attach to ENIs and EIPs we create at runtime, so their
    charges are attributed to Check Point. Read from the PRODUCT_CODE env
    var set by the CFN template (`!GetAtt AMI.Outputs.ProductCode`).

    Returns a list with one tag entry, or an empty list if PRODUCT_CODE
    isn't set — defensive against the env var being unset during local
    testing."""
    product_code = os.environ.get('PRODUCT_CODE', '').strip()
    if not product_code:
        return []
    return [{'Key': 'aws-apn-id', 'Value': f'pc:{product_code}'}]


# Optional: Add JSON formatter for structured logs
class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            'timestamp': self.formatTime(record, self.datefmt),
            'level': record.levelname,
            'message': record.getMessage(),
        }
        # Add instance_id if present in the message
        if hasattr(record, 'instance_id'):
            log_data['instance_id'] = record.instance_id
        return json.dumps(log_data)


def lambda_handler(event, context):
    """
    Lambda function to handle EC2 instance events.
    - On launch (ASG lifecycle): attach a second ENI to the instance in a public subnet
    - On terminate (EC2 state change): clean up associated Elastic IPs
    """

    # Initialize AWS clients
    ec2 = boto3.client('ec2')
    autoscaling = boto3.client('autoscaling')

    try:
        # Parse the event - handle both ASG lifecycle and EC2 state change events
        detail = event['detail']
        source = event.get('source', '')
        detail_type = event.get('detail-type', '')

        logger.info(f"Event source: {source}, detail-type: {detail_type}")

        # Check if this is an ASG lifecycle event (for launch)
        if source == 'aws.autoscaling' and 'LifecycleTransition' in detail:
            instance_id = detail['EC2InstanceId']
            lifecycle_transition = detail['LifecycleTransition']
            logger.info(f"Processing {lifecycle_transition} for instance: {instance_id}")

            if lifecycle_transition == 'autoscaling:EC2_INSTANCE_LAUNCHING':
                result = handle_instance_launch(ec2, autoscaling, detail)
            elif lifecycle_transition == 'autoscaling:EC2_INSTANCE_TERMINATING':
                result = handle_instance_termination(ec2, autoscaling, detail)
            else:
                # For any other ASG lifecycle event, just complete it
                complete_lifecycle_action(autoscaling, detail, instance_id, 'CONTINUE')
                result = {
                    'statusCode': 200,
                    'body': json.dumps({
                        'message': f'Unknown transition {lifecycle_transition}, completed with CONTINUE',
                        'instance_id': instance_id
                    })
                }
        else:
            logger.warning(f"Unknown event type: source={source}, detail-type={detail_type}")
            result = {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Unknown event type, ignoring',
                    'event': event
                })
            }

        return result

    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")

        # Try to complete lifecycle action if this was an ASG event
        try:
            detail = event['detail']
            if 'LifecycleHookName' in detail:
                autoscaling.complete_lifecycle_action(
                    LifecycleHookName=detail['LifecycleHookName'],
                    AutoScalingGroupName=detail['AutoScalingGroupName'],
                    LifecycleActionToken=detail['LifecycleActionToken'],
                    InstanceId=detail['EC2InstanceId'],
                    LifecycleActionResult='ABANDON'
                )
        except Exception as abandon_error:
            logger.error(f"Failed to abandon lifecycle action: {str(abandon_error)}")

        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'instance_id': detail.get('EC2InstanceId', detail.get('instance-id', 'unknown'))
            })
        }


def is_autoscale_gwlb_instance(ec2, instance_id):
    """
    Check if instance belongs to the autoscale_gwlb_dual_arm solution.
    Returns (is_valid, instance_data) tuple.
    """
    try:
        instance_response = ec2.describe_instances(InstanceIds=[instance_id])

        # Check if instance was found
        if not instance_response['Reservations']:
            logger.info(f"Instance {instance_id} not found (may be already deleted)")
            return False, None

        instance = instance_response['Reservations'][0]['Instances'][0]
        instance_tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}

        # Check for the x-chkp-solution tag
        solution_tag = instance_tags.get('x-chkp-solution', '')

        if solution_tag != 'autoscale_gwlb_dual_arm':
            logger.info(f"Instance {instance_id} does not have x-chkp-solution=autoscale_gwlb_dual_arm "
                        f"(found: '{solution_tag}')")
            return False, None

        logger.info(f"Instance {instance_id} confirmed as part of autoscale_gwlb_dual_arm solution")
        return True, instance

    except Exception as e:
        logger.error(f"Error checking instance tags for {instance_id}: {str(e)}")
        return False, None


def find_matching_subnet(ec2, instance_az, public_subnets, instance_id):
    """
    Find a public subnet in the same AZ as the instance.
    Returns subnet_id or raises Exception if not found.
    """
    subnets_response = ec2.describe_subnets(SubnetIds=public_subnets)

    for subnet in subnets_response['Subnets']:
        if subnet['AvailabilityZone'] == instance_az:
            subnet_id = subnet['SubnetId']
            logger.info(f"[{instance_id}] Found matching public subnet {subnet_id} in AZ {instance_az}")
            return subnet_id

    raise Exception(f"[{instance_id}] No matching public subnet found in AZ {instance_az}")


def create_and_attach_eni(ec2, instance_id, target_subnet_id, security_groups):
    """
    Create a network interface, attach it to the instance, and configure it.
    Returns eni_id.
    """
    # Create the network interface
    eni_response = ec2.create_network_interface(
        SubnetId=target_subnet_id,
        Description=f"eni created from lambda for instance: {instance_id}",
        Groups=security_groups,
        TagSpecifications=[
            {
                'ResourceType': 'network-interface',
                'Tags': [
                    {
                        'Key': 'x-chkp-anti-spoofing',
                        'Value': 'false'
                    }
                ] + _prm_tag()
            }
        ]
    )

    eni_id = eni_response['NetworkInterface']['NetworkInterfaceId']
    logger.info(f"[{instance_id}] Created ENI: {eni_id} with tag x-chkp-anti-spoofing: false")

    # Wait for ENI to be available
    ec2.get_waiter('network_interface_available').wait(NetworkInterfaceIds=[eni_id])

    # Attach the ENI to the instance
    attach_response = ec2.attach_network_interface(
        NetworkInterfaceId=eni_id,
        InstanceId=instance_id,
        DeviceIndex=1
    )

    attachment_id = attach_response['AttachmentId']
    logger.info(f"[{instance_id}] Attached ENI {eni_id} to instance {instance_id}")

    # Configure the ENI to delete on termination
    ec2.modify_network_interface_attribute(
        NetworkInterfaceId=eni_id,
        Attachment={
            'AttachmentId': attachment_id,
            'DeleteOnTermination': True
        }
    )

    return eni_id


def allocate_and_associate_eip(ec2, instance_id, eni_id, ipam_pool_id=None):
    """
    Allocate an Elastic IP and associate it with the given ENI.
    If ipam_pool_id is provided, allocate from IPAM pool, otherwise use default allocation.
    Returns allocation_id.
    """
    # Allocate Elastic IP - from IPAM pool if specified, otherwise from Amazon's pool
    allocate_params = {'Domain': 'vpc'}

    if ipam_pool_id:
        allocate_params['IpamPoolId'] = ipam_pool_id
        logger.info(f"[{instance_id}] Allocating EIP from IPAM pool: {ipam_pool_id}")
    else:
        logger.info(f"[{instance_id}] Allocating EIP from Amazon's public IPv4 pool")

    eip_response = ec2.allocate_address(**allocate_params)
    allocation_id = eip_response['AllocationId']
    logger.info(f"[{instance_id}] Allocated EIP: {allocation_id}")

    # Tag the EIP with a name and (when configured) the PRM aws-apn-id tag.
    ec2.create_tags(
        Resources=[allocation_id],
        Tags=[
            {
                'Key': 'Name',
                'Value': f'EIP-{instance_id}'
            }
        ] + _prm_tag()
    )
    logger.info(f"[{instance_id}] Tagged EIP {allocation_id} with Name: EIP-{instance_id}")

    # Associate EIP with the ENI
    ec2.associate_address(
        AllocationId=allocation_id,
        NetworkInterfaceId=eni_id
    )
    logger.info(f"[{instance_id}] Associated EIP {allocation_id} with ENI {eni_id}")

    return allocation_id


def complete_lifecycle_action(autoscaling, detail, instance_id, result='CONTINUE'):
    """
    Complete an ASG lifecycle action.
    """
    try:
        autoscaling.complete_lifecycle_action(
            LifecycleHookName=detail['LifecycleHookName'],
            AutoScalingGroupName=detail['AutoScalingGroupName'],
            LifecycleActionToken=detail['LifecycleActionToken'],
            InstanceId=instance_id,
            LifecycleActionResult=result
        )
        logger.info(f"[{instance_id}] Completed lifecycle action with result: {result}")
    except Exception as e:
        logger.error(f"[{instance_id}] Failed to complete lifecycle action: {str(e)}")
        raise


def cleanup_eip(ec2, instance_id):
    """
    Find and release EIP associated with the instance.
    """
    eip_name = f'EIP-{instance_id}'
    try:
        addresses_response = ec2.describe_addresses(
            Filters=[
                {
                    'Name': 'tag:Name',
                    'Values': [eip_name]
                }
            ]
        )

        if addresses_response['Addresses']:
            for address in addresses_response['Addresses']:
                allocation_id = address['AllocationId']
                logger.info(f"[{instance_id}] Found EIP {allocation_id} with tag Name={eip_name}")

                try:
                    # Disassociate if still associated
                    if 'AssociationId' in address:
                        association_id = address['AssociationId']
                        ec2.disassociate_address(AssociationId=association_id)
                        logger.info(f"[{instance_id}] Disassociated EIP {allocation_id}")

                    # Release the Elastic IP with retry mechanism
                    import time
                    max_retries = 10
                    retry_delay = 3

                    for attempt in range(max_retries):
                        try:
                            ec2.release_address(AllocationId=allocation_id)
                            logger.info(f"[{instance_id}] Released EIP {allocation_id}")
                            break
                        except Exception as release_error:
                            if 'InUse' in str(release_error) and attempt < max_retries - 1:
                                logger.warning(f"[{instance_id}] EIP {allocation_id} still in use, retrying "
                                               f"in {retry_delay}s (attempt {attempt + 1}/{max_retries})")
                                time.sleep(retry_delay)
                            else:
                                raise
                except Exception as eip_error:
                    logger.error(f"[{instance_id}] Failed to release EIP {allocation_id}: {str(eip_error)}")
        else:
            logger.info(f"[{instance_id}] No EIP found with tag Name={eip_name}")
    except Exception as e:
        logger.error(f"[{instance_id}] Error looking up EIP for instance {instance_id}: {str(e)}")


def handle_instance_launch(ec2, autoscaling, detail):
    """Handle instance launch lifecycle event"""
    instance_id = detail['EC2InstanceId']

    try:
        # Get instance details
        instance_response = ec2.describe_instances(InstanceIds=[instance_id])
        instance = instance_response['Reservations'][0]['Instances'][0]

        instance_az = instance['Placement']['AvailabilityZone']
        primary_subnet_id = instance['SubnetId']
        logger.info(f"[{instance_id}] Instance AZ: {instance_az}, Primary subnet: {primary_subnet_id}")

        # Get subnet lists from environment variables
        public_subnets = json.loads(os.environ['PUBLIC_SUBNETS'])

        # Get IPAM pool ID from environment variable (optional)
        ipam_pool_id = os.environ.get('IPAM_POOL_ID', '').strip()
        if ipam_pool_id:
            logger.info(f"[{instance_id}] IPAM pool configured: {ipam_pool_id}")

        # Find matching public subnet in the same AZ
        target_subnet_id = find_matching_subnet(ec2, instance_az, public_subnets, instance_id)

        # Get security groups from the primary ENI
        primary_security_groups = [sg['GroupId'] for sg in instance['NetworkInterfaces'][0]['Groups']]
        logger.info(f"[{instance_id}] Primary ENI security groups: {primary_security_groups}")

        # Create and attach the second ENI
        eni_id = create_and_attach_eni(ec2, instance_id, target_subnet_id, primary_security_groups)

        # Allocate and associate EIP with the secondary ENI (from IPAM pool if configured)
        allocate_and_associate_eip(ec2, instance_id, eni_id, ipam_pool_id if ipam_pool_id else None)

        # Get S3 version from environment variable
        s3_version = os.environ.get('S3_VERSION_ID', 'unknown')

        # Tag the instance with topology information and S3 version AFTER all configuration is complete
        ec2.create_tags(
            Resources=[instance_id],
            Tags=[
                {
                    'Key': 'x-chkp-topology',
                    'Value': 'dual'
                },
                {
                    'Key': 'x-chkp-lambda-version',
                    'Value': s3_version
                }
            ]
        )
        logger.info(f"[{instance_id}] Tagged instance {instance_id} with x-chkp-topology: dual and x-chkp-lambda-version: "
                    f"{s3_version} (configuration complete)")

        # Complete the lifecycle action successfully
        complete_lifecycle_action(autoscaling, detail, instance_id, 'CONTINUE')

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Second ENI attached successfully',
                'instance_id': instance_id,
                'eni_id': eni_id,
                'target_subnet': target_subnet_id
            })
        }

    except Exception as e:
        logger.error(f"Error processing instance launch {instance_id}: {str(e)}")

        # Complete the lifecycle action with ABANDON on error
        try:
            complete_lifecycle_action(autoscaling, detail, instance_id, 'ABANDON')
        except Exception as abandon_error:
            logger.error(f"Failed to abandon launch lifecycle action: {str(abandon_error)}")

        raise e


def handle_instance_termination(ec2, autoscaling, detail):
    """Handle instance termination - clean up EIP"""
    instance_id = detail['EC2InstanceId']

    try:
        logger.info(f"[{instance_id}] Handling termination for instance: {instance_id}")

        # Clean up the EIP
        cleanup_eip(ec2, instance_id)

        # Complete the lifecycle action successfully
        complete_lifecycle_action(autoscaling, detail, instance_id, 'CONTINUE')

        logger.info(f"[{instance_id}] Instance termination cleanup completed successfully")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Instance termination handled successfully',
                'instance_id': instance_id
            })
        }

    except Exception as e:
        logger.error(f"Error processing instance termination {instance_id}: {str(e)}")

        # Complete the lifecycle action with ABANDON on error
        try:
            complete_lifecycle_action(autoscaling, detail, instance_id, 'ABANDON')
        except Exception as abandon_error:
            logger.error(f"Failed to abandon termination lifecycle action: {str(abandon_error)}")

        raise e
