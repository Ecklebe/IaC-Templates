(terraform init -input=false) \
&& (terraform plan -destroy -var-file=terraform.tfvars -out=main.destroy.tfplan -input=false -compact-warnings) \
&& (terraform apply -auto-approve -input=false -compact-warnings "main.destroy.tfplan")