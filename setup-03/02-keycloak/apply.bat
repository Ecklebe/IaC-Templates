(terraform init -input=false) ^
&& (terraform plan -var-file=..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform  apply -auto-approve -input=false -compact-warnings "output.tfplan") ^