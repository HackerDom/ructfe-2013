#!/bin/bash -x

cd "$( dirname "${BASH_SOURCE[0]}" )"

pacman --noconfirm --needed -S core/openldap extra/apache

useradd -s /bin/false -M contacts
mkdir /home/contacts

cp -R home_deploy_contents/contacts/* /home/contacts/
chmod -R 770 /home/contacts
chown -R contacts:contacts /home/contacts

cp initscripts/contacts_apache.service initscripts/contacts_slapd.service /etc/systemd/system/
systemctl daemon-reload
systemctl start contacts_slapd

echo Waiting for slapd
sleep 5
cat <<EOF | ldapadd -H ldapi://%2Fhome%2Fcontacts%2Fldap%2Fsocket -w ctf -D "cn=Manager,dc=ructfe,dc=org"
dn: dc=ructfe,dc=org
objectClass: dcObject
objectClass: organization
dc: ructfe
o: ctforg
description: The ctf org

EOF

systemctl start contacts_apache
systemctl enable contacts_slapd contacts_slapd
