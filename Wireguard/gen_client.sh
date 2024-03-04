#!/bin/bash

function gen-keys() {
    echo "[*] Création de la paire de clés publique/privée..."
    mkdir -p /tmp/gen-client
    umask 077
    wg genkey > /tmp/gen-client/privatekey
    wg pubkey < /tmp/gen-client/privatekey > /tmp/gen-client/publickey
}

function add-rule() {
    echo "[*] Ajout du nouveau peer avec l'IP : $(echo "$ip")..."
    wg set wg0 peer $(cat /tmp/gen-client/publickey) allowed-ips "$ip"/32
}

function gen-conf() {
    echo "[*] Création du fichier de configuration client..."
    conf_client=$(cat <<'END'
[Interface]
PrivateKey = REDACTED
Address = ip_client/8
DNS = DNS_LOCAL # A MODIFIER AVANT DE LANCER LE SCRIPT
MTU = 1420

[Peer]
PublicKey = pubkey_serveur
AllowedIPs = 0.0.0.0/0, 192.168.1.0/24, 10.0.0.0/8 # A MODIFIER SI BESOIN
Endpoint = IP_BOX:VOTRE_PORT_WG  # A MODIFIER AVANT DE LANCER LE SCRIPT
PersistentKeepalive = 1
END
    )
    conf_client=$(sed "s%ip_client%$ip%g" <<< "$conf_client")
    conf_client=$(sed "s%pubkey_serveur%$(wg show wg0 public-key)%g" <<< "$conf_client")
    conf_client=$(sed "s%REDACTED%$(cat /tmp/gen-client/privatekey)%g" <<< "$conf_client")
    printf "%s\n" "$conf_client" > /tmp/gen-client/wg.conf
}

function generate_qr() {
    qrencode -t ANSI < /tmp/gen-client/wg.conf
}

function save_and_delete() {
    read -p "[!] Comment voulez-vous appeler votre profil Wireguard ? : " nom
    echo "[*] Sauvegarde du fichier de configuration client dans le répertoire home..."
    file_name= $HOME/$nom
    mv /tmp/gen-client/wg.conf $file_name
    echo "[*] Fichier de configuration sauvegardé sous le nom : $file_name"
    echo "[*] Suppression des fichiers générés...."
    rm -rf /tmp/gen-client
    echo "[*] Tips : Pour générer le QRcode associé au fichier de configuration, on peut utiliser la commande suivante :"
    echo "qrencode -t ANSI < $file_name"
}

echo "[*] Utilitaire de création de configuration client Wireguard"
read -p "IP de votre client (10.0.0.X) : " ip
gen-keys
add-rule
gen-conf
generate_qr
save_and_delete
