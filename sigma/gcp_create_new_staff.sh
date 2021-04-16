#! /bin/bash
# install gcp project for workspace

# keyin name
echo " > Enter STAFF_NAME : "
read -r STAFF_NAME
echo " > Verify STAFF_NAME => $STAFF_NAME ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "@Start create GCP project"; break;;
        No ) exit;;
    esac
done
#* -- ENV --
# STAFF_NAME=test
STAFF_EMAIL="$STAFF_NAME"@lctech.com.tw
NEW_PROJ=lcwp-"$STAFF_NAME"
#* - GCP -
GCP_ORG=lctech.com.tw
GCP_ORG_FOLDER=workspaces
GCP_BILL_ID=016C7E-002F99-DBD754
GCP_ORG_ID=$(gcloud organizations list | grep $GCP_ORG | awk '{print $2}')                                                        # {DISPLAY_NAME,ID,DIRECTORY_CUSTOMER_ID}
GCP_ORG_FOLDER_ID=$(gcloud alpha resource-manager folders list --organization="$GCP_ORG_ID" | grep $GCP_ORG_FOLDER | awk '{print $3}') # {DISPLAY_NAME,PARENT_NAME,ID}
#* - GCE -
GCP_GCE_NAME="gce-$STAFF_NAME"
#* - NAS Storage -
GCP_STORAGE_NAME=storage-"$STAFF_NAME"
GCP_STORAGE_PROJ="$NEW_PROJ"
GCP_STORAGE_CLASS=standard
GCP_STORAGE_LOCATION=asia-east1
# 建立專案 # --organization=$GCP_ORG_ID
if ! gcloud projects list --format="table(projectId)" | grep -q "$NEW_PROJ"; then
    # 建立專案
    echo "@create proj"
    gcloud projects create "$NEW_PROJ" --folder="$GCP_ORG_FOLDER_ID"
    # 綁定帳單
    echo "@billing proj"
    gcloud alpha billing projects link "$NEW_PROJ" --billing-account=$GCP_BILL_ID
fi
# 綁定專案
gcloud config set project "$NEW_PROJ"
# 設定用戶
gcloud projects add-iam-policy-binding "$NEW_PROJ" \
    --member=user:ir@lctech.com.tw --role=roles/owner
gcloud projects add-iam-policy-binding "$NEW_PROJ" \
    --member=user:zeki@lctech.com.tw --role=roles/owner
gcloud projects add-iam-policy-binding "$NEW_PROJ" \
    --member=user:"$STAFF_EMAIL" --role=roles/edit
# 設定監控 A-預處理
if [ ! -f ./set-permissions.sh ];then
curl -LJO https://raw.githubusercontent.com/lctech-tw/util_scripts/main/sigma/set-permissions.sh
fi
bash set-permissions.sh --project="$NEW_PROJ" \
      --iam-service-account="$STAFF_EMAIL" \
      --iam-permission-role=guestPolicyViewer
# 設定監控 B-設定
gcloud beta compute instances ops-agents policies create ops-agents-policy-safe-rollout \
    --agent-rules="type=logging,version=current-major,package-state=installed,enable-autoupgrade=true;type=metrics,version=current-major,package-state=installed,enable-autoupgrade=true" \
    --os-types=short-name=debian,version=10
# 建立GCS
gsutil mb -p "$GCP_STORAGE_PROJ" -c $GCP_STORAGE_CLASS -l $GCP_STORAGE_LOCATION -b on gs://"$GCP_STORAGE_NAME"
# 建立防火牆規則
gcloud compute --project="$NEW_PROJ" firewall-rules create tag-office-rules \
    --direction=INGRESS --network=default --action=ALLOW --rules=all \
    --source-ranges=61.216.175.49,60.251.234.18,35.185.147.25 --target-tags=tag-office
# 建立虛擬機 ＆ 掛防火牆
gcloud beta compute instances create "$GCP_GCE_NAME" --project="$NEW_PROJ" \
    --zone=asia-east1-b --machine-type=e2-medium \
    --tags=tag-office --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced --boot-disk-device-name=test \
    --image-project=debian-cloud --image=debian-10-buster-v20210316 \
    --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring
# VM取IP
GCP_GCE_IP=$(gcloud compute instances list | grep "$GCP_GCE_NAME" | awk '{print $5}')
echo " > IP : $GCP_GCE_IP ----------------------------------------"
# 連線 func
function GCP_GCE_SSH_CMD(){
    gcloud beta compute ssh --zone "asia-east1-b" "$GCP_GCE_NAME" --project "$NEW_PROJ" --command "$@" 
}
# 掛GCS / Use gcsfuse
GCP_GCE_SSH_CMD "sudo mkdir -p /storage"
GCP_GCE_SSH_CMD "sudo chmod 777 +R /storage"
GCP_GCE_SSH_CMD "gcsfuse $GCP_STORAGE_NAME /storage"
GCP_GCE_SSH_CMD "ls /storage"
# SMB for Apple M1
GCP_GCE_SSH_CMD "sudo apt install samba -y"
# [file]
#     comment = A new share
#     path = /storage
#     browseable = yes
#     read only = no
#     guest ok = no
#     valid users = nick
# GCP_GCE_SSH_CMD "sudo smbpasswd -a $STAFF_NAME"
# GCP_GCE_SSH_CMD "sudo systemctl restart smbd"