(terraform -chdir=.\03-authelia\ init -input=false) ^
&& (terraform -chdir=.\03-authelia\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\03-authelia\ apply -auto-approve -input=false -compact-warnings "output.tfplan")