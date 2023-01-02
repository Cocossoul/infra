#!/bin/sh
while true ; do
    python3 /home/pi/waker.py 'localhost' "{{ lookup('ansible.builtin.env', 'WAKER_PC_MAC_ADDR') }}" "{{ lookup('ansible.builtin.env', 'MOSQUITTO_USER', default='admin') }}" "{{ lookup('ansible.builtin.env', 'MOSQUITTO_PASSWORD', default='admin') }}"
done
