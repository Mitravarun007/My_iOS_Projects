import requests
from typing import Optional, Dict, List
from ..core.config import config
from ..core.logger import chimpi_logger

class CopilotClient:
    """GitHub Copilot API client for code-related queries"""
    
    def __init__(self):
        self.logger = chimpi_logger
        self.github_token = config.github_token
        
        if not self.github_token:
            self.logger.warning("GitHub token not found - Copilot features disabled")
            self.enabled = False
        else:
            self.enabled = True
            
        self.base_url = "https://api.github.com"
        self.headers = {
            "Authorization": f"Bearer {self.github_token}",
            "Accept": "application/vnd.github.v3+json"
        }
    
    async def search_code(self, query: str, language: Optional[str] = None) -> List[Dict]:
        """
        Search for code snippets on GitHub
        
        Args:
            query: Search query
            language: Programming language filter
        
        Returns:
            List of code search results
        """
        if not self.enabled:
            return []
        
        try:
            # Construct search query
            search_query = query
            if language:
                search_query += f" language:{language}"
            
            # Make API request
            url = f"{self.base_url}/search/code"
            params = {
                "q": search_query,
                "sort": "indexed",
                "order": "desc",
                "per_page": config.max_search_results
            }
            
            response = requests.get(url, headers=self.headers, params=params)
            response.raise_for_status()
            
            results = response.json()
            
            # Process results
            code_snippets = []
            for item in results.get('items', []):
                snippet = {
                    "title": item.get('name', ''),
                    "repository": item.get('repository', {}).get('full_name', ''),
                    "path": item.get('path', ''),
                    "url": item.get('html_url', ''),
                    "score": item.get('score', 0),
                    "language": item.get('repository', {}).get('language', ''),
                    "description": item.get('repository', {}).get('description', '')
                }
                code_snippets.append(snippet)
            
            self.logger.info(f"Found {len(code_snippets)} code snippets")
            return code_snippets
            
        except Exception as e:
            self.logger.error(f"GitHub code search error: {str(e)}")
            return []
    
    async def get_repository_info(self, repo_name: str) -> Optional[Dict]:
        """Get information about a specific repository"""
        if not self.enabled:
            return None
        
        try:
            url = f"{self.base_url}/repos/{repo_name}"
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            
            repo_data = response.json()
            
            return {
                "name": repo_data.get('full_name', ''),
                "description": repo_data.get('description', ''),
                "language": repo_data.get('language', ''),
                "stars": repo_data.get('stargazers_count', 0),
                "forks": repo_data.get('forks_count', 0),
                "url": repo_data.get('html_url', ''),
                "topics": repo_data.get('topics', []),
                "created_at": repo_data.get('created_at', ''),
                "updated_at": repo_data.get('updated_at', '')
            }
            
        except Exception as e:
            self.logger.error(f"Repository info error: {str(e)}")
            return None
    
    async def search_repositories(self, query: str, language: Optional[str] = None) -> List[Dict]:
        """Search for repositories"""
        if not self.enabled:
            return []
        
        try:
            # Construct search query
            search_query = query
            if language:
                search_query += f" language:{language}"
            
            url = f"{self.base_url}/search/repositories"
            params = {
                "q": search_query,
                "sort": "stars",
                "order": "desc",
                "per_page": config.max_search_results
            }
            
            response = requests.get(url, headers=self.headers, params=params)
            response.raise_for_status()
            
            results = response.json()
            
            repositories = []
            for item in results.get('items', []):
                repo = {
                    "name": item.get('full_name', ''),
                    "description": item.get('description', ''),
                    "language": item.get('language', ''),
                    "stars": item.get('stargazers_count', 0),
                    "forks": item.get('forks_count', 0),
                    "url": item.get('html_url', ''),
                    "topics": item.get('topics', [])
                }
                repositories.append(repo)
            
            self.logger.info(f"Found {len(repositories)} repositories")
            return repositories
            
        except Exception as e:
            self.logger.error(f"Repository search error: {str(e)}")
            return []