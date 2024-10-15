#!/bin/bash

# Функция для отображения заголовка
show_header() {
  echo "▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒"
  echo "▒██████╗▒▒██████╗▒▒██████╗██╗▒▒██╗███████╗██████╗▒▒▒▒▒▒███████╗███████╗████████╗██╗▒▒▒██╗██████╗▒▒"
  echo "▒██╔══██╗██╔═══██╗██╔════╝██║▒██╔╝██╔════╝██╔══██╗▒▒▒▒▒██╔════╝██╔════╝╚══██╔══╝██║▒▒▒██║██╔══██╗▒"
  echo "▒██║▒▒██║██║▒▒▒██║██║▒▒▒▒▒█████╔╝▒█████╗▒▒██████╔╝▒▒▒▒▒███████╗█████╗▒▒▒▒▒██║▒▒▒██║▒▒▒██║██████╔╝▒"
  echo "▒██║▒▒██║██║▒▒▒██║██║▒▒▒▒▒██╔═██╗▒██╔══╝▒▒██╔══██╗▒▒▒▒▒╚════██║██╔══╝▒▒▒▒▒██║▒▒▒██║▒▒▒██║██╔═══╝▒▒"
  echo "▒██████╔╝╚██████╔╝╚██████╗██║▒▒██╗███████╗██║▒▒██║▒▒▒▒▒███████║███████╗▒▒▒██║▒▒▒╚██████╔╝██║▒▒▒▒▒▒"
  echo "▒╚═════╝▒▒╚═════╝▒▒╚═════╝╚═╝▒▒╚═╝╚══════╝╚═╝▒▒╚═╝▒▒▒▒▒╚══════╝╚══════╝▒▒▒╚═╝▒▒▒▒╚═════╝▒╚═╝▒▒▒▒▒▒"
  echo "▒▒ by morington ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒"
  echo
}

# Цвета для вывода
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
RESET='\e[0m'

# Функция для вывода сообщений и выполнения команд
log_step() {
  local message=$1
  local command=$2

  # Выводим сообщение с "идет выполнение" и очищаем строку
  printf "${YELLOW}%-60s${RESET}" "$message... "

  # Выполняем команду с подавлением вывода
  eval "$command"

  # Проверка успешности выполнения команды
  if [ $? -eq 0 ]; then
    printf "\r${YELLOW}%-50s\t${GREEN}ОК${RESET}\n" "$message..."
else
    printf "\r${YELLOW}%-50s\t${RED}Ошибка${RESET}\n" "$message..."
    exit 1
fi
}

# Показываем заголовок
show_header

# Запуск команды для каждого этапа
log_step "Обновляем список пакетов" "sudo apt-get update"
log_step "Устанавливаем пакеты для работы через HTTPS" "sudo apt-get install apt-transport-https ca-certificates curl software-properties-common"
log_step "Добавляем GPG-ключ репозитория Docker" "bash -c \"curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -\""
log_step "Добавляем репозиторий Docker в источники APT" 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"'
log_step "Обновляем список пакетов после добавления репозитория Docker" "sudo apt-get update"
log_step "Проверяем доступные версии Docker" "apt-cache policy docker-ce"
log_step "Устанавливаем Docker" "sudo apt-get install -y docker-ce"
log_step "Проверка статуса Docker" "sudo systemctl status docker --no-pager"

# Запрашиваем пользователя о добавлении в группу Docker
CURRENT_USER=$(whoami)
echo -ne "${YELLOW}"
read -p "Хотите добавить текущего пользователя ($CURRENT_USER) в группу Docker для запуска без sudo? (y/n): " add_user
echo -ne "${RESET}"

if [[ "$add_user" == "y" || "$add_user" == "Y" ]]; then
  log_step "Добавляем $CURRENT_USER в группу Docker" "sudo usermod -aG docker $CURRENT_USER"
  echo -e "${GREEN}Пользователь $CURRENT_USER добавлен в группу Docker. Для применения изменений, выйдите и снова войдите в систему.${RESET}"
else
  echo -e "${RED}Добавление в группу Docker пропущено.${RESET}"
fi

log_step "Установка Docker завершена" "echo"
echo
