#! /bin/bash

# GCP
GCP_PROJECT="proj"
GCP_SVC_NAME="sa-name"
# GKE
GKE_NAMESPACE="nsName"
GKE_SVC_ACCOUNT="default"

# Create svc
gcloud iam service-accounts create $GCP_SVC_NAME \
    --display-name $GCP_SVC_NAME \
    --project $GCP_PROJECT

# Setting svc / gke workloadIdentityUser
gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$GCP_PROJECT.svc.id.goog[$GKE_NAMESPACE/$GKE_SVC_ACCOUNT]" \
    $GCP_SVC_NAME@$GCP_PROJECT.iam.gserviceaccount.com \
    --project $GCP_PROJECT

# Settng default service role
SET_ROLE=(
    "roles/logging.logWriter"
    "roles/cloudprofiler.agent"
    "roles/cloudtrace.agent"
    "roles/secretmanager.secretAccessor")
for ((i = 1; i <= ${#SET_ROLE[@]}; i++)); do
    #echo "${SET_ROLE[i]}"
    gcloud projects add-iam-policy-binding $GCP_PROJECT \
        --member "serviceAccount:$GCP_SVC_NAME@$GCP_PROJECT.iam.gserviceaccount.com" \
        --role "${SET_ROLE[i]}" \
        -quiet \
        --project $GCP_PROJECT
done
