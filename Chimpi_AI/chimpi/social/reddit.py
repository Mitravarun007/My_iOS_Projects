import praw
import asyncio
from typing import List, Dict, Optional
from ..core.config import config
from ..core.logger import chimpi_logger

class RedditSearcher:
    """Reddit search functionality using PRAW"""
    
    def __init__(self):
        self.logger = chimpi_logger
        self.client_id = config.reddit_client_id
        self.client_secret = config.reddit_client_secret
        self.user_agent = config.reddit_user_agent
        
        if not all([self.client_id, self.client_secret]):
            raise ValueError("Reddit API credentials not found in configuration")
        
        # Initialize Reddit API client
        self.reddit = praw.Reddit(
            client_id=self.client_id,
            client_secret=self.client_secret,
            user_agent=self.user_agent
        )
    
    async def search(self, query: str, max_results: int = None) -> List[Dict]:
        """
        Search Reddit for posts related to the query
        
        Args:
            query: Search query
            max_results: Maximum number of results to return
        
        Returns:
            List of Reddit post data
        """
        if max_results is None:
            max_results = config.max_search_results
        
        try:
            # Run Reddit search in executor to avoid blocking
            loop = asyncio.get_event_loop()
            posts = await loop.run_in_executor(
                None,
                self._search_posts,
                query,
                max_results
            )
            
            self.logger.info(f"Found {len(posts)} Reddit posts for query: {query}")
            return posts
            
        except Exception as e:
            self.logger.error(f"Reddit search error: {str(e)}")
            return []
    
    def _search_posts(self, query: str, max_results: int) -> List[Dict]:
        """Internal method to search Reddit posts"""
        try:
            posts_data = []
            
            # Search across all of Reddit
            search_results = self.reddit.subreddit("all").search(
                query,
                sort="relevance",
                time_filter="all",
                limit=max_results
            )
            
            for post in search_results:
                post_dict = {
                    "id": post.id,
                    "title": post.title,
                    "selftext": post.selftext,
                    "url": post.url,
                    "permalink": f"https://reddit.com{post.permalink}",
                    "subreddit": str(post.subreddit),
                    "author": str(post.author) if post.author else "[deleted]",
                    "score": post.score,
                    "upvote_ratio": post.upvote_ratio,
                    "num_comments": post.num_comments,
                    "created_utc": post.created_utc,
                    "is_self": post.is_self,
                    "over_18": post.over_18,
                    "spoiler": post.spoiler,
                    "stickied": post.stickied,
                    "source": "reddit",
                    "snippet": self._create_snippet(post.title, post.selftext)
                }
                
                # Add flair information if available
                if post.link_flair_text:
                    post_dict["flair"] = post.link_flair_text
                
                posts_data.append(post_dict)
            
            return posts_data
            
        except Exception as e:
            self.logger.error(f"Reddit search execution error: {str(e)}")
            return []
    
    def _create_snippet(self, title: str, selftext: str) -> str:
        """Create a snippet from title and selftext"""
        snippet = title
        if selftext:
            # Add first few sentences of selftext
            sentences = selftext.split('.')
            if sentences and len(sentences[0]) > 10:
                snippet += f" - {sentences[0][:200]}..."
        return snippet
    
    async def search_subreddit(self, subreddit_name: str, query: str, max_results: int = None) -> List[Dict]:
        """Search within a specific subreddit"""
        if max_results is None:
            max_results = config.max_search_results
        
        try:
            loop = asyncio.get_event_loop()
            posts = await loop.run_in_executor(
                None,
                self._search_subreddit_posts,
                subreddit_name,
                query,
                max_results
            )
            
            self.logger.info(f"Found {len(posts)} posts in r/{subreddit_name}")
            return posts
            
        except Exception as e:
            self.logger.error(f"Subreddit search error: {str(e)}")
            return []
    
    def _search_subreddit_posts(self, subreddit_name: str, query: str, max_results: int) -> List[Dict]:
        """Internal method to search within a subreddit"""
        try:
            posts_data = []
            subreddit = self.reddit.subreddit(subreddit_name)
            
            search_results = subreddit.search(
                query,
                sort="relevance",
                time_filter="all",
                limit=max_results
            )
            
            for post in search_results:
                post_dict = {
                    "id": post.id,
                    "title": post.title,
                    "selftext": post.selftext,
                    "url": post.url,
                    "permalink": f"https://reddit.com{post.permalink}",
                    "subreddit": subreddit_name,
                    "author": str(post.author) if post.author else "[deleted]",
                    "score": post.score,
                    "num_comments": post.num_comments,
                    "created_utc": post.created_utc,
                    "source": "reddit",
                    "snippet": self._create_snippet(post.title, post.selftext)
                }
                posts_data.append(post_dict)
            
            return posts_data
            
        except Exception as e:
            self.logger.error(f"Subreddit search execution error: {str(e)}")
            return []
    
    async def get_hot_posts(self, subreddit_name: str = "all", max_results: int = None) -> List[Dict]:
        """Get hot posts from Reddit"""
        if max_results is None:
            max_results = config.max_search_results
        
        try:
            loop = asyncio.get_event_loop()
            posts = await loop.run_in_executor(
                None,
                self._get_hot_posts,
                subreddit_name,
                max_results
            )
            
            self.logger.info(f"Retrieved {len(posts)} hot posts from r/{subreddit_name}")
            return posts
            
        except Exception as e:
            self.logger.error(f"Hot posts error: {str(e)}")
            return []
    
    def _get_hot_posts(self, subreddit_name: str, max_results: int) -> List[Dict]:
        """Internal method to get hot posts"""
        try:
            posts_data = []
            subreddit = self.reddit.subreddit(subreddit_name)
            
            for post in subreddit.hot(limit=max_results):
                post_dict = {
                    "id": post.id,
                    "title": post.title,
                    "selftext": post.selftext,
                    "url": post.url,
                    "permalink": f"https://reddit.com{post.permalink}",
                    "subreddit": str(post.subreddit),
                    "author": str(post.author) if post.author else "[deleted]",
                    "score": post.score,
                    "num_comments": post.num_comments,
                    "created_utc": post.created_utc,
                    "source": "reddit",
                    "category": "hot",
                    "snippet": self._create_snippet(post.title, post.selftext)
                }
                posts_data.append(post_dict)
            
            return posts_data
            
        except Exception as e:
            self.logger.error(f"Hot posts execution error: {str(e)}")
            return []
    
    async def get_subreddit_info(self, subreddit_name: str) -> Optional[Dict]:
        """Get information about a subreddit"""
        try:
            loop = asyncio.get_event_loop()
            info = await loop.run_in_executor(
                None,
                self._get_subreddit_info,
                subreddit_name
            )
            
            return info
            
        except Exception as e:
            self.logger.error(f"Subreddit info error: {str(e)}")
            return None
    
    def _get_subreddit_info(self, subreddit_name: str) -> Optional[Dict]:
        """Internal method to get subreddit info"""
        try:
            subreddit = self.reddit.subreddit(subreddit_name)
            
            return {
                "name": subreddit.display_name,
                "title": subreddit.title,
                "description": subreddit.public_description,
                "subscribers": subreddit.subscribers,
                "created_utc": subreddit.created_utc,
                "over_18": subreddit.over18,
                "url": f"https://reddit.com/r/{subreddit_name}"
            }
            
        except Exception as e:
            self.logger.error(f"Subreddit info execution error: {str(e)}")
            return None