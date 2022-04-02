(terraform -chdir=.\01-extending-kubernetes\ init -input=false) ^
&& (terraform -chdir=.\01-extending-kubernetes\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\01-extending-kubernetes\ apply -auto-approve -input=false -compact-warnings "output.tfplan") ^
&& (terraform -chdir=.\02-setup\ init -input=false) ^
&& (terraform -chdir=.\02-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\02-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")