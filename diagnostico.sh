#!/usr/bin/env bash
# Somente leitura. Não lista redes, endereços MAC ou nomes de dispositivos pareados.
set -u
printf 'Kernel: '; uname -r
printf '\nDispositivos USB AIC esperados:\n'
for dev in /sys/bus/usb/devices/*; do
  [[ -r "$dev/idVendor" && -r "$dev/idProduct" ]] || continue
  id="$(cat "$dev/idVendor"):$(cat "$dev/idProduct")"
  case "$id" in 1111:1111|a69c:8d80|a69c:8d81) printf '%s\n' "$id";; esac
done
printf '\nMódulos AIC/Bluetooth:\n'
lsmod | grep -E '^(aic|btusb)' || true
wifi=0
for dev in /sys/class/net/*; do [[ -d "$dev/wireless" ]] && wifi=$((wifi+1)); done
bt=0
for dev in /sys/class/bluetooth/hci*; do [[ -e "$dev" ]] && bt=$((bt+1)); done
printf '\nInterfaces Wi-Fi: %s\nControladores Bluetooth: %s\n' "$wifi" "$bt"
printf '\nDKMS:\n'
if command -v dkms >/dev/null; then dkms status; else echo 'DKMS não encontrado'; fi
printf '\nSecure Boot:\n'
if command -v mokutil >/dev/null; then mokutil --sb-state; else echo 'mokutil não encontrado'; fi
printf '\nDetecção não comprova conexão: teste Wi-Fi e um pareamento Bluetooth.\n'
