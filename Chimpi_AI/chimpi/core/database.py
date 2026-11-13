from sqlalchemy import create_engine, Column, Integer, String, Text, DateTime, Boolean, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime
from .config import config

Base = declarative_base()

class SearchQuery(Base):
    """Model for storing search queries and results"""
    __tablename__ = "search_queries"
    
    id = Column(Integer, primary_key=True, index=True)
    query = Column(String(500), nullable=False)
    source = Column(String(50), nullable=False)  # google, bing, twitter, etc.
    response = Column(Text, nullable=True)
    confidence_score = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)
    response_time = Column(Float, nullable=True)  # in seconds

class UserSession(Base):
    """Model for tracking user sessions"""
    __tablename__ = "user_sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String(100), unique=True, nullable=False)
    user_id = Column(String(100), nullable=True)
    platform = Column(String(50), nullable=False)  # cli, web, discord, telegram
    created_at = Column(DateTime, default=datetime.utcnow)
    last_activity = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)

class APIUsage(Base):
    """Model for tracking API usage"""
    __tablename__ = "api_usage"
    
    id = Column(Integer, primary_key=True, index=True)
    api_name = Column(String(50), nullable=False)  # openai, google, twitter, etc.
    endpoint = Column(String(100), nullable=True)
    tokens_used = Column(Integer, default=0)
    cost = Column(Float, default=0.0)
    success = Column(Boolean, default=True)
    error_message = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

# Database setup
engine = create_engine(config.database_url, echo=config.debug)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def create_tables():
    """Create all database tables"""
    Base.metadata.create_all(bind=engine)

def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()