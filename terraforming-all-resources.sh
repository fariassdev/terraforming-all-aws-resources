#!/bin/bash

export AWS_REGION=eu-west-1
AWS_PROFILE=mow
TERRAFORM_RESOURCES_FOLDER=terraform_$AWS_PROFILE

echo Using $AWS_PROFILE AWS profile. Ensure you have this profile in $HOME/.aws/credentials file
echo [$AWS_PROFILE]
echo aws_access_key_id = XXXXXXXXXXXXXXXXXXXX
echo aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

mkdir -p $TERRAFORM_RESOURCES_FOLDER
cd $TERRAFORM_RESOURCES_FOLDER

terraforming help | grep terraforming | grep -v help | awk -v aws_profile="$AWS_PROFILE" '{print "terraforming", $2, "--profile", aws_profile, ">", $2".tf";}' | bash

echo Empty terraform files:
find . -type f -name '*.tf' | xargs wc -l | grep ' 1 .'

if [ ! -z "$1" ]; then
	if [[ $1 != --preserve-empty ]]; then
		echo -e "\e[31mInvalid parameter value, you can use --preserve-empty parameter for preserve empty files\e[0m"
	fi
else
	echo -e "\e[32mDeleting empty terraform files, for preserve empty files use the --preserve-empty argument...\e[0m"
	find . -type f -name '*.tf' | xargs -i bash -c 'if [ $(wc -l {}|cut -d" " -f1) -eq 1 ]; then rm -f {}; fi'
fi

