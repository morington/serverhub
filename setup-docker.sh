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
  local interactive=${3:-false} # Флаг для интерактивных команд

  # Выводим сообщение с "идет выполнение" и очищаем строку
  printf "${YELLOW}%-60s${RESET}" "$message... "

  # Выполняем команду
   if [ "$interactive" = true ]; then
    echo
    eval "$command"
  else
    # Выполняем команду, подавляя её вывод
     output=$(eval "$command" 2>&1)
  fi

  # Проверка успешности выполнения команды
  if [ $? -eq 0 ]; then
    printf "\r${YELLOW}%-100s\t${GREEN}ОК${RESET}\n" "$message..."
else
    printf "\r${YELLOW}%-100s\t${RED}Ошибка${RESET}\n" "$message..."
    echo -e "${RED}$output"
    exit 1
fi
}

# Показываем заголовок
show_header

# Запуск команды для каждого этапа
log_step "Обновляем список пакетов" "sudo apt-get update"

if systemctl is-active --quiet ssh; then
    echo -e "${YELLOW}Docker уже установлен."
    exit 1
fi

log_step "Устанавливаем пакеты для работы через HTTPS" "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common"
log_step "Добавляем GPG-ключ репозитория Docker" "bash -c \"curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -\""
log_step "Добавляем репозиторий Docker в источники APT" 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"' true
log_step "Обновляем список пакетов после добавления репозитория Docker" "sudo apt-get update"

if apt-cache policy docker-ce | grep -q "Candidate:"; then
    echo -e "${YELLOW}Пакет docker-ce доступен в репозиториях."
else
    echo -e "${RED}Ошибка: ${YELLOW}Пакет `docker-ce` недоступен."
    exit 1
fi

log_step "Устанавливаем Docker" "sudo apt-get install -y docker-ce"

if systemctl is-active --quiet ssh; then
    echo -e "${YELLOW}Docker запущен."
else
    echo -e "${RED}Ошибка: ${YELLOW}Docker не запущен."
    exit 1
fi
echo

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
