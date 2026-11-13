from typing import Dict, List
from collections import defaultdict
from ..core.logger import chimpi_logger

class ResultAggregator:
    """Aggregates and processes search results from multiple sources"""
    
    def __init__(self):
        self.logger = chimpi_logger
    
    def aggregate(self, search_results: Dict) -> Dict:
        """
        Aggregate search results from multiple sources
        
        Args:
            search_results: Dict containing results from different sources
        
        Returns:
            Aggregated and processed results
        """
        aggregated = {
            "sources": [],
            "top_results": [],
            "confidence": 0.0,
            "summary": "",
            "topics": [],
            "sentiment": "neutral"
        }
        
        try:
            # Process each source
            all_results = []
            source_count = 0
            
            for source_name, results in search_results.items():
                if results:
                    source_count += 1
                    self.logger.info(f"Processing {len(results)} results from {source_name}")
                    
                    # Add source info
                    aggregated["sources"].append({
                        "name": source_name,
                        "count": len(results),
                        "results": results[:3]  # Top 3 results per source
                    })
                    
                    all_results.extend(results)
            
            # Rank and filter results
            top_results = self._rank_results(all_results)
            aggregated["top_results"] = top_results[:10]  # Top 10 overall
            
            # Calculate confidence based on number of sources and results
            if source_count > 0 and all_results:
                base_confidence = min(source_count * 0.2, 0.8)  # Max 0.8 from sources
                result_confidence = min(len(all_results) * 0.02, 0.2)  # Max 0.2 from quantity
                aggregated["confidence"] = base_confidence + result_confidence
            
            # Extract topics
            aggregated["topics"] = self._extract_topics(all_results)
            
            # Generate summary
            aggregated["summary"] = self._generate_summary(top_results)
            
            self.logger.info(f"Aggregated {len(all_results)} total results from {source_count} sources")
            
        except Exception as e:
            self.logger.error(f"Result aggregation error: {str(e)}")
        
        return aggregated
    
    def _rank_results(self, results: List[Dict]) -> List[Dict]:
        """Rank results based on relevance and source reliability"""
        scored_results = []
        
        for result in results:
            score = 0.0
            
            # Source weight
            source_weights = {
                "google": 1.0,
                "bing": 0.9,
                "twitter": 0.7,
                "reddit": 0.8,
                "news": 1.1
            }
            source = result.get("source", "unknown")
            score += source_weights.get(source, 0.5)
            
            # Content quality indicators
            title = result.get("title", "")
            snippet = result.get("snippet", "")
            
            if title:
                score += 0.3
            if snippet:
                score += 0.2
            
            # Length bonus (more content is often better)
            content_length = len(title) + len(snippet)
            if content_length > 100:
                score += 0.1
            
            # URL quality (https, known domains)
            url = result.get("url", "")
            if url.startswith("https://"):
                score += 0.1
            
            # Add score to result
            result["relevance_score"] = score
            scored_results.append(result)
        
        # Sort by score (highest first)
        scored_results.sort(key=lambda x: x.get("relevance_score", 0), reverse=True)
        
        return scored_results
    
    def _extract_topics(self, results: List[Dict]) -> List[str]:
        """Extract common topics from search results"""
        try:
            # Simple keyword extraction from titles and snippets
            word_count = defaultdict(int)
            
            for result in results:
                text = f"{result.get('title', '')} {result.get('snippet', '')}".lower()
                
                # Simple tokenization and filtering
                words = text.replace(',', ' ').replace('.', ' ').split()
                for word in words:
                    word = word.strip('.,!?;:"()[]{}')
                    if len(word) > 3 and word not in ['the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had', 'her', 'was', 'one', 'our', 'out', 'day', 'get', 'has', 'him', 'his', 'how', 'man', 'new', 'now', 'old', 'see', 'two', 'way', 'who', 'boy', 'did', 'its', 'let', 'put', 'say', 'she', 'too', 'use']:
                        word_count[word] += 1
            
            # Get top topics
            topics = sorted(word_count.items(), key=lambda x: x[1], reverse=True)
            return [topic[0] for topic in topics[:10]]
            
        except Exception as e:
            self.logger.error(f"Topic extraction error: {str(e)}")
            return []
    
    def _generate_summary(self, results: List[Dict]) -> str:
        """Generate a brief summary of search results"""
        if not results:
            return "No search results found."
        
        try:
            # Combine top snippets
            snippets = []
            for result in results[:5]:  # Top 5 results
                snippet = result.get("snippet", "")
                if snippet:
                    snippets.append(snippet)
            
            if snippets:
                # Simple summarization by taking first sentences
                summary_parts = []
                for snippet in snippets:
                    sentences = snippet.split('.')
                    if sentences and sentences[0]:
                        summary_parts.append(sentences[0].strip())
                
                return ". ".join(summary_parts[:3]) + "."
            
            return "Multiple search results available."
            
        except Exception as e:
            self.logger.error(f"Summary generation error: {str(e)}")
            return "Search results processed successfully."
    
    def format_for_ai(self, aggregated_results: Dict) -> str:
        """Format aggregated results for AI processing"""
        try:
            formatted = []
            
            # Add summary
            if aggregated_results.get("summary"):
                formatted.append(f"Summary: {aggregated_results['summary']}")
            
            # Add top results
            top_results = aggregated_results.get("top_results", [])
            if top_results:
                formatted.append("\nTop Search Results:")
                for i, result in enumerate(top_results[:5], 1):
                    title = result.get("title", "")
                    snippet = result.get("snippet", "")
                    url = result.get("url", "")
                    source = result.get("source", "")
                    
                    formatted.append(f"{i}. {title}")
                    if snippet:
                        formatted.append(f"   {snippet}")
                    formatted.append(f"   Source: {source} - {url}")
            
            # Add topics
            topics = aggregated_results.get("topics", [])
            if topics:
                formatted.append(f"\nRelated Topics: {', '.join(topics[:5])}")
            
            return "\n".join(formatted)
            
        except Exception as e:
            self.logger.error(f"AI formatting error: {str(e)}")
            return "Search results available for processing."