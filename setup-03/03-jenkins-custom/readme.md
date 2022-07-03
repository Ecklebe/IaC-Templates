# Custom Jenkins

This folder takes care of a custom jenkins setup.

## Prerequisites:

Create the folder that you defined for the parameter "jenkins_persistent_volume_host_path". This will be done otherwise
also by Terraform, but then the access rights are not in the way that the Jenkins installation wizard can use the
directory.

## Setup

After applying terraform the Jenkins should be reachable with the following link:

- http://jenkins.cluster.local

For the login you can use the following two ways:

1. The default admin account. Check (1) how to use this account.
2. or the test account
    - Username: test
    - Password: test

(1) https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins 