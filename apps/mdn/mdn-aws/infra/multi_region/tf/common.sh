#!/bin/bash

set -e
set -u

check_prereqs() {
    if [ -z "${MDN_PROVISIONING_REGION}" ]; then
    echo "MDN_PROVISIONING_REGION must be set"
    exit -1
    fi


    if [ -z "${TERRAFORM_ENV}" ]; then
    echo "TERRAFORM_ENV must be set"
    exit -1
    fi
}

TF_ARGS=$@

MDN_PROVISIONING_BUCKET="mdn-multi-region-tf-state"
STATE_BUCKET_REGION="us-west-2"

setup_tf_s3_state_store() {
    echo "Creating Terraform state bucket at s3://${MDN_PROVISIONING_BUCKET} (region ${STATE_BUCKET_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${MDN_PROVISIONING_BUCKET} --region ${STATE_BUCKET_REGION}
}

setup_tf_envs() {
    # this MUST be run in the dir that this file resides in
    set +e
    terraform env new tokyo
    terraform env new virginia
    set -e
}

check_state_store() {
    echo "Checking state store"
    set +e
    if aws s3 ls s3://${MDN_PROVISIONING_BUCKET} > /dev/null 2>&1; then
        echo "State store already exists"
    else
        echo "Setting up state store"
        setup_tf_s3_state_store
        echo "Setting up envs"
        setup_tf_envs
    fi
    set -e
}

tf_main() {
    # it's safe to always init the s3 backend
    terraform init

    setup_tf_envs

    # switch env to virginia, tokyo etc
    terraform env select ${TERRAFORM_ENV}

    # import local modules
    #terraform get

    PLAN=$(mktemp)
    terraform plan --out $PLAN $TF_ARGS
    # if terraform plan fails, the next command won't run due to
    # set -e at the top of the script.
    terraform apply $PLAN
    rm $PLAN
}

check_prereqs
check_state_store
tf_main


