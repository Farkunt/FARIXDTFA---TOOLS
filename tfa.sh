#!/bin/bash

# Tools: FARIXD - TFA (Text Forensic Analyzer)
# Version: 1.0
# Author: FARIXD
# Fungsi: Mendeteksi indikasi scamer dari teks/nomor/link

# Warna
R="\033[1;31m"
G="\033[1;32m"
Y="\033[1;33m"
B="\033[1;34m"
C="\033[1;36m"
P="\033[1;35m"
NC="\033[0m"

# Banner
banner() {
    clear
    echo -e "${C}"
    echo "╔═══════════════════════════════════════╗"
    echo "║     FARIXD - TFA v1.0                 ║"
    echo "║  Text Forensic Analyzer - Anti Scam   ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Database lokal
SCAM_NUMBERS=(
    "0888" "0899" "0857" "0812"  # contoh prefix
)

SCAM_KEYWORDS=(
    "menang" "hadiah" "undian" "transfer" "verifikasi"
    "pin bb" "m banking" "otp" "kode verifikasi"
    "dana" "gopay" "topup" "kirim pulsa"
)

# Cek nomor scam
check_number() {
    local number=$1
    echo -e "${Y}[*] Menganalisis nomor: $number${NC}"
    
    for scam in "${SCAM_NUMBERS[@]}"; do
        if [[ "$number" == *"$scam"* ]]; then
            echo -e "${R}[!] ⚠️  NOMOR TERINDIKASI SCAM!${NC}"
            echo -e "${Y}    Pola: $scam${NC}"
            return 1
        fi
    done
    echo -e "${G}[✓] Nomor aman sementara${NC}"
    return 0
}

# Cek teks/pesan scam
check_text() {
    local text=$1
    echo -e "${Y}[*] Menganalisis teks...${NC}"
    
    local found=()
    for keyword in "${SCAM_KEYWORDS[@]}"; do
        if echo "$text" | grep -qi "$keyword"; then
            found+=("$keyword")
        fi
    done
    
    if [ ${#found[@]} -gt 0 ]; then
        echo -e "${R}[!] ⚠️  TEKS TERINDIKASI SCAM!${NC}"
        echo -e "${Y}    Kata kunci mencurigakan:${NC}"
        for f in "${found[@]}"; do
            echo -e "    - $f"
        done
        return 1
    else
        echo -e "${G}[✓] Teks aman sementara${NC}"
        return 0
    fi
}

# Cek link scam
check_link() {
    local link=$1
    echo -e "${Y}[*] Menganalisis link: $link${NC}"
    
    # Domain mencurigakan
    if echo "$link" | grep -qE "(bit\.ly|tinyurl|short\.link|rb\.gy|shorte\.st)"; then
        echo -e "${R}[!] ⚠️  LINK SHORTENER MENURIGAKAN!${NC}"
        return 1
    fi
    
    if echo "$link" | grep -qiE "login|verify|secure|update|confirm"; then
        echo -e "${R}[!] ⚠️  LINK PHISHING TERINDIKASI!${NC}"
        return 1
    fi
    
    echo -e "${G}[✓] Link aman sementara${NC}"
    return 0
}

# Menu utama
menu() {
    banner
    echo -e "${B}[1]${NC} Cek Nomor Telepon"
    echo -e "${B}[2]${NC} Cek Teks/Pesan"
    echo -e "${B}[3]${NC} Cek Link"
    echo -e "${B}[4]${NC} Update Database (GitHub)"
    echo -e "${B}[0]${NC} Keluar"
    echo ""
    echo -ne "${P}➜ Pilih: ${NC}"
    read -r pilih
    
    case $pilih in
        1)
            echo -ne "${Y}Masukkan nomor: ${NC}"
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
            echo -e "${Y}[*] Menghubungi GitHub untuk update...${NC}"
            bash update.sh
            ;;
        0)
            echo -e "${G}Terima kasih! - FARIXD${NC}"
            exit 0
            ;;
        *)
            echo -e "${R}Pilihan salah!${NC}"
            sleep 1
            menu
            ;;
    esac
    
    echo ""
    echo -ne "${Y}Tekan Enter untuk kembali...${NC}"
    read
    menu
}

# Jalankan
menu
