#!/bin/bash
clear
echo "Install FARIXD - TFA"
pkg update -y
pkg install git curl grep -y
git clone https://github.com/usernamekamu/FARIXD-TFA
cd FARIXD-TFA
chmod +x tfa.sh update.sh
echo "Instalasi selesai!"
echo "Jalankan: ./tfa.sh"
