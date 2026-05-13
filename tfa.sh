#!/bin/bash

# Tools: FARIXD - TFA (Text Forensic Analyzer)
# Version: 1.0
# Author: FARIXD

R="\033[1;31m"
G="\033[1;32m"
Y="\033[1;33m"
B="\033[1;34m"
C="\033[1;36m"
P="\033[1;35m"
NC="\033[0m"

banner() {
    clear
    echo -e "${C}"
    echo "╔══════════════════════════════════════════╗"
    echo "║      FARIXD - TFA v1.0                   ║"
    echo "║   Text Forensic Analyzer - Anti Scam     ║"
    echo "╠══════════════════════════════════════════╣"
    echo "║  [•] Deteksi Nomor Scam                  ║"
    echo "║  [•] Deteksi Teks Scam                   ║"
    echo "║  [•] Deteksi Link Phishing               ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Database embedded
check_number() {
    local num=$1
    echo -e "${Y}[*] Scanning nomor: $num${NC}"
    
    # Pola nomor scam Indonesia
    if [[ ${#num} -eq 11 ]] || [[ ${#num} -eq 12 ]]; then
        case $num in
            0881*|0882*|0883*|0888*|0895*|0896*|0897*|0898*|0899*)
                echo -e "${R}⚠️  TERINDIKASI SCAM! (Nomor premium/call center palsu)${NC}"
                return 1
                ;;
            0857*|0858*|0859*|0812*|0813*)
                echo -e "${Y}⚠️  NOMOR BERISIKO TINGGI (sering dipakai scam)${NC}"
                return 1
                ;;
            *)
                echo -e "${G}✓ Nomor aman sementara${NC}"
                return 0
                ;;
        esac
    else
        echo -e "${R}⚠️ Format nomor tidak valid!${NC}"
        return 1
    fi
}

# Database kata scam embedded
check_text() {
    local txt=$1
    echo -e "${Y}[*] Scanning teks...${NC}"
    
    local found=0
    local keywords=(
        "menang" "hadiah" "undian" "transfer" "verifikasi"
        "pin bb" "m banking" "otp" "kode verifikasi" "dana"
        "gopay" "topup" "kirim pulsa" "klik link" "login"
        "update data" "konfirmasi" "segera" "batas waktu"
        "bank indonesia" "pertamina" "pln" "bri" "bca" "mandiri"
    )
    
    for kw in "${keywords[@]}"; do
        if echo "$txt" | grep -qi "$kw"; then
            echo -e "${R}⚠️  Kata kunci scam: $kw${NC}"
            found=1
        fi
    done
    
    # Cek pola nomor rekening/pulsa
    if echo "$txt" | grep -qE "[0-9]{10,15}"; then
        echo -e "${R}⚠️  Terdeteksi nomor rekening/pulsa!${NC}"
        found=1
    fi
    
    if [[ $found -eq 1 ]]; then
        echo -e "${R}[!] TEKS TERINDIKASI SCAM!${NC}"
        return 1
    else
        echo -e "${G}✓ Teks aman sementara${NC}"
        return 0
    fi
}

# Database link scam embedded
check_link() {
    local link=$1
    echo -e "${Y}[*] Scanning link: $link${NC}"
    
    local found=0
    
    # Shortener mencurigakan
    if echo "$link" | grep -qE "(bit\.ly|tinyurl|shortlink|rb\.gy|shorte\.st|cut\.ly|ow\.ly|is\.gd|cli\.gs)"; then
        echo -e "${R}⚠️  LINK SHORTENER TANPA PREVIEW!${NC}"
        found=1
    fi
    
    # Domain phishing umum
    if echo "$link" | grep -qiE "(login|verify|secure|update|confirm|account|signin|webmail)"; then
        echo -e "${R}⚠️  DOMAIN PHISHING TERINDIKASI!${NC}"
        found=1
    fi
    
    # Cek link palsu bank/e-commerce
    if echo "$link" | grep -qiE "(bca|bri|mandiri|bni|dana|gopay|shopeepay)"; then
        echo -e "${R}⚠️  LINK MENGATASNAMAKAN BANK/ECOMMERCE!${NC}"
        found=1
    fi
    
    if [[ $found -eq 1 ]]; then
        echo -e "${R}[!] LINK TERINDIKASI PHISHING/SCAM!${NC}"
        return 1
    else
        echo -e "${G}✓ Link aman sementara${NC}"
        return 0
    fi
}

menu() {
    banner
    echo -e "${B}┌──────────────────────────────────────┐${NC}"
    echo -e "${B}│${NC}  ${G}[1]${NC} Cek Nomor Telepon               ${B}│${NC}"
    echo -e "${B}│${NC}  ${G}[2]${NC} Cek Teks/Pesan                  ${B}│${NC}"
    echo -e "${B}│${NC}  ${G}[3]${NC} Cek Link                        ${B}│${NC}"
    echo -e "${B}│${NC}  ${G}[4]${NC} Update Tools (GitHub)           ${B}│${NC}"
    echo -e "${B}│${NC}  ${R}[0]${NC} Keluar                          ${B}│${NC}"
    echo -e "${B}└──────────────────────────────────────┘${NC}"
    echo ""
    echo -ne "${P}➜ Pilih: ${NC}"
    read pilih
    
    case $pilih in
        1)
            echo -ne "${Y}Masukkan nomor (contoh: 08123456789): ${NC}"
            read nomor
            check_number "$nomor"
            ;;
        2)
            echo -ne "${Y}Masukkan teks/pesan: ${NC}"
            read teks
            check_text "$teks"
            ;;
        3)
            echo -ne "${Y}Masukkan link: ${NC}"
            read link
            check_link "$link"
            ;;
        4)
            echo -e "${Y}[*] Update dari GitHub...${NC}"
            curl -s -o tfa.sh "https://raw.githubusercontent.com/FARIXD/FARIXD-TFA/main/tfa.sh"
            chmod +x tfa.sh
            echo -e "${G}[✓] Update selesai! Jalankan ulang tools.${NC}"
            exit 0
            ;;
        0)
            echo -e "${G}Thanks for using FARIXD - TFA${NC}"
            exit 0
            ;;
        *)
            echo -e "${R}Pilihan salah!${NC}"
            sleep 1
            menu
            ;;
    esac
    
    echo ""
    echo -ne "${Y}Tekan Enter untuk lanjut...${NC}"
    read
    menu
}

# Jalankan
menu
