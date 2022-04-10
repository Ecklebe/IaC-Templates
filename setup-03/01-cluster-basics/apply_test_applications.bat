(terraform -chdir=.\04-test-applications\ init -input=false) ^
&& (terraform -chdir=.\04-test-applications\ plan -var-file=..\..\terraform.tfvars -out=output.tfplan -input=false -compact-warnings) ^
&& (terraform -chdir=.\04-test-applications\ apply -auto-approve -input=false -compact-warnings "output.tfplan")