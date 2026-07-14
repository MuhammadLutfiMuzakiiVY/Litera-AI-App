from functools import lru_cache
from os import getenv

from pydantic import BaseModel


class Settings(BaseModel):
    app_name: str = "LITERA-AI"
    environment: str = getenv("APP_ENV", "development")
    api_base_path: str = "/v1"
    jwt_secret: str = getenv("JWT_SECRET", "development-only-secret")
    jwt_algorithm: str = "HS256"
    access_token_minutes: int = int(getenv("ACCESS_TOKEN_MINUTES", "15"))
    refresh_token_days: int = int(getenv("REFRESH_TOKEN_DAYS", "14"))
    postgres_dsn: str = getenv(
        "POSTGRES_DSN",
        "postgresql+psycopg://litera:litera@localhost:5432/litera_ai",
    )
    redis_url: str = getenv("REDIS_URL", "redis://localhost:6379/0")
    cors_origins: list[str] = ["*"]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()

