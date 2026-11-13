import os
from dotenv import load_dotenv
from typing import Optional

load_dotenv()

class Config:
    """Configuration management for Chimpi AI"""
    
    # API Keys
    openai_api_key: Optional[str] = os.getenv("OPENAI_API_KEY")
    google_api_key: Optional[str] = os.getenv("GOOGLE_API_KEY")
    github_token: Optional[str] = os.getenv("GITHUB_TOKEN")
    
    # Search APIs
    google_search_api_key: Optional[str] = os.getenv("GOOGLE_SEARCH_API_KEY")
    google_search_engine_id: Optional[str] = os.getenv("GOOGLE_SEARCH_ENGINE_ID")
    bing_search_api_key: Optional[str] = os.getenv("BING_SEARCH_API_KEY")
    
    # Social Media APIs
    twitter_bearer_token: Optional[str] = os.getenv("TWITTER_BEARER_TOKEN")
    twitter_api_key: Optional[str] = os.getenv("TWITTER_API_KEY")
    twitter_api_secret: Optional[str] = os.getenv("TWITTER_API_SECRET")
    twitter_access_token: Optional[str] = os.getenv("TWITTER_ACCESS_TOKEN")
    twitter_access_token_secret: Optional[str] = os.getenv("TWITTER_ACCESS_TOKEN_SECRET")
    
    reddit_client_id: Optional[str] = os.getenv("REDDIT_CLIENT_ID")
    reddit_client_secret: Optional[str] = os.getenv("REDDIT_CLIENT_SECRET")
    reddit_user_agent: str = os.getenv("REDDIT_USER_AGENT", "Chimpi_AI_Bot")
    
    facebook_access_token: Optional[str] = os.getenv("FACEBOOK_ACCESS_TOKEN")
    instagram_access_token: Optional[str] = os.getenv("INSTAGRAM_ACCESS_TOKEN")
    
    discord_bot_token: Optional[str] = os.getenv("DISCORD_BOT_TOKEN")
    telegram_bot_token: Optional[str] = os.getenv("TELEGRAM_BOT_TOKEN")
    
    # Database
    database_url: str = os.getenv("DATABASE_URL", "sqlite:///chimpi_ai.db")
    
    # Application
    app_host: str = os.getenv("APP_HOST", "localhost")
    app_port: int = int(os.getenv("APP_PORT", "8000"))
    debug: bool = os.getenv("DEBUG", "True").lower() == "true"
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    
    # Search Configuration
    max_search_results: int = int(os.getenv("MAX_SEARCH_RESULTS", "10"))
    search_timeout: int = int(os.getenv("SEARCH_TIMEOUT", "30"))
    enable_web_scraping: bool = os.getenv("ENABLE_WEB_SCRAPING", "True").lower() == "true"
    enable_social_media: bool = os.getenv("ENABLE_SOCIAL_MEDIA", "True").lower() == "true"
    
    # AI Model Configuration
    default_ai_model: str = os.getenv("DEFAULT_AI_MODEL", "gpt-3.5-turbo")
    temperature: float = float(os.getenv("TEMPERATURE", "0.7"))
    max_tokens: int = int(os.getenv("MAX_TOKENS", "1500"))

# Global config instance
config = Config()