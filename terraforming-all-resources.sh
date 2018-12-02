#!/bin/bash

empty_parameter_error() {
    printf 'ERROR: "--%s" requires a non-empty option argument.\n' "$1"
    exit 1
}

missing_parameter_error() {
    printf 'ERROR: Missing option argument "--%s".\n' "$1"
}

show_help() {
    echo -e "Terraforming all AWS infrastructure\n"
    echo -e "Export all AWS existing resources to Terraform files using Terraforming tool."
	echo -e "This command uses https://github.com/dtan4/terraforming project. dtan4/terraforming is licensed under the MIT License.\n"
    echo -e "Usage:"
    echo -e "\t${0##*/} --region <AWS_REGION> --profile <AWS_PROFILE>"
    echo -e "\t${0##*/} -h | --help\n"
    echo -e "Options:"
    echo -e "\t-h --help\t\t\tdisplay this help and exit"
    echo -e "\t-r --region AWS_REGION\t\tthe AWS region you want to export from"
    echo -e "\t-p --profile AWS_PROFILE\tthe AWS profile of your ~/.aws/credentials file\n"
    echo -e "Extra help:"
    echo -e "\tEnsure you have a profile in $HOME/.aws/credentials file.\n"
    echo -e "\tProfile example in $HOME/.aws/credentials file:"
    echo -e "\t[AWS_PROFILE]"
    echo -e "\taws_access_key_id = XXXXXXXXXXXXXXXXXXXX"
    echo -e "\taws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}

profile=
region=

while :; do
    case $1 in
        -h|-\?|--help)
            show_help
            exit
            ;;
        -p|--profile)
            if [ "$2" ]; then
                profile=$2
                shift
            else
                empty_parameter_error "profile"
            fi
            ;;
        --profile=?*)
            profile=${1#*=}
            ;;
        --profile=)
            empty_parameter_error "profile"
            ;;
        -r|--region)
            if [ "$2" ]; then
                region=$2
                shift
            else
                empty_parameter_error "region"
            fi
            ;;
        --region=?*)
            region=${1#*=}
            ;;
        --region=)
            empty_parameter_error "region"
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)
            break
    esac

    shift
done

export AWS_REGION=$region
dir=terraform_$profile_$region

if [ ! -z "$profile" ] && [ ! -z "$region" ]; then
    mkdir -p $dir
    cd $dir

    echo -e "\e[32mExporting AWS resources into $dir...\e[0m"
    terraforming help | grep terraforming | grep -v help | awk -v aws_profile="$profile" '{print "terraforming", $2, "--profile", aws_profile, ">", $2".tf";}' | bash

    echo -e "\e[32mDeleting empty terraform files...\e[0m"
	find . -type f -name '*.tf' | xargs -i bash -c 'if [ $(wc -l {}|cut -d" " -f1) -eq 1 ]; then rm -f {}; fi'
else
    if [ -z "$region" ]; then missing_parameter_error "region" ; fi
    if [ -z "$profile" ]; then missing_parameter_error "profile" ; fi
    exit 1
fi