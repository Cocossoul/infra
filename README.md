# WIFI Wake on LAN

My Raspi installation at home which can power on my gamer PC upon receiving a specific message on a MQTT queue.

## Use case

To power on their computer without touching to the physical power button, one can use the Wake on LAN capability of their computer's network card.
In short, you can configure your computer to power on upon receiving a specific packet on the port 9 of its ethernet interface. The packet mostly contains the target computer mac address.

In my case, I could not connect my computer to the box using an ethernet cable, but I really wanted to be able to power it on from afar.

I came up with a workaround, by wiring a Raspberry Pi to my computer by ethernet, the Raspberry Pi sending the Wake on LAN packet.

The Raspberry Pi listens on a MQTT queue (or other messaging services like RabbitMQ), and when receiving a specific message it sends the WOL (Wake on LAN) packet to the computer using the `etherwake` utility.

The MQTT queue can be hosted on the Raspi itself if you can open your ports (and don't mind), like I did here.

Once everything in place, you can use the `client.py` script to power on the computer from another computer.
There are Android apps that can send a message to a MQTT queue to power on the computer from your phone.
The MQTT topic is `wol/mqtt` and the message is `wake up`.

This Ansible playbook deploys the above solution.

## Requirements

- A Raspberry Pi on Raspbian with Python3 installed and SSH access configured
  (not password access, only PublicKey since the first part of this Ansible playbook will disable the first).
- Python3 and Ansible installed on the control node (the host).

## Configuration

- The `inventory.yml` file contains the list of machines that will be configured by Ansible upon deployment.
- Export the *MOSQUITTO_USER* and *MOSQUITTO_PASSWORD* variables in the environment.
- Export the *WAKER_PC_MAC_ADDR* variable in the environment, which is the mac address of the computer to wake up.

## Deployment

You can deploy it directly to the Raspberry Pi using Ansible.
The `run.sh` script contains the needed command to download everything Ansible needs and deploy.
