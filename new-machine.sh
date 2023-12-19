#!/bin/bash

## Fonctions : 

name() {
    
    read -p "Quel nom donner à la machine ? : " name

    if [ -z "$name" ]; then
        echo "Le nom de la machine ne peut pas être vide."
        name
    fi

    clear
    echo "[*] Modification des fichiers hosts et hostname..."
    echo "$name" > /etc/hostname
    sed -i "s/debian/$name/" /etc/hosts
    sleep 1

}

adressage() {

    read -p "Quelle IP pour la machine ? : " ip

    if ! [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "L'adresse IP n'est pas valide."
        adressage
    fi

    clear
    echo "[*] Changement d'adresse IP dans le fichier /etc/network/interfaces..."
    sed -i "s/192.168.1.250/$ip/" /etc/network/interfaces
    clear
    echo "IP renseignée : $(grep 'address' /etc/network/interfaces)"
    sleep 2
    clear 

}

echo "Utilitaire post-clonage"

name # Appelle la fonction pour renommer la machine
adressage # "" pour adresser la machine


echo "[!!] La machine va s'éteindre dans 10 secondes."
echo "====> Il faut penser à regénérer la carte réseau virtuelle en supprimant l'ancienne et en en refaisant une nouvelle depuis l'interface web de Proxmox."
sleep 10
shutdown now
