import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "MessMind API"
    API_V1_STR: str = "/api/v1"
    DATABASE_URL: str = "postgresql+psycopg://postgres:1234@localhost:5432/messmind_db"
    SECRET_KEY: str = "messmind_secret_key_phase1_super_secure_2026_dev"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    ADMIN_EMAIL: str = "admin@messmind.com"
    ADMIN_PASSWORD: str = "AdminPassword123!"

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
