(terraform -chdir=.\01-install-operator-lifecycle-manager\ init -input=false) ^
&& (terraform -chdir=.\01-install-operator-lifecycle-manager\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\01-install-operator-lifecycle-manager\ apply -auto-approve -input=false -compact-warnings "output.tfplan") ^
&& (terraform -chdir=.\02-extending-kubernetes\ init -input=false) ^
&& (terraform -chdir=.\02-extending-kubernetes\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\02-extending-kubernetes\ apply -auto-approve -input=false -compact-warnings "output.tfplan") ^
&& (terraform -chdir=.\03-setup\ init -input=false) ^
&& (terraform -chdir=.\03-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\03-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")