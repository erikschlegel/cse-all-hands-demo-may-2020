# CSE All Hands - May 2020

This repository contains material that will be covered during the May 2020 CSE All Hands sessions

## Devcontainers

## Terraform provider for Azure DevOps

The [Terraform provider for Azure DevOps](https://github.com/microsoft/terraform-provider-azuredevops) allows you to create and manage Azure DevOps resources through [Terraform](https://www.terraform.io/). The code included in this repository will showcase a subset of the features for this provider.

*Note:*. The Terraform Provider for Azure DevOps is not yet released to HashiCorp's official registry. Until it is, you will need to manually install it by following [the instructions](https://github.com/microsoft/terraform-provider-azuredevops/blob/master/docs/contributing.md#3-build--install-provider)

### Resources Provisioned

**Azure DevOps** (`azdo.tf`)
- Project
- Variable Groups
  - `Vars - Common`
  - `Vars - $STAGE`
  - `Secrets - $STAGE`
- Git Repository
- Build Definition (pipeline)
- Service Connection
- Service Connection Authorization

**Azure Active Directory** (`azure.tf`)

- AAD Application
- Service Principal

**Azure** (`azure.tf`)

- Role assignment for provisioned service principal

### Deploy Resources

```bash
# 1. Initialize Terraform
terraform init tf-code/

# 2. Deploy Resources
terraform apply tf-code/
```

### Push some code

```bash
# 1. Get repo clone URL
REPO_CLONE_URL=$(terraform output -json | jq -r '.repo_clone_url.value')

# 2. Clone repo using AzDO PAT
git clone $(echo $REPO_CLONE_URL | sed "s/https:\/\//https:\/\/$AZDO_PERSONAL_ACCESS_TOKEN@/g") .tmp/

# 3. Add AzDO Pipelines to Repo
mkdir .tmp/
cp pipeline-code/*.yml .tmp/
(
    cd .tmp/                                   && \
    git add -A                                 && \
    git commit -m"Adding azure pipeline files" && \
    git push
)

# 4. Remove local repo directory
rm -rf .tmp/
```

### Run Pipeline

Navigate to your newly created project in Azure DevOps and run your pipeline. You should see that the pipeline runs without issues


### Cleaning Up

> Note: This is a destructive action! Only do it if you are sure you want to destroy your environment
```bash
# 1. Destroy all provisioned resources
terraform destroy tf-code/
```