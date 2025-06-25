FROM python:3.11-slim

# Installer les dépendances système pour Chrome + Selenium
RUN apt-get update && apt-get install -y \
    curl fonts-liberation gnupg libappindicator1 libasound2 libfontconfig1 libgconf-2-4 \
    libglib2.0-0 libnss3 libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxi6 \
    libxrandr2 libxss1 libxtst6 unzip wget xdg-utils && rm -rf /var/lib/apt/lists/*

# Installer Chrome
ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /tmp/google-chrome.deb
RUN apt-get update && apt-get install -y /tmp/google-chrome.deb && \
    rm /tmp/google-chrome.deb && rm -rf /var/lib/apt/lists/*

# Installer ChromeDriver (adapté à la version de Chrome)
RUN CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | cut -d. -f1) && \
    DRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION}") && \
    wget -q -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${DRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && chmod +x /usr/local/bin/chromedriver && rm /tmp/chromedriver.zip

# Variables environnement pour Chrome headless
ENV CHROME_BIN=/usr/bin/google-chrome
ENV CHROMEDRIVER_BIN=/usr/local/bin/chromedriver

# Copier le code source
COPY app/ app/
COPY tests/ tests/
COPY web/ web/
COPY requirements.txt .

# Installer les dépendances Python (selenium, uvicorn, fastapi etc.)
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

CMD ["uvicorn", "app.api:app", "--host", "0.0.0.0", "--port", "8000"]
