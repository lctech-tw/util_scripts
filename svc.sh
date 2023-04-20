#! /bin/bash
# Purpose: Create GCP service account and setting role
# Author: zeki@lctech.com.tw
# Requirments: gcloud
# -------------------------------------------------------------------
# Usage: 
# GCP_PROJECT=aa GCP_SVC_NAME=bb GKE_NAMESPACE=cc svc.sh
# -------------------------------------------------------------------
# Notes:
# -------------------------------------------------------------------

# GCP
GCP_PROJECT=""
GCP_SVC_NAME=""
# GKE
GKE_NAMESPACE=""
GKE_SVC_ACCOUNT="default"
GCP_PROJECT=123

# Init color
RED='\033[0;31m'
NC='\033[0m'


# check env
INPUT_ENVS=("GCP_PROJECT" "GCP_SVC_NAME" "GKE_NAMESPACE")
for ((i = 0; i <= ${#INPUT_ENVS[@]}; i++)); do
    if [ -z "${!INPUT_ENVS[i]}" ] ; then
        echo "${RED}${INPUT_ENVS[i]}${NC} is empty"
        read -p "${INPUT_ENVS[i]}:" -r "${INPUT_ENVS[i]}"
        echo "${!INPUT_ENVS[i]}"
    else
        echo "${INPUT_ENVS[i]}: ${!INPUT_ENVS[i]}"
    fi
done

# Create svc
gcloud iam service-accounts create "$GCP_SVC_NAME" \
    --display-name "$GCP_SVC_NAME" \
    --project "$GCP_PROJECT"

# Setting svc / gke workloadIdentityUser
gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$GCP_PROJECT.svc.id.goog[$GKE_NAMESPACE/$GKE_SVC_ACCOUNT]" \
    "$GCP_SVC_NAME"@"$GCP_PROJECT".iam.gserviceaccount.com \
    --project "$GCP_PROJECT"

# Settng default service role
SET_ROLE=(
    "roles/logging.logWriter"
    "roles/cloudprofiler.agent"
    "roles/cloudtrace.agent"
    "roles/secretmanager.secretAccessor")
for ((i = 1; i <= ${#SET_ROLE[@]}; i++)); do
    #echo "${SET_ROLE[i]}"
    gcloud projects add-iam-policy-binding "$GCP_PROJECT" \
        --member "serviceAccount:$GCP_SVC_NAME@$GCP_PROJECT.iam.gserviceaccount.com" \
        --role "${SET_ROLE[i]}" \
        -quiet \
        --project "$GCP_PROJECT"
done
