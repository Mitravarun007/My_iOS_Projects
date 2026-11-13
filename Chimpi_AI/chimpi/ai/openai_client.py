import openai
from typing import Optional
from ..core.config import config
from ..core.logger import chimpi_logger

class OpenAIClient:
    """OpenAI API client for Chimpi AI"""
    
    def __init__(self):
        self.logger = chimpi_logger
        self.api_key = config.openai_api_key
        
        if not self.api_key:
            raise ValueError("OpenAI API key not found in configuration")
        
        openai.api_key = self.api_key
        self.model = config.default_ai_model
        self.temperature = config.temperature
        self.max_tokens = config.max_tokens
    
    async def generate_response(self, question: str, context: Optional[str] = None) -> str:
        """
        Generate response using OpenAI GPT
        
        Args:
            question: User's question
            context: Additional context from search results
        
        Returns:
            Generated response
        """
        try:
            # Prepare the prompt
            system_prompt = """You are Chimpi, an intelligent AI assistant that can search the web and social media to provide comprehensive answers. 
            You have access to real-time information from various sources. Provide helpful, accurate, and well-structured responses.
            Always cite your sources when providing information."""
            
            user_prompt = f"Question: {question}"
            
            if context:
                user_prompt += f"\n\nContext from search results:\n{context}"
            
            user_prompt += "\n\nPlease provide a comprehensive answer based on the question and available context."
            
            # Make API call
            response = await openai.ChatCompletion.acreate(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=self.temperature,
                max_tokens=self.max_tokens
            )
            
            answer = response.choices[0].message.content.strip()
            
            self.logger.info("OpenAI response generated successfully")
            return answer
            
        except Exception as e:
            self.logger.error(f"OpenAI API error: {str(e)}")
            raise e
    
    async def analyze_sentiment(self, text: str) -> dict:
        """Analyze sentiment of given text"""
        try:
            response = await openai.ChatCompletion.acreate(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "Analyze the sentiment of the following text. Return only: positive, negative, or neutral."},
                    {"role": "user", "content": text}
                ],
                temperature=0.1,
                max_tokens=50
            )
            
            sentiment = response.choices[0].message.content.strip().lower()
            
            return {
                "sentiment": sentiment,
                "confidence": 0.8  # Placeholder confidence score
            }
            
        except Exception as e:
            self.logger.error(f"Sentiment analysis error: {str(e)}")
            return {"sentiment": "neutral", "confidence": 0.0}
    
    async def summarize_text(self, text: str, max_length: int = 200) -> str:
        """Summarize long text"""
        try:
            response = await openai.ChatCompletion.acreate(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": f"Summarize the following text in no more than {max_length} characters."},
                    {"role": "user", "content": text}
                ],
                temperature=0.3,
                max_tokens=max_length // 4  # Rough token estimation
            )
            
            summary = response.choices[0].message.content.strip()
            return summary
            
        except Exception as e:
            self.logger.error(f"Text summarization error: {str(e)}")
            return text[:max_length] + "..." if len(text) > max_length else text