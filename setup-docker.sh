#!/bin/bash

# Функция для вывода текущей задачи в нижней строке
log_step() {
  # Очищаем последнюю строку и выводим туда сообщение
  tput sc               # Сохраняем текущую позицию курсора
  tput cup $(tput lines) 0  # Переходим на последнюю строку
  echo -ne "$1"          # Выводим сообщение
  tput rc               # Возвращаемся на сохраненную позицию
}

# Обновляем список пакетов
log_step "Обновляем список пакетов..."
sudo apt update | tee >(log_step "Обновление списка пакетов завершено.")  # Используем tee для отображения действий в реальном времени

# Устанавливаем пакеты для работы apt через HTTPS
log_step "Устанавливаем пакеты для работы через HTTPS..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common \
    | tee >(log_step "Установка пакетов для HTTPS завершена.")

# Добавляем GPG-ключ репозитория Docker
log_step "Добавляем GPG-ключ репозитория Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
    | tee >(log_step "Добавление GPG-ключа завершено.")

# Добавляем репозиторий Docker в источники
log_step "Добавляем репозиторий Docker в источники APT..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee >(log_step "Репозиторий Docker добавлен.")

# Обновляем список пакетов с репозитория Docker
log_step "Обновляем список пакетов после добавления репозитория Docker..."
sudo apt update | tee >(log_step "Список пакетов обновлен.")

# Проверяем доступные версии Docker
log_step "Проверяем доступные версии Docker..."
apt-cache policy docker-ce | tee >(log_step "Проверка версий Docker завершена.")

# Устанавливаем Docker
log_step "Устанавливаем Docker..."
sudo apt install -y docker-ce | tee >(log_step "Установка Docker завершена.")

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
