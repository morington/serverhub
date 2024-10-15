#!/bin/bash

# Функция для вывода текущей задачи в нижней строке и очистки предыдущей строки
log_step() {
  # Сохраняем текущую позицию курсора и переходим в последнюю строку
  tput sc
  tput cup $(tput lines) 0

  # Очищаем строку, заполняя её пробелами, затем возвращаем курсор в начало строки
  printf "%-$(tput cols)s" " "
  tput cup $(tput lines) 0

  # Выводим новое сообщение
  echo -e "====================================================="
  echo -ne "$1"

  # Возвращаем курсор на сохраненное место
  tput rc
}

# Обновляем список пакетов
log_step "Обновляем список пакетов..."
sudo apt-get update | tee >(log_step "Обновление списка пакетов завершено.")

# Устанавливаем пакеты для работы через HTTPS
log_step "Устанавливаем пакеты для работы через HTTPS..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common \
    | tee >(log_step "Установка пакетов для HTTPS завершена.")

# Добавляем GPG-ключ репозитория Docker
log_step "Добавляем GPG-ключ репозитория Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    | tee >(log_step "Добавление GPG-ключа завершено.")

# Добавляем репозиторий Docker в источники
log_step "Добавляем репозиторий Docker в источники APT..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
    | tee >(log_step "Репозиторий Docker добавлен.")

# Обновляем список пакетов с репозитория Docker
log_step "Обновляем список пакетов после добавления репозитория Docker..."
sudo apt-get update | tee >(log_step "Список пакетов обновлен.")

# Проверяем доступные версии Docker
log_step "Проверяем доступные версии Docker..."
apt-cache policy docker-ce | tee >(log_step "Проверка версий Docker завершена.")

# Устанавливаем Docker
log_step "Устанавливаем Docker..."
sudo apt-get install -y docker-ce | tee >(log_step "Установка Docker завершена.")

# Проверяем статус Docker
log_step "Проверка статуса Docker..."
sudo systemctl status docker --no-pager | tee >(log_step "Проверка статуса Docker завершена.")

# Спрашиваем пользователя о добавлении в группу Docker
CURRENT_USER=$(whoami)
echo
read -p "Хотите добавить текущего пользователя ($CURRENT_USER) в группу Docker для запуска без sudo? (y/n): " add_user
if [[ "$add_user" == "y" || "$add_user" == "Y" ]]; then
  sudo usermod -aG docker $CURRENT_USER
  echo "Пользователь $CURRENT_USER добавлен в группу Docker. Для применения изменений, выйдите и снова войдите в систему."
else
  echo "Добавление в группу Docker пропущено."
fi

log_step "Установка Docker завершена!"
echo
