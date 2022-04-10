(terraform -chdir=.\01-keycloak-operator-setup\ init -input=false) ^
&& (terraform -chdir=.\01-keycloak-operator-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\01-keycloak-operator-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")
&& (terraform -chdir=.\02-keycloak-database-setup\ init -input=false) ^
&& (terraform -chdir=.\02-keycloak-database-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\02-keycloak-database-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")
&& (terraform -chdir=.\03-keycloak-instance-setup\ init -input=false) ^
&& (terraform -chdir=.\03-keycloak-instance-setup\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\03-keycloak-instance-setup\ apply -auto-approve -input=false -compact-warnings "output.tfplan")