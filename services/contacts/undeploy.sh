#!/bin/bash -x

systemctl stop contacts_apache contacts_slapd
rm /etc/systemd/system/contacts_apache.service /etc/systemd/system/contacts_slapd.service
systemctl daemon-reload

rm -r /home/contacts
userdel contacts
