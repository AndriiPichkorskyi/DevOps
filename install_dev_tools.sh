#!/bin/bash

# Функція для перевірки наявності команди в системі
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

echo "--- Початок автоматизації (режим venv) ---"

# 1. Встановлення Docker
if is_installed docker; then
    echo "[✓] Docker вже встановлено: $(docker --version)"
else
    echo "[!] Встановлення Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Додавання репозиторію
    printf "Types: deb\nURIs: https://download.docker.com/linux/ubuntu\nSuites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")\nComponents: stable\nSigned-By: /etc/apt/keyrings/docker.asc\n" | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
fi

# 2. Встановлення Docker Compose
if docker compose version >/dev/null 2>&1; then
    echo "[✓] Docker Compose вже встановлено."
else
    echo "[!] Встановлення Docker Compose..."
    sudo apt-get install -y docker-compose-plugin
fi

# 3. Встановлення Python (3.9+)
if is_installed python3; then
    PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    # Перевірка версії через awk
    IS_GE_39=$(echo "$PYTHON_VERSION" | awk '{if ($1 >= 3.9) print "true"; else print "false"}')
    
    if [ "$IS_GE_39" = "true" ]; then
        echo "[✓] Python $PYTHON_VERSION вже встановлено."
    else
        echo "[!] Оновлення Python..."
        sudo apt-get install -y python3
    fi
else
    echo "[!] Встановлення Python..."
    sudo apt-get update
    sudo apt-get install -y python3
fi

# 4. Створення venv та встановлення Django
echo "[!] Перевірка віртуального середовища..."

# Спочатку перевіряємо, чи взагалі є папка venv
if [ ! -d "venv" ]; then
    echo "[!] Папку venv не знайдено. Створюємо..."
    sudo apt-get install -y python3-venv python3-pip
    python3 -m venv venv
fi

# Тепер перевіряємо, чи встановлений Django ВСЕРЕДИНІ цього venv
if ./venv/bin/pip show django >/dev/null 2>&1; then
    echo "[✓] Django вже встановлено у venv: $(./venv/bin/django-admin --version)"
else
    echo "[!] Django не знайдено у venv. Встановлюємо..."
    ./venv/bin/pip install --upgrade pip
    ./venv/bin/pip install django
    echo "[✓] Django успішно додано у віртуальне середовище."
fi

# Перевірка результату
echo "--- Підсумок встановлення ---"
docker --version
docker compose version
python3 --version
./venv/bin/django-admin --version