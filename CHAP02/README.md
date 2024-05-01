## Manual installation
To install Terraform manually, perform the following steps:
1. Go to the official download page at https://www.terraform.io/
downloads.html. Then, download the package corresponding to your operating
system.
2. After downloading, unzip and copy the binary into an execution directory (for
example, inside c:\Terraform).
3. Then, the PATH environment variable must be completed with the path to the
binary directory. For detailed instructions, please view the video at https://
learn.hashicorp.com/tutorials/terraform/install-cli.

## Installing Terraform by script on Linux
To install the Terraform binary on Linux, we have two solutions. The first solution is to
install Terraform using the following script:

TERRAFORM_VERSION="1.0.6"

curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
&& curl https://keybase.io/hashicorp/pgp_keys.asc | gpg --import \
&& curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig \
&& gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS \
&& shasum -a 256 -c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1 | grep "${TERRAFORM_VERSION}_linux_amd64.zip:\sOK" \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin

or

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl \
&& curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
&& sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
&& sudo apt-get install terraform

## Installing Terraform by script on Windows
If we use Windows, we can use Chocolatey, which is a free public package manager,
such as NuGet or npm, but dedicated to software. It is widely used for the automation of
software on Windows servers or even local machines.

$ choco install terraform -y

$ terraform version

## Installing Terraform by script on macOS
On macOS, we can use Homebrew, the macOS package manager (https://brew.
sh/), to install Terraform by executing the following command in your Terminal: 

$ brew install terraform

## Configuring Terraform for Azure
Before writing the Terraform code in which to provision a cloud infrastructure such
as Azure, we must configure Terraform to allow the manipulation of resources in an
Azure subscription.
To do this, first, we will create a new Azure Service Principal (SP) in Azure Active
Directory (AD), which, in Azure, is an application user who has permission to manage
Azure resources. The SP is used to authenticate and authorize the Terraform code to use the Azure API.

## Creating the Azure SP
This operation can be done either via the Azure portal (all steps are detailed within
the official documentation at https://docs.microsoft.com/en-us/azure/
active-directory/develop/howto-create-service-principal-portal)
or via a script by executing the following az cli command (which we can launch in
Azure Cloud Shell).
The following is a template az cli script that you have to run to create an SP. Here, you
have to enter your SP name, role, and scope:
 
az ad sp create-for-rbac --name="SPForTerraform" --role="Contributor" --scopes="/subscriptions/8921-1444-..."

--scopes="/subscriptions/8921-1444-..." ### This is the subscription ID where the SP will be created. 
it is found under subscription in azure web page or you can use the following command to get the subscription ID after 
login to azure account using command line interface $ az login, then $ az account show