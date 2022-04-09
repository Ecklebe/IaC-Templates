(terraform -chdir=.\01-setup\ init -input=false) ^
&& (terraform -chdir=.\01-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\01-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")