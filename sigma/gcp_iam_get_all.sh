#! /bin/bash

#? Need yq -V = 4.6.1

# print iam list

# #* MODE A
# for i in $(gcloud projects list |  sed 1d | cut -f1 -d$' '); do 
#     gcloud projects get-iam-policy $i;
# done;

# #* MODE B one.csv
# for i in $(gcloud projects list | sed 1d | cut -f1 -d$' '); do
#     echo "Getting IAM policies for project:" $i;
#     echo "..........";
#     (echo "ROLES,MEMBERS" && paste -d "," <(printf %s "$(gcloud projects get-iam-policy $i | yq eval '.bindings | .[].role' - | cut -d "\"" -f2)") <(printf %s "$(gcloud projects get-iam-policy $i | yq eval '.bindings | .[].members | join(",")' - | cut -d"\"" -f2)")) | cat >> $i.csv
 
#     echo "Done. Logs created at file" $i.csv;
#     echo "--------------------------------"
# done;

#* MODE C all.csv
echo "PROJECT_ID,ROLES,MEMBERS" | cat >> output.csv
for i in $(gcloud projects list |  sed 1d | cut -f1 -d$' '); do
    echo "Getting IAM policies for project:" $i;
    echo "..........";
    paste -d "," <(printf %s "$(for j in $(seq 1 $(gcloud projects get-iam-policy $i | yq eval '.bindings | .[].role' - | cut -d "\"" -f2 | wc -l)); do echo $i; done;)") <(printf %s "$(gcloud projects get-iam-policy $i | yq eval '.bindings | .[].role' - | cut -d "\"" -f2)") <(printf %s "$(gcloud projects get-iam-policy $i | yq eval '.bindings | .[].members | join("/")' - | cut -d"\"" -f2)") | cat >> output.csv
 
    echo "Done. Logs created at file" $output.csv;
    echo "--------------------------------"
done;