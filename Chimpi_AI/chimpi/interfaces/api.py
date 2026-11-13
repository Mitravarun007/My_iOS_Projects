from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
from ..main import Chimpi
from ..core.config import config
from ..core.logger import chimpi_logger

# FastAPI app
app = FastAPI(
    title="Chimpi AI API",
    description="Intelligent Question Answering Robot API",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Chimpi
chimpi = Chimpi()

# Request/Response models
class QuestionRequest(BaseModel):
    question: str
    sources: Optional[List[str]] = None
    max_results: Optional[int] = None

class QuestionResponse(BaseModel):
    question: str
    answer: str
    sources: List[dict]
    confidence: float
    search_results: dict

# API endpoints
@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Welcome to Chimpi AI API",
        "version": "1.0.0",
        "status": "online"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "apis": {
            "openai": bool(chimpi.openai_client),
            "gemini": bool(chimpi.gemini_client),
            "twitter": bool(chimpi.twitter_searcher),
            "reddit": bool(chimpi.reddit_searcher)
        }
    }

@app.post("/ask", response_model=QuestionResponse)
async def ask_question(request: QuestionRequest):
    """Ask Chimpi a question"""
    try:
        chimpi_logger.info(f"API request: {request.question}")
        
        response = await chimpi.ask(
            question=request.question,
            sources=request.sources
        )
        
        return QuestionResponse(**response)
        
    except Exception as e:
        chimpi_logger.error(f"API error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/search")
async def search_only(request: QuestionRequest):
    """Search without AI processing"""
    try:
        # Perform search without AI response generation
        search_results = await chimpi._gather_information(
            request.question,
            request.sources or ["web"]
        )
        
        return {
            "question": request.question,
            "search_results": search_results,
            "sources": list(search_results.keys())
        }
        
    except Exception as e:
        chimpi_logger.error(f"Search API error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/sources")
async def get_available_sources():
    """Get available search sources"""
    sources = {
        "web": True,  # Always available
        "ai": bool(chimpi.openai_client or chimpi.gemini_client),
        "twitter": bool(chimpi.twitter_searcher),
        "reddit": bool(chimpi.reddit_searcher)
    }
    
    return {
        "sources": sources,
        "available": [k for k, v in sources.items() if v]
    }

# Run server
def run_server():
    """Run the FastAPI server"""
    uvicorn.run(
        "chimpi.interfaces.api:app",
        host=config.app_host,
        port=config.app_port,
        reload=config.debug,
        log_level=config.log_level.lower()
    )

if __name__ == "__main__":
    run_server()