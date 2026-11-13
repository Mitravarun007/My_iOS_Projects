import asyncio
from typing import Dict, List, Optional
from .core.config import config
from .core.logger import chimpi_logger
from .core.database import create_tables
from .ai.openai_client import OpenAIClient
from .ai.gemini_client import GeminiClient
from .search.web_search import WebSearcher
from .search.aggregator import ResultAggregator
from .social.twitter import TwitterSearcher
from .social.reddit import RedditSearcher
from .utils.text_processor import TextProcessor

class Chimpi:
    """Main Chimpi AI class for handling questions and generating responses"""
    
    def __init__(self):
        self.logger = chimpi_logger
        self.config = config
        
        # Initialize components
        self.openai_client = OpenAIClient() if config.openai_api_key else None
        self.gemini_client = GeminiClient() if config.google_api_key else None
        self.web_searcher = WebSearcher()
        self.twitter_searcher = TwitterSearcher() if config.twitter_bearer_token else None
        self.reddit_searcher = RedditSearcher() if config.reddit_client_id else None
        self.result_aggregator = ResultAggregator()
        self.text_processor = TextProcessor()
        
        # Initialize database
        create_tables()
        
        self.logger.info("Chimpi AI initialized successfully")
    
    async def ask(self, question: str, sources: Optional[List[str]] = None) -> Dict:
        """
        Main method to ask Chimpi a question
        
        Args:
            question: The question to ask
            sources: Optional list of sources to search (web, twitter, reddit, etc.)
        
        Returns:
            Dict containing the answer and source information
        """
        try:
            self.logger.info(f"Processing question: {question}")
            
            # Default sources if none specified
            if sources is None:
                sources = ["web", "ai"]
                if self.config.enable_social_media:
                    sources.extend(["twitter", "reddit"])
            
            # Gather information from various sources
            search_results = await self._gather_information(question, sources)
            
            # Aggregate and process results
            aggregated_results = self.result_aggregator.aggregate(search_results)
            
            # Generate AI-powered response
            ai_response = await self._generate_ai_response(question, aggregated_results)
            
            # Prepare final response
            response = {
                "question": question,
                "answer": ai_response,
                "sources": aggregated_results.get("sources", []),
                "confidence": aggregated_results.get("confidence", 0.0),
                "search_results": search_results
            }
            
            self.logger.info("Question processed successfully")
            return response
            
        except Exception as e:
            self.logger.error(f"Error processing question: {str(e)}")
            return {
                "question": question,
                "answer": f"I apologize, but I encountered an error while processing your question: {str(e)}",
                "sources": [],
                "confidence": 0.0,
                "error": str(e)
            }
    
    async def _gather_information(self, question: str, sources: List[str]) -> Dict:
        """Gather information from various sources"""
        results = {}
        tasks = []
        
        # Web search
        if "web" in sources:
            tasks.append(self._search_web(question))
        
        # Social media searches
        if "twitter" in sources and self.twitter_searcher:
            tasks.append(self._search_twitter(question))
        
        if "reddit" in sources and self.reddit_searcher:
            tasks.append(self._search_reddit(question))
        
        # Execute all searches concurrently
        if tasks:
            search_results = await asyncio.gather(*tasks, return_exceptions=True)
            
            # Process results
            for i, result in enumerate(search_results):
                if isinstance(result, Exception):
                    self.logger.error(f"Search task {i} failed: {str(result)}")
                else:
                    results.update(result)
        
        return results
    
    async def _search_web(self, question: str) -> Dict:
        """Search the web for information"""
        try:
            results = await self.web_searcher.search(question)
            return {"web": results}
        except Exception as e:
            self.logger.error(f"Web search failed: {str(e)}")
            return {"web": []}
    
    async def _search_twitter(self, question: str) -> Dict:
        """Search Twitter for information"""
        try:
            results = await self.twitter_searcher.search(question)
            return {"twitter": results}
        except Exception as e:
            self.logger.error(f"Twitter search failed: {str(e)}")
            return {"twitter": []}
    
    async def _search_reddit(self, question: str) -> Dict:
        """Search Reddit for information"""
        try:
            results = await self.reddit_searcher.search(question)
            return {"reddit": results}
        except Exception as e:
            self.logger.error(f"Reddit search failed: {str(e)}")
            return {"reddit": []}
    
    async def _generate_ai_response(self, question: str, context: Dict) -> str:
        """Generate AI-powered response using available AI services"""
        try:
            # Prepare context for AI
            context_text = self.result_aggregator.format_for_ai(context)
            
            # Try OpenAI first
            if self.openai_client:
                try:
                    response = await self.openai_client.generate_response(question, context_text)
                    return response
                except Exception as e:
                    self.logger.warning(f"OpenAI failed, trying Gemini: {str(e)}")
            
            # Fallback to Gemini
            if self.gemini_client:
                try:
                    response = await self.gemini_client.generate_response(question, context_text)
                    return response
                except Exception as e:
                    self.logger.warning(f"Gemini failed: {str(e)}")
            
            # Fallback to simple text processing
            return self.text_processor.generate_simple_response(question, context)
            
        except Exception as e:
            self.logger.error(f"AI response generation failed: {str(e)}")
            return "I'm having trouble generating a comprehensive response right now, but here's what I found from my searches."

# CLI entry point
if __name__ == "__main__":
    import sys
    
    async def main():
        chimpi = Chimpi()
        
        if len(sys.argv) > 1:
            question = " ".join(sys.argv[1:])
        else:
            question = input("Ask Chimpi: ")
        
        response = await chimpi.ask(question)
        
        print(f"\n🤖 Chimpi's Response:")
        print(f"{response['answer']}\n")
        
        if response.get('sources'):
            print("📚 Sources:")
            for source in response['sources'][:3]:  # Show top 3 sources
                print(f"  • {source}")
    
    asyncio.run(main())