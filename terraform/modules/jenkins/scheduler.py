import boto3
from datetime import datetime

SSM_INSTANCE_PARAMETER = "/project/jenkins/instance"

BOTO3_EC2 = boto3.resource('ec2')
BOTO3_SSM = boto3.client('ssm')

INSTANCE_ID = BOTO3_SSM.get_parameter(Name=SSM_INSTANCE_PARAMETER)['Parameter']['Value']

def lambda_handler(event, context):
    if datetime.now().hour < 12:
        # If AM, start instance
        BOTO3_EC2.instances.filter(InstanceIds=[INSTANCE_ID]).start()
    else:
        # If PM, stop instance
        BOTO3_EC2.instances.filter(InstanceIds=[INSTANCE_ID]).stop()
