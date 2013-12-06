#!/bin/bash

useradd -m aploader
mkdir /home/aploader/files
cp -r usr /
cp -r xinetd.d/ /etc/
cp ../aploader.+ /home/aploader
cp ../run.sh /home/aploader
chown -R aploader:aploader /home/aploader
