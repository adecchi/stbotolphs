### Preconditions
Install the following software:
- [terraform ](https://www.terraform.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [google-cloud-sdk](https://cloud.google.com/sdk/docs/install)

You can install using the script called `install_requeriments.sh` inside the scripts folder.
In case of failure, read the above links.

###  List Google Apis enabled
``` bash
https://console.cloud.google.com/apis/dashboard
``` 
or
``` bash
$ gcloud services list --enabled
```
In our project we will use the followings:
- `container.googleapis.com`
- `containerregistry.googleapis.com`
- `cloudbuild.googleapis.com`
- `compute.googleapis.com`
- `servicenetworking.googleapis.com`
- `cloudresourcemanager.googleapis.com`
- `secretmanager.googleapis.com`
- `sqladmin.googleapis.com`

# Google Auth Scope
The following auth scope we will use in our terraform.
- [Logging](https://www.googleapis.com/auth/logging.write)
- [Monitoring](https://www.googleapis.com/auth/monitoring)
- [Cloud Platform](https://www.googleapis.com/auth/cloud-platform)
- [Compute](https://www.googleapis.com/auth/compute)
- [SQL](https://www.googleapis.com/auth/sqlservice.admin)
- [Storage](https://www.googleapis.com/auth/devstorage.full_control)

### Preparing our account to deploy
Enable Google Cloud Build Service to connect to Github and deploy.
So, login in [Google Console](https://console.cloud.google.com/home/dashboard) select your project and then tahe note of
the `Project number` and `Project ID` and replace in the below command and execute.

``` bash
cloud projects add-iam-policy-binding [Project ID] --member=serviceAccount:[Project number]@cloudbuild.gserviceaccount.com --role=roles/container.developer
```
### Editing Terraform files
Edit the following files and complete with your `Project ID` and `region` to use.
``` bash
$ vim terraform/gcloud_cloudbuild/terraform.tfvars
$ vim terraform/gke/terraform.tfvars
```

### Deploy Infrastructure
Here is the list of command to execute to create the trigger in Google Cloud Build.:
``` bash
$ cd terraform/gcloud_cloudbuild
$ terraform init
$ terraform plan -out stbotolphs.plan
$ terraform apply stbotolphs.plan
```
You will get an error due you need to map the Github repository with Google Cloud Build. The error provide you an URL, 
where you only have to accept the map.

Now, we continue creating the resto fo the infrastructure:
``` bash
$ cd terraform/gke
$ terraform init
$ terraform plan -out stbotolphs.plan
$ terraform apply stbotolphs.plan
```
In case of some error,for example `namespaces "stbotolphs" not found` or `Error: Failed to update Ingress stbotolphs/stbotolphs-ingress because: namespaces "stbotolphs" not found
` or others, please wait 5 minutes and rerun terraform.
You can monitor or watch the error in [Google Cloud Build](https://console.cloud.google.com/cloud-build/)
``` bash
$ terraform plan -out stbotolphs.plan
$ terraform apply stbotolphs.plan
```
Once we finished, We have created and configured the following services:

- Google Storage Bucket
- GKE
- Google SQL
- Google VPC and VPC Peering
- Google Cloud Deploy
- Google Secret Manager

### Configure Database for Django
Copy the output and configure it in `k8s-config/deployment.yaml` in the container name `cloud-sql-proxy` under command section.
``` bash
$ terraform output SQL_DB_Connection_Name
$ vim k8s-config/deployment.yaml
```

### Commit and deploy
Inside [Google Cloud Build](https://console.cloud.google.com/cloud-build/) you will find the trigger that:
- Build the image
- Insert  the secrets inside the image
- Create the image
- Push the image
- Deploy the image to EKS

### Prepare Django Database
Execute the following command to make the django migration. This procedure must be executed in any POD that name start
with `st botolphs-`

``` bash
$ gcloud container clusters get-credentials stbotolphs-gke --region europe-west2 --project [PROJECT-ID]
$ kubectl config set-context --current --namespace=stbotolphs
$ kubectl exec [POD-NAME] --container stbotolphs ./manage.py migrate
```

### Create User
Execute the following command to create an user. This procedure must be executed in any POD that name start
with `st botolphs-`

``` bash
$ gcloud container clusters get-credentials stbotolphs-gke --region europe-west2 --project [PROJECT-ID]
$ kubectl config set-context --current --namespace=stbotolphs
$ kubectl exec -i -t [POD-NAME] --container stbotolphs -- /bin/sh
```
Inside the container execute:
``` bash
$ ./manage.py createsuperuser
```

### Get Application Endpoint/PublicIP
Execute the following command to get the Public IP.
``` bash
$ gcloud container clusters get-credentials stbotolphs-gke --region europe-west2 --project [PROJECT-ID]
$ kubectl config set-context --current --namespace=stbotolphs
$ kubectl get ingress stbotolphs-ingress
```
Once we get the Public IP, use it in any web explorer to access to the web site.
The `stbotolphs` web page is the default web page served by our Nginx Ingress, if you want to access to the
`sdsd` mail tool just add `/mailhog` to the end of the endpoint.

For example:

http://35.12.90.30/
http://35.12.90.30/mailhog

# Logs
To troubleshooting you can use the following logs:

Application Logs:
``` bash
$ gcloud container clusters get-credentials stbotolphs-gke --region europe-west2 --project [PROJECT-ID]
$ kubectl config set-context --current --namespace=stbotolphs
$ kubectl logs [POD-NAME] stbotolphs
```
SQL Proxy Logs:
``` bash
$ gcloud container clusters get-credentials stbotolphs-gke --region europe-west2 --project [PROJECT-ID]
$ kubectl config set-context --current --namespace=stbotolphs
$ kubectl logs [POD-NAME] cloud-sql-proxy
```

### Destroy Infrastructure
Here is the list of command to execute:
``` bash
$ cd terraform/gcloud_cloudbuild
$ terraform destroy
$ cd terraform/gke
$ terraform destroy -target=kubernetes_namespace.stbotolphs
$ terraform destroy -target=google_sql_database.cms
$ terraform destroy -target=google_sql_user.webapp -target=google_sql_user.root
$ terraform destroy
```

### Pending Improvements
- Django Migration command perhaps run at start due does not affect our DB data if it run more than once.
- Add SSL/TLS certificates and rotation of them.
- Password Rotation.
- Migrate/Improve actual Secrets Manager to allow our PODs to detects passwords change. Perhaps, Vault is better.
- Add liveness and readiness probes.
- Create automation script to deploy all the requirements and application.
- Create test cases.
- Improve documentation. 
- Improve monitoring, dashboards and alerts.
- Improve CI/CD to allow deploy by branch, tags.
- Decouple from the CI/CD the kubernetes configurations.
- Create/migrate the actual Terraform code to Modules, Create the Project in GCloud with Terraform.
- Adapt Terraform to deploy differents environments like QA, STAGE, PROD.
- Create an option to deploy with `kubectl` in place of use Terraform.

### References
- [Default Google accounts ](https://cloud.google.com/compute/docs/access/service-accounts#default_service_account)
- [GKE](https://cloud.google.com/kubernetes-engine/docs)
- [Google Secrets Manager](https://cloud.google.com/secret-manager/docs)
- [Google SQL](https://cloud.google.com/sql/docs)
- [Google Storage](https://cloud.google.com/storage/docs)
- [SQL Proxy](https://cloud.google.com/sql/docs/postgres/connect-kubernetes-engine)
- [Terraform](https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html)
