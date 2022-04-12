(terraform -chdir=.\01-install-operator-lifecycle-manager\ init -input=false) ^
&& (terraform -chdir=.\01-install-operator-lifecycle-manager\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\01-install-operator-lifecycle-manager\ apply -auto-approve -input=false -compact-warnings "output.tfplan")