#!/bin/bash

# DEFINE EXTERNAL SOURCES
source ../common/style.sh

# DECLARE FUNCTIONS

function startup(){

bash $PWD/start-ec2-instance.sh --instance-ids $i --profile $AWS_PROFILE
ec2_ip=$(echo | aws ec2 describe-instances --instance-ids $i --profile $AWS_PROFILE | jq ".Reservations[].Instances[].PublicIpAddress" | tr -d '"')
# ssh into ec2 instance
# echo "${info}INFO${reset}: Configuration..."
#echo "SSH into ec2 instances with IP $ec2_ip"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $SSH_KEY_FILE ec2-user@$ec2_ip /bin/bash << EOF
# echo "Starting docker containers..."
bash start-docker.sh &> /dev/null
if [[ \$? -eq 0 ]] 
then
# echo "docker containers are running!"
exit 0
fi
EOF
out=0
}

# DEFINE VARIABLES
EC2_INSTANCE_ID=
RDS_INSTANCE_ID=
REGION=
SSH_KEY_FILE=
frames="/ | \\ -"

while [ ! -z "$1" ]; do
  case "$1" in
     --instance-ids|-i)
         shift
         EC2_INSTANCE_ID=$1
         ;;
    --rds-instance-id|-d)
        shift
        RDS_INSTANCE_ID=$1
        ;;
    --profile|-p)
        shift
        AWS_PROFILE=$1
        ;;
    --region|-r)
        shift
        REGION=$1
        ;;
    --ssh-key|-k)
        shift
        SSH_KEY_FILE=$1
        ;;
     *)
		echo "--instance-ids <String>: is your ec2 instances you want to start (ex. i-0add17d16aa8cd46f)"
		echo "--profile <String>: if you have multiple aws profile you need to specify which one to pick. If empty 'default' will be choose"
		echo "--rds-instance-id <String>: is your database-id in aws"
		echo "--region <String>: in which region your EC2 instances are defined."
		echo "--ssh-key <String>: fullpath of your ssh key to connect to EC2 instance and start configuration"
		;;
  esac
shift
done

if [[ -z $AWS_PROFILE ]]
then
	AWS_PROFILE=default
fi

echo "${info}INFO${reset}: Starting EC2 instances..."

for i in ${EC2_INSTANCE_ID//,/ };
do
    printf "\r- Configuration..."
    _out=$(startup)
done

printf "All EC2 instances are ready.\n"
printf "${info}INFO${reset}: Starting database..."
bash $PWD/start-rds-instance.sh --rds-instance-id $RDS_INSTANCE_ID
wait
printf "Database is ready.\n"
exit 0