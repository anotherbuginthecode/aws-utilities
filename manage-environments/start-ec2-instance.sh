#!/bin/bash

while [ $# -gt 0 ]; do
	case "$1" in
		--instance-ids*)
			shift
			EC2_INSTANCE_ID="${1#}"
		;;
		--profile*)
			shift
			AWS_PROFILE="${1#}"
		;;
		--help*)
			echo "--instance-ids <String> is your ec2 instances you want to start (ex. i-0add17d16aa8cd46f)"
			echo "--profile <String> if you have multiple aws profile you need to specify which one to pick. If empty default will be choose"
			exit 0
		;;
		*)
		exit 1
	esac
	shift
done

if [[ -z $AWS_PROFILE ]]
then
	AWS_PROFILE=default
fi

echo "Starting EC2 $EC2_INSTANCE_ID..."

EC2_STATUS_CODE=$(aws ec2 describe-instances --instance-ids $EC2_INSTANCE_ID --profile $AWS_PROFILE | jq ".Reservations[].Instances[].State.Code")

if [[ EC2_STATUS_CODE -eq 16 ]]
then
	echo "EC2 $EC2_INSTANCE_ID is already in running state."
	exit 0
fi

aws ec2 start-instances --instance-ids $EC2_INSTANCE_ID --profile $AWS_PROFILE &> /dev/null

echo "Waiting EC2 if fully running..."

while [[ EC2_STATUS_CODE -ne 16 ]]
do
	sleep 2
	EC2_STATUS_CODE=$(aws ec2 describe-instances --instance-ids $EC2_INSTANCE_ID --profile $AWS_PROFILE | jq ".Reservations[].Instances[].State.Code")
done

echo "EC2 $EC2_INSTANCE_ID ready!"
exit 0

