# Make sure to set the following environment variables:
#   AZDO_PERSONAL_ACCESS_TOKEN
#   AZDO_ORG_SERVICE_URL
provider "azuredevops" {
  version = ">= 0.0.1"
}

resource "azuredevops_project" "p" {
  project_name = format("%s-project", var.prefix)
}

resource "azuredevops_variable_group" "vars_shared" {
  project_id   = azuredevops_project.p.id
  name         = "Variables - Shared"
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "VAR_A"
    value = "This variable is managed by Terraform!"
  }

  variable {
    name  = "VAR_B"
    value = "So is this one!"
  }

}

resource "azuredevops_variable_group" "vars_stage" {
  project_id   = azuredevops_project.p.id
  count        = length(var.environments)
  name         = format("Variables - %s", var.environments[count.index])
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "STAGE"
    value = var.environments[count.index]
  }

}

resource "azuredevops_variable_group" "vars_stage_secret" {
  project_id   = azuredevops_project.p.id
  count        = length(var.environments)
  name         = format("Variable Secrets - %s", var.environments[count.index])
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "STAGE_SECRET"
    value = format("Secret value for %s - %s", var.environments[count.index], strrev(var.environments[count.index]))
    is_secret = true
  }

}

resource "azuredevops_git_repository" "repo" {
  project_id = azuredevops_project.p.id
  name       = "App Repository"
  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_build_definition" "build" {
  project_id = azuredevops_project.p.id
  name       = "App Deployment Pipeline"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.repo.id
    repo_name   = azuredevops_git_repository.repo.name
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = "azure-pipelines.yml"
  }

  variable_groups = concat(
    [azuredevops_variable_group.vars_shared.id],
    azuredevops_variable_group.vars_stage.*.id,
    azuredevops_variable_group.vars_stage_secret.*.id
  )
}

resource "azuredevops_serviceendpoint_azurerm" "endpointazure" {
  project_id            = azuredevops_project.p.id
  service_endpoint_name = "Infrastructure Deployment Service Connection"
  credentials {
    serviceprincipalid  = azuread_service_principal.sp.application_id
    serviceprincipalkey = random_string.random.result
  }
  azurerm_spn_tenantid      = data.azurerm_subscription.sub.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.sub.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.sub.display_name
}
