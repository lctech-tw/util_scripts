import os


def access_secret_version(project_id, secret_id, version_id, env_name):
    from google.cloud import secretmanager
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"
    response = client.access_secret_version(request={"name": name})
    os.environ[env_name] = response.payload.data.decode("UTF-8")


#635335492910 / jkf-servers
access_secret_version("635335492910", "slack_url", "latest", "SLACK_URL")
print("env.SLACK_URL : "+os.getenv("SLACK_URL"))
