# Railway Ticket & Operation Management System - Installation Guide

This guide provides short instructions on how to install, configure, and run the database and the Django application.

---

## 🛠️ 1. Prerequisites & Installation

1. **Extract the Project:** Extract the project ZIP file and open your terminal/command prompt inside the root directory (`dbms proje`).
2. **Activate the Virtual Environment:**
   ```bash
   venv\Scripts\activate
Install Dependencies:

Bash
pip install django mysqlclient
⚙️ 2. Database Configuration
Open MySQL Workbench and ensure your MySQL server is running.

Import and execute your database schema and sample data scripts (e.g., schema.sql / data.sql) to set up the tables.

Open the project's settings.py file (located inside the main project configuration folder) and locate the DATABASES setting. Update it with your local MySQL password:

Python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'railway_db',       # Your MySQL database name
        'USER': 'root',             # Your MySQL username
        'PASSWORD': 'YOUR_PASSWORD', # Change this to your local MySQL password
        'HOST': '127.0.0.1',
        'PORT': '3306',
    }
}
🚀 3. Running the Application
Apply Django Migrations: (Run this in the terminal to sync the database state)

Bash
python manage.py migrate
Start the Development Server:

Bash
python manage.py runserver
## 🔗 4. Application Access & Credentials

* **Passenger Search Interface:** Open `http://127.0.0.1:8000/railway/search/` in your browser.
* **Staff / Admin Panel:** Click the green **"Go to Staff Panel"** button located on the top-right corner of the Search page.
  * **Username:** `staff`
  * **Password:** `1234`