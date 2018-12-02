#!/bin/bash

empty_parameter_error() {
    printf 'ERROR: "--%s" requires a non-empty option argument.\n' "$1"
    exit 1
}

missing_parameter_error() {
    printf 'ERROR: Missing option argument "--%s".\n' "$1"
}

show_help() {
    echo -e "Usage: ${0##*/} [--region AWS_REGION] [--profile AWS_PROFILE]\n"
    echo -e "Export all AWS existing resources to Terraform files using Terraforming tool."
    echo -e "\t--help\t\t\tdisplay this help and exit"
    echo -e "\t--region AWS_REGION\tthe AWS region you want to export from. Default: eu-west-1"
    echo -e "\t--profile AWS_PROFILE\tthe AWS profile of your ~/.aws/credentials file"
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