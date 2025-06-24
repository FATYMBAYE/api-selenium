from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

def run_test():
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    driver = webdriver.Chrome(options=options)

    try:
        driver.get("http://localhost:8000")
        print("Page title:", driver.title)

        # Exemple de vérification : page chargée sans erreur
        assert "Calculatrice" in driver.page_source or driver.title != "", "La page ne contient pas le texte attendu"

        print("Selenium test passed")
    except Exception as e:
        print(" Selenium test failed:", str(e))
        raise
    finally:
        driver.quit()

if __name__ == "__main__":
    run_test()
