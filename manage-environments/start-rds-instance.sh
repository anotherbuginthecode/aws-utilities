#!/bin/bash

while [ $# -gt 0 ]; do
  case "$1" in
    --rds-instance-id*)
      shift
      RDS_INSTANCE_ID="${1#}"
    ;;
    --profile*)
      shift
      AWS_PROFILE="${1#}"
    ;;
    --help*)
      echo "--irds-instance-id <String> is your rds database identifier."
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

echo "Starting RDS database..."

RDS_STATUS=$(echo | aws rds describe-db-instances --db-instance-identifier $RDS_INSTANCE_ID --profile $AWS_PROFILE | jq ".DBInstances[].DBInstanceStatus" | tr -d '"')

if [[ $RDS_STATUS == "available" ]]
then
  echo "RDS database is already available."
  exit
fi

aws rds start-db-instance --db-instance-identifier $RDS_INSTANCE_ID --profile $AWS_PROFILE &> /dev/null

echo "Waiting RDS database switch to available status..."

while [[ $RDS_STATUS != "available" ]]
do
  sleep 2
  RDS_STATUS=$(echo | aws rds describe-db-instances --db-instance-identifier $RDS_INSTANCE_ID --profile $AWS_PROFILE | jq ".DBInstances[].DBInstanceStatus" | tr -d '"')
done

echo "RDS database is now available!"
exit

