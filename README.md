# AIC 88M80: Wi-Fi e Bluetooth no Linux 🇧🇷

Guia em português baseado em uma instalação com funcionamento de Wi-Fi e Bluetooth confirmado pelo usuário. Este projeto facilita a instalação do driver comunitário; não é o autor do driver nem um projeto oficial da AIC.

## Ambiente testado

| Item | Resultado observado |
|---|---|
| Sistema | Zorin OS 18.1, base Ubuntu 24.04 |
| Kernel | 7.0.0-31-generic, x86_64 |
| Adaptador | USB AIC 88M80, Wi-Fi + Bluetooth |
| USB inicial | `1111:1111` (armazenamento com instalador Windows) |
| Após troca de modo | `a69c:8d80` (AIC Wlan) |
| Após inicialização | `a69c:8d81`, interface Wi-Fi e controlador Bluetooth |
| Secure Boot | Desativado no computador testado |

Wi-Fi e Bluetooth foram testados pelo usuário. Reconexão após reiniciar, outros kernels e outras revisões do adaptador ainda não foram validados. Um ID USB igual não garante a mesma revisão interna.

## Antes de começar

Conecte o adaptador e mantenha acesso à internet por cabo ou compartilhamento USB do celular. O arquivo `Wifi6_install.exe` contém o instalador Windows e não instala o driver Linux.

Abra o Terminal e confira:

```bash
lsusb
```

Este guia destina-se ao dispositivo identificado acima. Para outros adaptadores, identifique o chipset antes de instalar.

## Pacote .deb (assistente)

[Baixe o pacote aic88m80-linux-br_0.1.0_all.deb](https://github.com/Handerson-Henri/aic88m80-linux-br/raw/refs/heads/main/aic88m80-linux-br_0.1.0_all.deb).

Abra o arquivo com o instalador de aplicativos do sistema. Se preferir o Terminal, na pasta do download:

```bash
sudo apt install ./aic88m80-linux-br_0.1.0_all.deb
```

Depois abra **AIC 88M80 — Instalar Wi-Fi e Bluetooth** no menu. Escolha **1**, confirme com `sim` e informe a senha quando solicitada. O terminal mostra o progresso. A opção **2** executa somente o diagnóstico.

O .deb instala o assistente. O download e a compilação do driver começam ao abrir o atalho; não ocorrem durante a instalação do pacote, para evitar conflito com o gerenciador de pacotes. Precisa de internet. Driver e firmware não estão incluídos. A senha é solicitada pelo sudo, não armazenada pelo assistente.

Remover o pacote com `sudo apt remove aic88m80-linux-br` remove apenas o assistente. O driver instalado pelo projeto original permanece; consulte o projeto original para removê-lo.

Para reconstruir o pacote a partir deste código:

```bash
bash build-deb.sh
```

O resultado fica em `dist/`. O pacote teve sua estrutura e seus scripts verificados, mas a instalação completa por este novo assistente ainda não foi testada. A instalação original do driver foi confirmada no ambiente descrito acima.

## Instalação assistida pelo código-fonte

Baixe este repositório e abra um Terminal na pasta extraída. Execute:

```bash
bash instalar.sh
```

O script mostra o que será feito e pede confirmação. Instala dependências pelo APT, baixa a revisão do driver usada no teste e executa o instalador original com sudo. O instalador original substitui arquivos de firmware AIC existentes e configura DKMS e regras de detecção USB; evite usá-lo sobre outra instalação AIC sem revisar a configuração anterior. Não reinicia o computador nem altera Secure Boot.

A versão do driver é fixada para tornar o procedimento reproduzível; isso não garante compatibilidade com futuros kernels. O script auxiliar foi validado quanto à sintaxe, mas não foi executado para reinstalar o sistema usado no teste.

## Se aparecer como armazenamento

O instalador do driver configura a troca automática de modo. Na instalação original, também foi usado este comando antes da instalação:

```bash
sudo usb_modeswitch -v 0x1111 -p 0x1111 -M "555342438765432100000000000010fd0000000000000000000000000000f3" -2 "555342438765432100000000000010fd0000000000000000000000000000f2"
```

Use apenas se `lsusb` mostrar `1111:1111`. A troca de modo, sozinha, não instala o driver.

## Como verificar

Aguarde alguns segundos após a instalação. Abra Configurações → Wi-Fi e conecte à rede; depois abra Configurações → Bluetooth e teste um pareamento.

```bash
bash diagnostico.sh
```

Uma mensagem inicial de “nenhum controlador Bluetooth” pode aparecer antes de o dispositivo terminar de inicializar. No caso testado, o controlador apareceu depois. Módulo carregado não comprova conexão funcionando: teste as duas funções.

Se não aparecer, retire e reconecte somente o adaptador Wi-Fi/Bluetooth e repita o diagnóstico. Se continuar sem funcionar, consulte o log local:

```bash
sudo journalctl -k -b --no-pager | grep -Ei 'aic|8800|bluetooth|firmware|timeout'
```

Revise logs antes de compartilhá-los: eles podem conter nomes do computador, endereços de dispositivos ou informações de rede. Não publique senhas.

Para problemas de firmware ou revisão MCU1, consulte as orientações do projeto original. Não troque de firmware às cegas. Secure Boot requer assinatura adequada dos módulos; este guia não orienta desativá-lo automaticamente.

## Créditos e versão

- [Driver comunitário de shenmintao](https://github.com/shenmintao/aic8800d80), baseado no driver Tenda, conforme documentação do autor.
- [Revisão utilizada](https://github.com/shenmintao/aic8800d80/tree/b72eea956451d6a351292cd6cd46b44b48e65b8d).
- [Documentação da troca de modo 88M80](https://github.com/ademasi/aic8800d80-wifi-bt-linux).

Este repositório não redistribui o driver nem seus firmwares. Seus termos pertencem aos respectivos autores. Os scripts auxiliares e o texto deste guia estão sob a licença MIT incluída.
