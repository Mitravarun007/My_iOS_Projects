import google.generativeai as genai
from typing import Optional
from ..core.config import config
from ..core.logger import chimpi_logger

class GeminiClient:
    """Google Gemini API client for Chimpi AI"""
    
    def __init__(self):
        self.logger = chimpi_logger
        self.api_key = config.google_api_key
        
        if not self.api_key:
            raise ValueError("Google API key not found in configuration")
        
        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel('gemini-pro')
    
    async def generate_response(self, question: str, context: Optional[str] = None) -> str:
        """
        Generate response using Google Gemini
        
        Args:
            question: User's question
            context: Additional context from search results
        
        Returns:
            Generated response
        """
        try:
            # Prepare the prompt
            prompt = f"""You are Chimpi, an intelligent AI assistant that searches the web and social media to provide comprehensive answers.
            
Question: {question}"""
            
            if context:
                prompt += f"\n\nContext from search results:\n{context}"
            
            prompt += "\n\nPlease provide a helpful, accurate, and well-structured response based on the question and available context. Always cite your sources when providing information."
            
            # Generate response
            response = await self.model.generate_content_async(prompt)
            
            answer = response.text.strip()
            
            self.logger.info("Gemini response generated successfully")
            return answer
            
        except Exception as e:
            self.logger.error(f"Gemini API error: {str(e)}")
            raise e
    
    async def analyze_content(self, content: str) -> dict:
        """Analyze content for key topics and sentiment"""
        try:
            prompt = f"""Analyze the following content and provide:
1. Main topics (up to 5)
2. Sentiment (positive/negative/neutral)
3. Key insights

Content: {content}

Provide response in this format:
Topics: [topic1, topic2, ...]
Sentiment: [sentiment]
Insights: [brief insights]"""
            
            response = await self.model.generate_content_async(prompt)
            
            # Parse the response (simplified parsing)
            result = {
                "topics": [],
                "sentiment": "neutral",
                "insights": response.text
            }
            
            # Basic parsing logic
            lines = response.text.split('\n')
            for line in lines:
                if line.startswith('Topics:'):
                    topics_text = line.replace('Topics:', '').strip()
                    result["topics"] = [t.strip() for t in topics_text.strip('[]').split(',')]
                elif line.startswith('Sentiment:'):
                    result["sentiment"] = line.replace('Sentiment:', '').strip().lower()
            
            return result
            
        except Exception as e:
            self.logger.error(f"Content analysis error: {str(e)}")
            return {"topics": [], "sentiment": "neutral", "insights": ""}
    
    async def generate_summary(self, text: str, style: str = "concise") -> str:
        """Generate summary of text"""
        try:
            prompt = f"""Please provide a {style} summary of the following text:

{text}

Summary:"""
            
            response = await self.model.generate_content_async(prompt)
            return response.text.strip()
            
        except Exception as e:
            self.logger.error(f"Summary generation error: {str(e)}")
            return "Unable to generate summary."