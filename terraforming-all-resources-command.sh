#!/bin/bash

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

show_help() {
    echo -e "Usage: ${0##*/} [--region AWS_REGION] [--profile AWS_PROFILE] [--dir DIR]...\n"
    echo -e "Export all AWS existing resources to Terraform files using Terraforming tool."
    echo -e "\t--help\t\t\tdisplay this help and exit"
    echo -e "\t--region AWS_REGION\tthe AWS region you want to export from. Default: eu-west-1"
    echo -e "\t--profile AWS_PROFILE\tthe AWS profile of your ~/.aws/credentials file"
    echo -e "\t--dir DIR\t\tdirectory where terraform resources will be saved. Default: terraform"
}

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
file=
verbose=0

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -f|--file)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                file=$2
                shift
            else
                die 'ERROR: "--file" requires a non-empty option argument.'
            fi
            ;;
        --file=?*)
            file=${1#*=} # Delete everything up to "=" and assign the remainder.
            ;;
        --file=)         # Handle the case of an empty --file=
            die 'ERROR: "--file" requires a non-empty option argument.'
            ;;
        -v|--verbose)
            verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

# if --file was provided, open it for writing, else duplicate stdout
if [ "$file" ]; then
    exec 3> "$file"
else
    exec 3>&1
fi