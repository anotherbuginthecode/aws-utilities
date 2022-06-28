#!/bin/bash

# DEFINE EXTERNAL SOURCES
source ../common/yaml-parser.sh
source ../common/helpers.sh
source ../common/style.sh

# DEFINE VARIABLES
TEMPLATE_FILE=
ENVIRONMENT=
SSH_KEY_FILE=
AWS_PROFILE=
REGION=

while [ ! -z "$1" ]; do
  case "$1" in
     --template-file|-f)
         shift
         TEMPLATE_FILE=$1
         ;;
    --environment|-e)
        shift
        ENVIRONMENT=$1
        ;;
    --ssh-key|-k)
        shift
        SSH_KEY_FILE=$1
        ;;
    --region|-r)
        shift
        REGION=$1
        ;;
    --profile|-p)
        shift
        AWS_PROFILE=$1
        ;;
     *)
		echo "--template-file <String>: fullpath of your template.yml file where you have defined your enviroment configuration"
		echo "--ssh-key <String>: fullpath of your ssh key to connect to EC2 instance and start configuration"
		echo "--environment <String>: define your environment where you want to run the script"
		echo "--region <String>: in which region your EC2 instances are defined."
		echo "--profile <String>: if you have multiple aws profile you need to specify which one to pick. If empty 'default' will be choose"
		;;
  esac
shift
done

if [[ -z $AWS_PROFILE ]]
then
	AWS_PROFILE=default
fi


# get ec2 instances from template file
EC2_INSTANCES=$(yaml $TEMPLATE_FILE environment.$ENVIRONMENT.instances)
EC2_INSTANCES=$(concat_w_comma $EC2_INSTANCES)

echo "${info}INFO${reset}: environment ${bold}$ENVIRONMENT${reset}"
echo "${info}INFO${reset}: instances found ${bold}$EC2_INSTANCES${reset}"

# get database
RDS_INSTANCE=$(yaml $TEMPLATE_FILE environment.$ENVIRONMENT.database)
echo "${info}INFO${reset}: database found ${bold}$RDS_INSTANCE${reset}"

bash $PWD/start-enviroment.sh --instance-ids $EC2_INSTANCES --rds-instance-id $RDS_INSTANCE --region $REGION --profile $AWS_PROFILE --ssh-key $SSH_KEY_FILE



