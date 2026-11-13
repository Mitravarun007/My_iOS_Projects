import re
import nltk
from typing import List, Dict, Optional
from collections import Counter
from ..core.logger import chimpi_logger

class TextProcessor:
    """Natural Language Processing utilities for Chimpi AI"""
    
    def __init__(self):
        self.logger = chimpi_logger
        self._download_nltk_resources()
    
    def _download_nltk_resources(self):
        """Download required NLTK resources"""
        try:
            import nltk
            nltk.download('punkt', quiet=True)
            nltk.download('stopwords', quiet=True)
            nltk.download('vader_lexicon', quiet=True)
        except Exception as e:
            self.logger.warning(f"NLTK resource download failed: {str(e)}")
    
    def extract_keywords(self, text: str, max_keywords: int = 10) -> List[str]:
        """Extract keywords from text"""
        try:
            # Clean and tokenize text
            cleaned_text = self.clean_text(text)
            words = cleaned_text.lower().split()
            
            # Remove stopwords
            stopwords = self._get_stopwords()
            words = [word for word in words if word not in stopwords and len(word) > 2]
            
            # Count word frequencies
            word_freq = Counter(words)
            
            # Return most common words
            return [word for word, _ in word_freq.most_common(max_keywords)]
            
        except Exception as e:
            self.logger.error(f"Keyword extraction error: {str(e)}")
            return []
    
    def clean_text(self, text: str) -> str:
        """Clean and normalize text"""
        if not text:
            return ""
        
        try:
            # Remove URLs
            text = re.sub(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', '', text)
            
            # Remove email addresses
            text = re.sub(r'\S+@\S+', '', text)
            
            # Remove special characters but keep basic punctuation
            text = re.sub(r'[^\w\s\.\!\?,:;-]', ' ', text)
            
            # Remove extra whitespace
            text = re.sub(r'\s+', ' ', text).strip()
            
            return text
            
        except Exception as e:
            self.logger.error(f"Text cleaning error: {str(e)}")
            return text
    
    def summarize_text(self, text: str, max_sentences: int = 3) -> str:
        """Simple extractive text summarization"""
        try:
            if not text:
                return ""
            
            # Split into sentences
            sentences = self._split_sentences(text)
            
            if len(sentences) <= max_sentences:
                return text
            
            # Score sentences based on keyword frequency
            keywords = self.extract_keywords(text, 20)
            keyword_set = set(keywords)
            
            sentence_scores = {}
            for i, sentence in enumerate(sentences):
                words = sentence.lower().split()
                score = sum(1 for word in words if word in keyword_set)
                sentence_scores[i] = score
            
            # Select top sentences
            top_sentences = sorted(sentence_scores.items(), key=lambda x: x[1], reverse=True)[:max_sentences]
            top_sentences = sorted([idx for idx, _ in top_sentences])  # Maintain order
            
            # Combine selected sentences
            summary = '. '.join([sentences[i] for i in top_sentences])
            
            return summary
            
        except Exception as e:
            self.logger.error(f"Text summarization error: {str(e)}")
            return text[:500] + "..." if len(text) > 500 else text
    
    def _split_sentences(self, text: str) -> List[str]:
        """Split text into sentences"""
        try:
            from nltk.tokenize import sent_tokenize
            return sent_tokenize(text)
        except:
            # Fallback simple sentence splitting
            sentences = re.split(r'[.!?]+', text)
            return [s.strip() for s in sentences if s.strip()]
    
    def analyze_sentiment(self, text: str) -> Dict[str, float]:
        """Analyze sentiment of text using VADER"""
        try:
            from nltk.sentiment.vader import SentimentIntensityAnalyzer
            
            analyzer = SentimentIntensityAnalyzer()
            scores = analyzer.polarity_scores(text)
            
            # Determine overall sentiment
            compound = scores['compound']
            if compound >= 0.05:
                sentiment = "positive"
            elif compound <= -0.05:
                sentiment = "negative"
            else:
                sentiment = "neutral"
            
            return {
                "sentiment": sentiment,
                "positive": scores['pos'],
                "negative": scores['neg'],
                "neutral": scores['neu'],
                "compound": compound
            }
            
        except Exception as e:
            self.logger.error(f"Sentiment analysis error: {str(e)}")
            return {
                "sentiment": "neutral",
                "positive": 0.0,
                "negative": 0.0,
                "neutral": 1.0,
                "compound": 0.0
            }
    
    def extract_entities(self, text: str) -> List[Dict]:
        """Extract named entities from text (simple version)"""
        try:
            # Simple pattern-based entity extraction
            entities = []
            
            # Extract potential person names (capitalized words)
            person_pattern = r'\b[A-Z][a-z]+ [A-Z][a-z]+\b'
            persons = re.findall(person_pattern, text)
            for person in persons:
                entities.append({"text": person, "type": "PERSON"})
            
            # Extract potential organizations (companies, etc.)
            org_patterns = [
                r'\b[A-Z][a-z]+ (Inc|LLC|Corp|Company|Ltd)\b',
                r'\b[A-Z]{2,}\b'  # Acronyms
            ]
            for pattern in org_patterns:
                orgs = re.findall(pattern, text)
                for org in orgs:
                    entities.append({"text": org, "type": "ORG"})
            
            # Extract dates
            date_pattern = r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b|\b(January|February|March|April|May|June|July|August|September|October|November|December) \d{1,2},? \d{4}\b'
            dates = re.findall(date_pattern, text)
            for date in dates:
                date_text = date if isinstance(date, str) else date[0] if date else ""
                if date_text:
                    entities.append({"text": date_text, "type": "DATE"})
            
            return entities
            
        except Exception as e:
            self.logger.error(f"Entity extraction error: {str(e)}")
            return []
    
    def _get_stopwords(self) -> set:
        """Get common English stopwords"""
        try:
            from nltk.corpus import stopwords
            return set(stopwords.words('english'))
        except:
            # Fallback stopwords
            return {
                'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from',
                'has', 'he', 'in', 'is', 'it', 'its', 'of', 'on', 'that', 'the',
                'to', 'was', 'will', 'with', 'the', 'this', 'but', 'they', 'have',
                'had', 'what', 'said', 'each', 'which', 'she', 'do', 'how', 'their',
                'if', 'up', 'out', 'many', 'then', 'them', 'these', 'so', 'some',
                'her', 'would', 'make', 'like', 'into', 'him', 'time', 'two', 'more',
                'go', 'no', 'way', 'could', 'my', 'than', 'first', 'been', 'call',
                'who', 'oil', 'sit', 'now', 'find', 'down', 'day', 'did', 'get',
                'come', 'made', 'may', 'part'
            }
    
    def generate_simple_response(self, question: str, context: Dict) -> str:
        """Generate a simple response when AI services are unavailable"""
        try:
            # Extract key information from context
            sources = context.get("sources", [])
            top_results = context.get("top_results", [])
            
            # If we have search results, use them
            if top_results:
                # Create a simple response based on search results
                response_parts = [
                    f"Based on my search, here's what I found about your question:",
                    ""
                ]
                
                # Add top results
                for i, result in enumerate(top_results[:3], 1):
                    title = result.get("title", "")
                    snippet = result.get("snippet", "")
                    source = result.get("source", "")
                    
                    if snippet:
                        response_parts.append(f"{i}. {snippet}")
                    elif title:
                        response_parts.append(f"{i}. {title}")
                    
                    if source:
                        response_parts.append(f"   (Source: {source})")
                    response_parts.append("")
                
                # Add summary if available
                summary = context.get("summary", "")
                if summary:
                    response_parts.append(f"Summary: {summary}")
                
                return "\n".join(response_parts)
            
            # If no search results, provide built-in knowledge for common questions
            return self._generate_builtin_response(question)
            
        except Exception as e:
            self.logger.error(f"Simple response generation error: {str(e)}")
            return "I found some information related to your question, but I'm having trouble processing it right now. Please try asking again."
    
    def _generate_builtin_response(self, question: str) -> str:
        """Generate responses using built-in knowledge for common questions"""
        question_lower = question.lower().strip()
        
        # AI and Technology questions - more flexible matching
        ai_keywords = ['ai', 'artificial', 'intelligence', 'inteligence', 'artif', 'intel']
        if any(keyword in question_lower for keyword in ai_keywords) and any(word in question_lower for word in ['what', 'define', 'explain']):
            return """🤖 **Artificial Intelligence (AI)** is a broad field of computer science focused on creating systems that can perform tasks that typically require human intelligence.

**Key aspects of AI include:**

• **Machine Learning**: Systems that learn and improve from data without explicit programming
• **Natural Language Processing**: Understanding and generating human language
• **Computer Vision**: Interpreting and analyzing visual information
• **Robotics**: Physical systems that can interact with the environment
• **Expert Systems**: Programs that mimic human decision-making in specific domains

**Types of AI:**
- **Narrow AI**: Designed for specific tasks (like voice assistants, recommendation systems)
- **General AI**: Hypothetical AI with human-level intelligence across all domains
- **Superintelligence**: AI that surpasses human intelligence (theoretical)

**Applications**: Virtual assistants, autonomous vehicles, medical diagnosis, game playing, language translation, image recognition, and much more.

AI is transforming industries and daily life, making systems smarter and more efficient while raising important questions about ethics, employment, and the future of human-AI interaction."""

        elif any(word in question_lower for word in ['machine learning', 'ml', 'deep learning']) or ('machine' in question_lower and 'learn' in question_lower):
            return """🧠 **Machine Learning (ML)** is a subset of AI that enables systems to learn and improve from data without being explicitly programmed for every scenario.

**Key concepts:**
• **Supervised Learning**: Learning from labeled examples
• **Unsupervised Learning**: Finding patterns in unlabeled data  
• **Reinforcement Learning**: Learning through trial and error with rewards
• **Deep Learning**: Using neural networks with many layers

**Common applications**: Recommendation systems, fraud detection, image recognition, speech recognition, and predictive analytics."""

        # Current events and government questions
        elif any(word in question_lower for word in ['prime minister', 'pm']) and 'india' in question_lower:
            return """🇮🇳 **India's Prime Minister**

As of my last knowledge update, **Narendra Modi** has been serving as the Prime Minister of India since May 26, 2014. He is a member of the Bharatiya Janata Party (BJP) and has been re-elected for multiple terms.

**Key Information:**
• **Current Term**: Started in 2014, re-elected in 2019
• **Political Party**: Bharatiya Janata Party (BJP) 
• **Previous Role**: Chief Minister of Gujarat (2001-2014)
• **Notable Initiatives**: Digital India, Make in India, Swachh Bharat Mission

**Note**: For the most current information about India's government, I recommend checking recent news sources as political situations can change."""

        # Technology and programming questions
        elif any(word in question_lower for word in ['python', 'programming', 'code', 'software']):
            return """💻 **Programming** is the process of creating instructions for computers to solve problems and perform tasks.

**Popular programming languages:**
• **Python**: Great for beginners, AI/ML, web development
• **JavaScript**: Essential for web development
• **Java**: Enterprise applications, Android development
• **C++**: System programming, game development
• **SQL**: Database management

**Key concepts**: Variables, functions, loops, conditionals, data structures, algorithms, and object-oriented programming."""

        elif any(word in question_lower for word in ['technology', 'tech', 'computer', 'internet']):
            return """🔧 **Technology** refers to the application of scientific knowledge for practical purposes, especially in industry and computing.

**Major areas:**
• **Computing**: Hardware, software, networks
• **Internet**: Global network connecting billions of devices
• **Mobile Technology**: Smartphones, tablets, apps
• **Cloud Computing**: Remote servers and services
• **Cybersecurity**: Protecting digital systems and data

Technology continues to evolve rapidly, shaping how we work, communicate, and live."""

        # General knowledge questions
        elif any(word in question_lower for word in ['hello', 'hi', 'hey', 'greetings']):
            return """👋 Hello! I'm Chimpi, your AI assistant. I'm here to help answer your questions and provide information on a wide range of topics.

I can help with:
• Technology and programming questions
• General knowledge and explanations
• Research and analysis
• Problem-solving assistance

What would you like to know about today?"""

        elif any(word in question_lower for word in ['help', 'what can you do', 'capabilities']):
            return """🤖 **I'm Chimpi, your AI assistant!** Here's what I can help you with:

**🔍 Information & Research:**
- Answer questions on various topics
- Explain complex concepts simply
- Provide definitions and overviews

**💻 Technology & Programming:**
- Programming languages and concepts
- Software development guidance
- Technology explanations

**🧠 Learning Support:**
- Break down difficult topics
- Provide examples and analogies
- Research assistance

**Note**: I work best when you ask specific questions. Try asking about topics like AI, programming, science, technology, or any subject you're curious about!"""

        else:
            # Default response for unknown questions
            return f"""I understand you're asking about "{question}". While I don't have specific search results available right now, I'm designed to help with a wide range of topics.

**Try asking me about:**
• Technology and programming concepts
• Artificial intelligence and machine learning
• General knowledge questions
• Scientific topics and explanations

To get the most comprehensive answers, you can also:
1. Set up API keys in the .env file for web search capabilities
2. Be more specific with your question
3. Try rephrasing your question differently

Feel free to ask me anything else! I'm here to help. 🤖"""