(terraform -chdir=.\01-operator-setup\ init -input=false) ^
&& (terraform -chdir=.\01-operator-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\01-operator-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")
&& (terraform -chdir=.\02-database-setup\ init -input=false) ^
&& (terraform -chdir=.\02-database-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\02-database-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")
&& (terraform -chdir=.\03-instance-setup\ init -input=false) ^
&& (terraform -chdir=.\03-instance-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\03-instance-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")