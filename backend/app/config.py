import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'vous_ne_devriez_pas_utiliser_cela_en_production'
    DB_HOST = 'localhost'
    DB_USER = 'root'
    DB_PASSWORD = ''
    DB_NAME = 'chretien'
