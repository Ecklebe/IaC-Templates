(terraform -chdir=.\01-extending-kubernetes\ init) ^
&& (terraform -chdir=.\01-extending-kubernetes\ apply -auto-approve) ^
&& (terraform -chdir=.\02-setup\ init) ^
&& (terraform -chdir=.\02-setup\ apply -auto-approve)