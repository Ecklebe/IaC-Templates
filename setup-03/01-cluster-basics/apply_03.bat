(terraform -chdir=.\03-setup\ init -input=false) ^
&& (terraform -chdir=.\03-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\03-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")