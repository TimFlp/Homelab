#!/bin/bash

# Suppression anciens certificats (changer site.fr par votre domaine)
rm -r /etc/ssl/certifs/live/site.fr
rm -r /etc/ssl/certifs/archive/site.fr

# Generation des certificats SSL (changer fournisseur par le votre : gandhi,infomaniak...)
sudo certbot certonly --authenticator dns-fournisseur --dns-fournisseur-credentials /root/certbot/certbot-yay.ini --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -m "votremail@site.fr" --rsa-key-size 4096 -d '*.site.fr' --config-dir /etc/ssl/certifs --work-dir /etc/ssl/certifs --logs-dir /etc/ssl/certifs --force-renewal

# Mise des bons droits
chmod -R 600 /etc/ssl/certifs/archive/site.fr

# Generation certificat pour Jellyfin
openssl pkcs12 -inkey /etc/ssl/certifs/archive/site.fr/privkey1.pem -in /etc/ssl/certifs/archive/site.fr/cert1.pem -keypbe NONE -certpbe NONE -passout pass: -export -out /etc/ssl/certifs/archive/site.fr/bundle.pkcs12

# Generation certificat pihole
sudo cat /etc/ssl/certifs/archive/site.fr/privkey1.pem /etc/ssl/certifs/archive/site.fr/cert1.pem | sudo tee /etc/ssl/certifs/archive/site.fr/combined.pem && chown www-data /etc/ssl/certifs/archive/site.fr/combined.pem
# Lancement du playbook Ansible
ansible-playbook -i /root/Ansible/inventaire.ini /root/Ansible/playbook/cert.yml
