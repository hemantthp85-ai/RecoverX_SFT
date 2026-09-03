import certifi
from pymongo import MongoClient

from app.core.config import settings


try:
    client = MongoClient(settings.MONGODB_URL, tlsCAFile=certifi.where())
except Exception:
    client = MongoClient(settings.MONGODB_URL)

database = client[settings.DATABASE_NAME]


def get_database():
    return database