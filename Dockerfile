FROM python:3.11-slim

# Installer les dépendances système pour Chrome + Selenium
RUN apt-get update && apt-get install -y \
    curl fonts-liberation gnupg libappindicator1 libasound2 libfontconfig1 libgconf-2-4 \
    libglib2.0-0 libnss3 libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxi6 \
    libxrandr2 libxss1 libxtst6 unzip wget xdg-utils && \
    rm -rf /var/lib/apt/lists/*

# Installer Google Chrome
RUN wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && apt-get install -y /tmp/google-chrome.deb && \
    rm /tmp/google-chrome.deb && \
    rm -rf /var/lib/apt/lists/*

# Installer ChromeDriver version stable (138.0.7204.49)
ENV CHROME_DRIVER_VERSION=138.0.7204.49
RUN wget -q -O /tmp/chromedriver.zip \
    "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_DRIVER_VERSION}/linux64/chromedriver-linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /tmp/ && \
    mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -rf /tmp/chromedriver.zip /tmp/chromedriver-linux64

# Variables environnement pour Chrome headless
ENV CHROME_BIN=/usr/bin/google-chrome
ENV CHROMEDRIVER_BIN=/usr/local/bin/chromedriver

# Copier le code source
COPY app/ app/
COPY tests/ tests/
COPY web/ web/
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Important : dire à Python où trouver le module `app`
ENV PYTHONPATH=/

EXPOSE 8000

CMD ["uvicorn", "app.api:app", "--host", "0.0.0.0", "--port", "8000"]
