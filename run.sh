#!/bin/sh

ansible-galaxy install -r requirements.yml
ansible-playbook -v -i inventory.yml playbook.yml
