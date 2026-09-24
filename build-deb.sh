#!/usr/bin/env bash
set -euo pipefail
project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
version=0.1.0
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
chmod 755 "$stage"
mkdir -p "$stage/DEBIAN" "$stage/usr/share/aic88m80-linux-br" "$stage/usr/share/applications" "$stage/usr/share/doc/aic88m80-linux-br"
cat > "$stage/DEBIAN/control" <<EOF
Package: aic88m80-linux-br
Version: $version
Section: net
Priority: optional
Architecture: all
Maintainer: aic88m80-linux-br contributors <noreply@users.noreply.github.com>
Depends: bash, sudo, git, ca-certificates, dkms, build-essential, usb-modeswitch, usbutils, bluez, mokutil, x-terminal-emulator
Homepage: https://github.com/Handerson-Henri/aic88m80-linux-br
Description: Assistente em portugues para adaptador AIC 88M80
 Instala um atalho para baixar e executar o driver comunitario AIC8800.
 Requer internet e autorizacao administrativa. Nao inclui driver ou firmware.
 Validado inicialmente no Zorin OS 18.1; consulte o README para limitacoes.
EOF
install -m 644 "$project_dir/instalar.sh" "$project_dir/diagnostico.sh" "$stage/usr/share/aic88m80-linux-br/"
install -m 755 "$project_dir/abrir.sh" "$stage/usr/share/aic88m80-linux-br/abrir.sh"
install -m 644 "$project_dir/README.md" "$stage/usr/share/doc/aic88m80-linux-br/README.md"
install -m 644 "$project_dir/LICENSE" "$stage/usr/share/doc/aic88m80-linux-br/copyright"
cat > "$stage/usr/share/applications/aic88m80-linux-br.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=AIC 88M80 — Instalar Wi-Fi e Bluetooth
Comment=Instalação assistida do driver AIC no Linux
Exec=/usr/share/aic88m80-linux-br/abrir.sh
Icon=network-wireless
Terminal=true
Categories=Settings;HardwareSettings;
Keywords=wifi;bluetooth;aic;88m80;driver;
EOF
mkdir -p "$project_dir/dist"
dpkg-deb --root-owner-group --build "$stage" "$project_dir/dist/aic88m80-linux-br_${version}_all.deb"
