import boto3
import os
import json

LTName = os.environ['TemplateName']
client = boto3.client('ec2')


def lambda_handler(event, context):
    if "sqs1" in event["Records"][0]["eventSource"]:
        instnceId = event["Records"][0]["body"]["instnceId"]
        create_ami(instnceId)
    else:
        IsLtExist = client.describe_launch_templates(LaunchTemplateNames=[LTName])
        if IsLtExist is not None:
            LtVersionData = client.describe_launch_template_versions(
                LaunchTemplateName=LTName)
            LtVersionData = LtVersionData["LaunchTemplateVersions"]
            seq = [x['VersionNumber'] for x in LtVersionData]
            LtVersionData = client.describe_launch_template_versions(
                LaunchTemplateName=LTName, Versions=[str(max(seq))])
            oldimageid = LtVersionData["LaunchTemplateVersions"][0]["LaunchTemplateData"]["ImageId"]
            availableImage = client.describe_images(
                Filters=[
                    {
                        'Name': 'name',
                        'Values': [
                            "Windows_Server-2016-English-Full-Base*",
                        ]
                    },
                ],
                Owners=[
                    'amazon',
                ]
            )
            availableImage = availableImage["Images"]
            LatestAmiId = sorted(
                availableImage, key=lambda i: i['CreationDate'], reverse=True)[0]["ImageId"]
            if LatestAmiId is oldimageid:
                New_Block_device_mapping = sorted(
                    availableImage, key=lambda i: i['CreationDate'], reverse=True)[0]["BlockDeviceMappings"]
                res = []
                for sub in New_Block_device_mapping:
                    if sub["DeviceName"] in "/dev/sda1":
                        print(sub)
                        res.append(sub)
                        New_Block_device_mapping = res
                        newmaxltdata = dict()
                        newmaxltdata["ImageId"] = str(LatestAmiId)
                        newmaxltdata["BlockDeviceMappings"] = New_Block_device_mapping
                        newmaxltdata["BlockDeviceMappings"][0]["Ebs"]["VolumeSize"] = 50
                        print("Creating New LT Version with New AMI ID...")
                        UpdatedLtData = client.create_launch_template_version(LaunchTemplateName=LTName, SourceVersion=str(
                            max(seq)), VersionDescription='New version From Lambda', LaunchTemplateData=newmaxltdata)
                        if UpdatedLtData["LaunchTemplateVersion"]["LaunchTemplateData"]["ImageId"] is not None:
                            NewLtVersionData = client.describe_launch_template_versions(
                                LaunchTemplateName=LTName)
                            NewLtVersionData = NewLtVersionData["LaunchTemplateVersions"]
                            Newseq = [x['VersionNumber'] for x in NewLtVersionData]
                            if Newseq > seq:
                                disable_autoscaling_healthchek()
                                body = "New AMI Id will be - " + \
                                    UpdatedLtData["LaunchTemplateVersion"]["LaunchTemplateData"]["ImageId"] + \
                                    " Old Image Was - " + oldimageid + " For LaunchTemplate " + LTName
                                send_request(str(body))
            else:
                print("Already at Latest Image...")
                body = "Nothing Updated as Image was Latest"
                send_request(str(body))
        return {
            'statusCode': 200,
            'body': json.dumps(str(body))
        }


def disable_autoscaling_healthchek():
    print("Disabling HealthCheck Now..")
    asclient = boto3.client('autoscaling')
    response = asclient.resume_processes(
        AutoScalingGroupName=os.environ['AutoScalingGroupName'],
        ScalingProcesses=[
            'HealthCheck',
        ]
    )
    print(response["ResponseMetadata"]["HTTPStatusCode"])


def send_request(body):
    # Create an SNS client
    sns = boto3.client('sns')

    # Publish a simple message to the specified SNS topic
    response = sns.publish(
        TopicArn=os.environ['EmailTopicName'],
        Message=body,
    )

    # Print out the response
    print(response)


def create_ami(instnceId):
    pass
