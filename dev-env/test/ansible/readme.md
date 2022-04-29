# Test ansible installation

Run the command:

``ansible-playbook testbook.yml --connection=local -i inventory.ini``

The output should be similar to:

````shell
root@f4f129cb3128:/workspace/dev-env/test/ansible# ansible-playbook testbook.yml --connection=local -i inventory.ini

PLAY [testing ansible] *********************************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************************************
ok: [localhost]

TASK [Echo inventory hostname] *************************************************************************************************************************
ok: [localhost] => {
    "msg": "System host name is: localhost"
}

PLAY RECAP *********************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
````