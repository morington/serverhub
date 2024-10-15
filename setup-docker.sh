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

# Функция для вывода сообщений с анимацией выполнения
log_step() {
  local message=$1
  local command=$2
  local interactive=${3:-true} # Флаг для интерактивного режима (по умолчанию false)

  # Выводим сообщение с "идет выполнение" и очищаем строку
  printf "%-60s" "$message... "

  # Если команда интерактивная, выполняем ее с выводом на экран
  if [ "$interactive" = true ]; then
    $command
  else
    $command >/dev/null 2>&1
  fi

  # Проверка успешности выполнения команды
  if [ $? -eq 0 ]; then
    echo -e "\r$message...ОК"
  else
    echo -e "\r$message...Ошибка"
    exit 1
  fi
}

# Показываем заголовок
show_header

# Запуск команды для каждого этапа
log_step "Обновляем список пакетов" "sudo apt-get update"
log_step "Устанавливаем пакеты для работы через HTTPS" "sudo apt-get install apt-transport-https ca-certificates curl software-properties-common"
log_step "Добавляем GPG-ключ репозитория Docker" "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
log_step "Добавляем репозиторий Docker в источники APT" 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"'
log_step "Обновляем список пакетов после добавления репозитория Docker" "sudo apt-get update"
log_step "Проверяем доступные версии Docker" "apt-cache policy docker-ce"
log_step "Устанавливаем Docker" "sudo apt-get install -y docker-ce"
log_step "Проверка статуса Docker" "sudo systemctl status docker --no-pager"

# Спрашиваем пользователя о добавлении в группу Docker
CURRENT_USER=$(whoami)
echo
read -p "Хотите добавить текущего пользователя ($CURRENT_USER) в группу Docker для запуска без sudo? (y/n): " add_user
if [[ "$add_user" == "y" || "$add_user" == "Y" ]]; then
  log_step "Добавляем $CURRENT_USER в группу Docker" "sudo usermod -aG docker $CURRENT_USER"
  echo "Пользователь $CURRENT_USER добавлен в группу Docker. Для применения изменений, выйдите и снова войдите в систему."
else
  echo "Добавление в группу Docker пропущено."
fi

log_step "Установка Docker завершена" "echo"
echo
