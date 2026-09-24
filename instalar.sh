#!/usr/bin/env bash
set -euo pipefail
readonly REV=b72eea956451d6a351292cd6cd46b44b48e65b8d
readonly REPO=https://github.com/shenmintao/aic8800d80.git
if (( EUID == 0 )); then
  echo 'Execute como usuário normal: bash instalar.sh (sudo será solicitado quando necessário).'
  exit 1
fi
command -v apt-get >/dev/null || { echo 'Este auxiliar requer um sistema com APT, como Zorin/Ubuntu.'; exit 1; }
found=false
for dev in /sys/bus/usb/devices/*; do
  [[ -r "$dev/idVendor" && -r "$dev/idProduct" ]] || continue
  id="$(cat "$dev/idVendor"):$(cat "$dev/idProduct")"
  case "$id" in 1111:1111|a69c:8d80|a69c:8d81) found=true;; esac
done
$found || { echo 'Adaptador esperado não detectado. Conecte o AIC 88M80 antes de continuar.'; exit 1; }
if command -v mokutil >/dev/null && mokutil --sb-state 2>/dev/null | grep -qi 'SecureBoot enabled'; then
  echo 'Secure Boot está ativo. Configure assinatura dos módulos antes de usar este guia.'
  exit 1
fi
printf '%s\n' 'Será instalado o driver comunitário AIC8800 via DKMS, com firmware e regras USB.'   'O instalador original substitui firmware AIC existente. Requer internet e sudo.'   "Revisão: $REV" 'O computador não será reiniciado automaticamente.'
read -r -p 'Continuar? Digite sim: ' answer
[[ "$answer" == sim ]] || { echo 'Cancelado, sem alterações.'; exit 0; }
sudo apt-get update
sudo apt-get install -y git dkms build-essential "linux-headers-$(uname -r)" usb-modeswitch usbutils bluez mokutil
if mokutil --sb-state 2>/dev/null | grep -qi 'SecureBoot enabled'; then
  echo 'Secure Boot ativo: instalação do driver interrompida; configure assinatura dos módulos.'
  exit 1
fi
source_dir=$(mktemp -d "${TMPDIR:-/tmp}/aic88m80-source.XXXXXXXX")
printf 'Código original será mantido em: %s\n' "$source_dir"
git -C "$source_dir" init -q
git -C "$source_dir" remote add origin "$REPO"
git -C "$source_dir" fetch --depth=1 origin "$REV"
git -C "$source_dir" checkout --detach FETCH_HEAD
[[ "$(git -C "$source_dir" rev-parse HEAD)" == "$REV" ]] || exit 1
if ! sudo bash "$source_dir/install.sh"; then
  echo 'O instalador retornou erro. Não considere a instalação concluída.'
  echo 'Confira /tmp/aic8800d80_install.log e execute bash diagnostico.sh.'
  exit 1
fi
echo 'Instalador concluído. Aguarde alguns segundos e teste Wi-Fi e Bluetooth nas Configurações.'
echo 'Para conferir os dispositivos: bash diagnostico.sh'
