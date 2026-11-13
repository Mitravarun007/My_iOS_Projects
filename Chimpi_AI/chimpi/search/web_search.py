import aiohttp
import asyncio
from typing import List, Dict, Optional
from urllib.parse import quote
from ..core.config import config
from ..core.logger import chimpi_logger

class WebSearcher:
    """Web search functionality using Google and Bing APIs"""
    
    def __init__(self):
        self.logger = chimpi_logger
        self.google_api_key = config.google_search_api_key
        self.google_engine_id = config.google_search_engine_id
        self.bing_api_key = config.bing_search_api_key
        self.timeout = aiohttp.ClientTimeout(total=config.search_timeout)
    
    async def search(self, query: str) -> List[Dict]:
        """
        Perform web search using available search engines
        
        Args:
            query: Search query
        
        Returns:
            List of search results
        """
        results = []
        tasks = []
        
        # Google Search
        if self.google_api_key and self.google_engine_id:
            tasks.append(self._google_search(query))
        
        # Bing Search
        if self.bing_api_key:
            tasks.append(self._bing_search(query))
        
        if tasks:
            search_results = await asyncio.gather(*tasks, return_exceptions=True)
            
            for result in search_results:
                if isinstance(result, Exception):
                    self.logger.error(f"Search failed: {str(result)}")
                else:
                    results.extend(result)
        
        # Remove duplicates and limit results
        unique_results = self._deduplicate_results(results)
        return unique_results[:config.max_search_results]
    
    async def _google_search(self, query: str) -> List[Dict]:
        """Perform Google Custom Search"""
        try:
            url = "https://www.googleapis.com/customsearch/v1"
            params = {
                "key": self.google_api_key,
                "cx": self.google_engine_id,
                "q": query,
                "num": min(config.max_search_results, 10)
            }
            
            async with aiohttp.ClientSession(timeout=self.timeout) as session:
                async with session.get(url, params=params) as response:
                    response.raise_for_status()
                    data = await response.json()
            
            results = []
            for item in data.get('items', []):
                result = {
                    "title": item.get('title', ''),
                    "url": item.get('link', ''),
                    "snippet": item.get('snippet', ''),
                    "source": "google",
                    "display_url": item.get('displayLink', ''),
                    "image": item.get('pagemap', {}).get('cse_image', [{}])[0].get('src', '') if item.get('pagemap') else ''
                }
                results.append(result)
            
            self.logger.info(f"Google search returned {len(results)} results")
            return results
            
        except Exception as e:
            self.logger.error(f"Google search error: {str(e)}")
            return []
    
    async def _bing_search(self, query: str) -> List[Dict]:
        """Perform Bing Web Search"""
        try:
            url = "https://api.bing.microsoft.com/v7.0/search"
            headers = {
                "Ocp-Apim-Subscription-Key": self.bing_api_key
            }
            params = {
                "q": query,
                "count": min(config.max_search_results, 50),
                "responseFilter": "Webpages"
            }
            
            async with aiohttp.ClientSession(timeout=self.timeout) as session:
                async with session.get(url, headers=headers, params=params) as response:
                    response.raise_for_status()
                    data = await response.json()
            
            results = []
            for item in data.get('webPages', {}).get('value', []):
                result = {
                    "title": item.get('name', ''),
                    "url": item.get('url', ''),
                    "snippet": item.get('snippet', ''),
                    "source": "bing",
                    "display_url": item.get('displayUrl', ''),
                    "date_published": item.get('datePublished', '')
                }
                results.append(result)
            
            self.logger.info(f"Bing search returned {len(results)} results")
            return results
            
        except Exception as e:
            self.logger.error(f"Bing search error: {str(e)}")
            return []
    
    def _deduplicate_results(self, results: List[Dict]) -> List[Dict]:
        """Remove duplicate search results based on URL"""
        seen_urls = set()
        unique_results = []
        
        for result in results:
            url = result.get('url', '')
            if url and url not in seen_urls:
                seen_urls.add(url)
                unique_results.append(result)
        
        return unique_results
    
    async def search_news(self, query: str) -> List[Dict]:
        """Search for news articles"""
        try:
            # Use Google News Search
            if self.google_api_key and self.google_engine_id:
                url = "https://www.googleapis.com/customsearch/v1"
                params = {
                    "key": self.google_api_key,
                    "cx": self.google_engine_id,
                    "q": query,
                    "num": min(config.max_search_results, 10),
                    "tbm": "nws"  # News search
                }
                
                async with aiohttp.ClientSession(timeout=self.timeout) as session:
                    async with session.get(url, params=params) as response:
                        response.raise_for_status()
                        data = await response.json()
                
                results = []
                for item in data.get('items', []):
                    result = {
                        "title": item.get('title', ''),
                        "url": item.get('link', ''),
                        "snippet": item.get('snippet', ''),
                        "source": "google_news",
                        "display_url": item.get('displayLink', ''),
                        "published_time": item.get('pagemap', {}).get('metatags', [{}])[0].get('article:published_time', '')
                    }
                    results.append(result)
                
                return results
            
            return []
            
        except Exception as e:
            self.logger.error(f"News search error: {str(e)}")
            return []