#!/bin/bash

# Функция для отображения заголовка
show_header() {
  echo "====================================================="
  echo "▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒"
  echo "▒██████╗▒▒██████╗▒▒██████╗██╗▒▒██╗███████╗██████╗▒▒▒▒▒▒███████╗███████╗████████╗██╗▒▒▒██╗██████╗▒▒"
  echo "▒██╔══██╗██╔═══██╗██╔════╝██║▒██╔╝██╔════╝██╔══██╗▒▒▒▒▒██╔════╝██╔════╝╚══██╔══╝██║▒▒▒██║██╔══██╗▒"
  echo "▒██║▒▒██║██║▒▒▒██║██║▒▒▒▒▒█████╔╝▒█████╗▒▒██████╔╝▒▒▒▒▒███████╗█████╗▒▒▒▒▒██║▒▒▒██║▒▒▒██║██████╔╝▒"
  echo "▒██║▒▒██║██║▒▒▒██║██║▒▒▒▒▒██╔═██╗▒██╔══╝▒▒██╔══██╗▒▒▒▒▒╚════██║██╔══╝▒▒▒▒▒██║▒▒▒██║▒▒▒██║██╔═══╝▒▒"
  echo "▒██████╔╝╚██████╔╝╚██████╗██║▒▒██╗███████╗██║▒▒██║▒▒▒▒▒███████║███████╗▒▒▒██║▒▒▒╚██████╔╝██║▒▒▒▒▒▒"
  echo "▒╚═════╝▒▒╚═════╝▒▒╚═════╝╚═╝▒▒╚═╝╚══════╝╚═╝▒▒╚═╝▒▒▒▒▒╚══════╝╚══════╝▒▒▒╚═╝▒▒▒▒╚═════╝▒╚═╝▒▒▒▒▒▒"
  echo "▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒"
  echo
}

# Функция для вывода сообщений с анимацией выполнения
log_step() {
  # Выводим сообщение с "идет выполнение"
  echo -ne "$1... (идет выполнение)"

  # Запускаем команду в фоновом режиме
  $2 >/dev/null 2>&1

  # После выполнения выводим "ОК"
  echo -e "\r$1...ОК"
}

# Показываем заголовок
show_header

# Запуск команды для каждого этапа
log_step "Обновляем список пакетов" "sudo apt-get update"
log_step "Устанавливаем пакеты для работы через HTTPS" "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common"
log_step "Добавляем GPG-ключ репозитория Docker" "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"
log_step "Добавляем репозиторий Docker в источники APT" "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
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
