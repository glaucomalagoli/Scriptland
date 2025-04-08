#!/usr/bin/env zsh
# enable-touchid-sudo

set -euo pipefail
IFS=$'\n\t'

tput sgr0 # Reset terminal colors

### Utility Functions ###

function ctrl_c {
  echo -e "\n[❌] ${USER} interrompeu a execução."
  exit 1
}

### Core Functionality ###

function enable_sudo_touchid {
  local sudo_file="/etc/pam.d/sudo"
  local local_file="/etc/pam.d/sudo_local"
  local touchid_entry="auth       sufficient     pam_tid.so"

  # Aviso se estiver configurado diretamente em /etc/pam.d/sudo
  if grep -q 'pam_tid.so' "$sudo_file"; then
    logger -p user.warning -s \
      "TouchID no sudo configurado diretamente em $sudo_file NÃO persiste após atualizações. \
Consulte: https://support.apple.com/en-us/HT213893"
  fi

  # Verifica se já está configurado corretamente
  if [[ -e "$local_file" ]]; then
    if grep -q 'pam_tid.so' "$local_file"; then
      logger -p user.info -s "TouchID para sudo já está habilitado."
      return 0
    fi
  else
    # Solicita senha para criar o arquivo sudo_local
    sudo --validate --prompt="[⚠️ ] Digite sua senha para criar $local_file: "

    # Criação segura do arquivo
    if sudo install -m 444 -g wheel -o root /dev/null "$local_file"; then
      logger -p user.info -s "Arquivo $local_file criado com sucesso."
    else
      logger -p user.error -s "Erro ao criar $local_file."
      return 1
    fi
  fi

  # Adiciona entrada do TouchID
  if echo "$touchid_entry" | sudo tee "$local_file" > /dev/null; then
    logger -p user.info -s "TouchID para sudo habilitado com sucesso em $local_file."
    return 0
  else
    logger -p user.error -s "Falha ao configurar TouchID para sudo."
    return 1
  fi
}

### Main Entry Point ###

function main {
  trap ctrl_c SIGINT
  enable_sudo_touchid
}

main "$@"
