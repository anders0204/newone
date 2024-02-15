# newone
[![CI](https://github.com/Simula-Consulting/newone/actions/workflows/test.yml/badge.svg)](https://github.com/Simula-Consulting/newone/actions/workflows/test.yml)

A short description of the project.

The minimal Python version is 3.8. For other dependencies, refer to `pyproject.toml`.
Dependencies are managed with [poetry](https://python-poetry.org/docs/).

## Installation
```bash
# install poetry, if not installed yet
curl -sSL https://install.python-poetry.org | python -
# install project
poetry install
```
Development dependendies can be ignored by appending the last command with `--without dev`.

## Usage
After installing, run
```
python main.py
```

## Development

For a development install, please install the development requirements.
Then install the pre-commit hook (<https://pre-commit.com/>):
```
pre-commit install
```

### Testing

We use `pytest` to run the tests. You can execute all tests using the command

```
python -m pytest
```

### Continuous integration

All tests are run using GitHub actions on _push_ and _pull requests_.

### Infrastructure

A Terraform configuration for standard Azure infrastructure is added in the `infrastructure` folder. The architecture consists of a PosgreSQL database and two web apps, one for the frontend and one for the backend.

#### Prerequisites
- Install Terraform:
    1. Install the HashiCorp tap: `brew tap hashicorp/tap`
    2. Install Terraform: `brew install hashicorp/tap/terraform`
- Install the Azure CLI with `brew install azure-cli`
- Modify the `secrets.tfvars` at the root of the project to have the following contents:
    ```
    db_username = "YOUR_DB_USERNAME"
    db_password = "YOUR_DB_PASSWORD"
    ```

#### Usage
The easiest way to work with Terraform is to configure and provision brand new resources under an Azure subscription. That is what the configuration in this repository is set up to do, and that way of working is covered below. However, it should also be possible to import existing infrastructure into a new Terraform configuration. This has not yet been explored, but a good place to start could be [this guide](https://techcommunity.microsoft.com/t5/itops-talk-blog/how-to-manage-existing-azure-resource-groups-using-terraform/ba-p/1648135).

Create a new Azure subscription (or use an existing one if you have one), and make sure you have at least Contributor rights for it. Terraform needs permission to access your Azure subscription. This is done via the Azure CLI. First, log in to your account with `az login`. Once you've authenticated, you should see a list of the subscriptions you have access to (if not, list them with `az account list`). Find the id of the subscription you wish to work under, and set that subscription as the current active subscription with `az account set --subscription <SUBSCRIPTION-ID>`. This should be sufficient to let Terraform provision resources under your subscription. If not, you might need to create a service principal for the subscription. Follow the steps in the [Terraform tutorial](https://learn.hashicorp.com/tutorials/terraform/azure-build?in=terraform/azure-get-started#create-a-service-principal) to do this.

Next, navigate to the root of the project and run `terraform init`. You are now ready to work with Terraform. If you wish to provision the resources specified in the current configuration, simply run
```
terraform apply -var-file="secrets.tfvars"
```
Alternatively, if you want to modify the configuration, make changes to `main.tf` and preview the changes Terraform would need to make to your existing infrastructure by replacing `apply` with `plan` in the command above. Apply the changes with the `apply` command. If you want to tear down all of the resources provisioned by Terraform, run the command with `destroy` instead of `apply`.

For more details on a typical Terraform workflow, consult the [Terraform introduction](https://www.terraform.io/intro) or the [Terraform tutorial](https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code?in=terraform/azure-get-started).
