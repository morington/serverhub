# serverhub

## Рекомендация

### Все скрипты написаны и протестированы для Ubuntu.

Перед выполнением любых скриптов использовать обновления системы:

```bash
sudo apt update && sudo apt dist-upgrade -y
```

Проверить на `root` учетной записи, что у пользователя есть доступ к группе `sudo`

```bash
sudo usermod -a -G sudo <username>
```

# SETUP DOCKER

Установка docker в чистую систему, с возможностью добавить пользователя в группу `docker`

```bash
curl -H 'Cache-Control: no-cache' -sL https://raw.githubusercontent.com/morington/serverhub/main/setup-docker.sh -o setup-docker.sh && chmod +x setup-docker.sh && ./setup-docker.sh
```

Для вывода всех логов выполнения команд, в скрипте нужно изменить строку:
```sh
local interactive=${3:-false} # Флаг для интерактивных команд
```
Где default значение `-false` изменить на `-true`.
