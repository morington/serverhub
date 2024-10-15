# serverhub

Рекомендация, перед выполнением любых скриптов использовать обновления системы:

**Ubuntu:**
```bash
sudo apt update && sudo apt dist-upgrade -y
```

**Debian:**
```bash
sudo apt update && sudo apt full-upgrade -y
```

**CentOS / RHEL:**
```bash
sudo yum update -y  # CentOS 7 и старше
```
```bash
sudo dnf upgrade -y # CentOS Stream, RHEL 8 и выше
```

**Fedora:**
```bash
sudo dnf upgrade --refresh -y
```

**Arch:**
```bash
sudo pacman -Syu --noconfirm
```

**OpenSUSE:**
```bash
sudo zypper refresh && sudo zypper update -y
```

**Alpine:**
```bash
sudo apk update && sudo apk upgrade
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
