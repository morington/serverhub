#!/bin/bash

# Цвета для вывода
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
RESET='\e[0m'
CURRENT_USER=$(whoami)

# Функция для отображения заголовка
show_header() {
  echo -e "${YELLOW}▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒"
  echo -e "${YELLOW}▒██████╗▒▒██████╗▒▒██████╗██╗▒▒██╗███████╗██████╗▒▒▒▒▒▒███████╗███████╗████████╗██╗▒▒▒██╗██████╗▒▒"
  echo -e "${YELLOW}▒██╔══██╗██╔═══██╗██╔════╝██║▒██╔╝██╔════╝██╔══██╗▒▒▒▒▒██╔════╝██╔════╝╚══██╔══╝██║▒▒▒██║██╔══██╗▒"
  echo -e "${YELLOW}▒██║▒▒██║██║▒▒▒██║██║▒▒▒▒▒█████╔╝▒█████╗▒▒██████╔╝▒▒▒▒▒███████╗█████╗▒▒▒▒▒██║▒▒▒██║▒▒▒██║██████╔╝▒"
  echo -e "${YELLOW}▒██║▒▒██║██║▒▒▒██║██║▒▒▒▒▒██╔═██╗▒██╔══╝▒▒██╔══██╗▒▒▒▒▒╚════██║██╔══╝▒▒▒▒▒██║▒▒▒██║▒▒▒██║██╔═══╝▒▒"
  echo -e "${YELLOW}▒██████╔╝╚██████╔╝╚██████╗██║▒▒██╗███████╗██║▒▒██║▒▒▒▒▒███████║███████╗▒▒▒██║▒▒▒╚██████╔╝██║▒▒▒▒▒▒"
  echo -e "${YELLOW}▒╚═════╝▒▒╚═════╝▒▒╚═════╝╚═╝▒▒╚═╝╚══════╝╚═╝▒▒╚═╝▒▒▒▒▒╚══════╝╚══════╝▒▒▒╚═╝▒▒▒▒╚═════╝▒╚═╝▒▒▒▒▒▒"
  echo -e "${YELLOW}▒▒ ${RESET}by morington${YELLOW} ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ v1.0.2 (15.10.2024) ▒▒▒▒▒"
  echo
}

# Функция для вывода сообщений и выполнения команд
log_step() {
  local message=$1
  local command=$2
  local interactive=${3:-false} # Флаг для интерактивных команд

  # Выводим сообщение с "идет выполнение" и очищаем строку
  echo -en "${YELLOW}${message}... ${RESET}"

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
    echo -e "${GREEN}ОК${RESET}"
  else
    echo -e "${RED}Ошибка${RESET}"
    echo -e "${RED}$output${RESET}"
    exit 1
  fi
}

# Показываем заголовок
show_header

# Запуск команды для каждого этапа
log_step "Обновляем список пакетов" "sudo apt-get update"

if systemctl is-active --quiet docker; then
    echo -e "${YELLOW}Docker уже установлен."
    exit 1
fi

log_step "Устанавливаем пакеты для работы через HTTPS" "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common"
log_step "Добавляем GPG-ключ репозитория Docker" "bash -c \"curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -\""
log_step "Добавляем репозиторий Docker в источники APT" 'sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"'
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
echo -ne "${YELLOW}"

# Используем цикл для проверки корректности ввода
while true; do
  read -r -p "Хотите добавить текущего пользователя ($CURRENT_USER) в группу Docker для запуска команд без sudo? (y/n): " add_user

  # Удаляем лишние пробелы
  add_user=$(echo "$add_user" | tr -d '[:space:]')

  # Проверяем ответ
  if [[ "$add_user" == "y" || "$add_user" == "Y" ]]; then
    # Добавляем пользователя в группу docker
    sudo usermod -aG docker "$CURRENT_USER"
    echo -e "${GREEN}Пользователь $CURRENT_USER добавлен в группу Docker."
    echo -e "${YELLOW}Необходимо перелогинить пользователя."

    break
  elif [[ "$add_user" == "n" || "$add_user" == "N" ]]; then
    echo -e "${YELLOW}Добавление пользователя в группу Docker пропущено."
    break
  else
    echo -e "${RED}Ошибка: ${YELLOW}Введите 'y' или 'n'."
  fi
done

echo -ne "${RESET}"

echo
echo -e "${GREEN}Установка Docker завершена"
echo
