#!/usr/bin/env bash
# Execute pelo menu como usuário normal. sudo é usado pelo instalador.
cd /usr/share/aic88m80-linux-br || exit 1
printf '\nAIC 88M80 — instalação de Wi-Fi e Bluetooth\n\n'
printf '1) Instalar driver (internet e senha administrativa)\n2) Diagnóstico (somente leitura)\n0) Sair\n\n'
read -r -p 'Escolha: ' option
status=0
case "$option" in
  1) bash ./instalar.sh || status=$? ;;
  2) bash ./diagnostico.sh || status=$? ;;
  *) exit 0 ;;
esac
printf '\nOperação encerrada (código %s).\n' "$status"
read -r -p 'Pressione Enter para fechar. ' _
exit "$status"
