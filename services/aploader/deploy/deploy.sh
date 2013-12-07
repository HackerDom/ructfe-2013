#!/bin/bash

useradd -m aploader
mkdir /home/aploader/files
cp -r usr /
cp -r xinetd.d/ /etc/
chown -R aploader:aploader /home/aploader
