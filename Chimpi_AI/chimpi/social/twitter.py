import tweepy
import asyncio
from typing import List, Dict, Optional
from ..core.config import config
from ..core.logger import chimpi_logger

class TwitterSearcher:
    """Twitter search functionality using Tweepy"""
    
    def __init__(self):
        self.logger = chimpi_logger
        self.bearer_token = config.twitter_bearer_token
        
        if not self.bearer_token:
            raise ValueError("Twitter Bearer Token not found in configuration")
        
        # Initialize Twitter API client
        self.client = tweepy.Client(bearer_token=self.bearer_token, wait_on_rate_limit=True)
    
    async def search(self, query: str, max_results: int = None) -> List[Dict]:
        """
        Search Twitter for tweets related to the query
        
        Args:
            query: Search query
            max_results: Maximum number of results to return
        
        Returns:
            List of tweet data
        """
        if max_results is None:
            max_results = min(config.max_search_results, 100)  # Twitter API limit
        
        try:
            # Run Twitter search in executor to avoid blocking
            loop = asyncio.get_event_loop()
            tweets = await loop.run_in_executor(
                None, 
                self._search_tweets, 
                query, 
                max_results
            )
            
            self.logger.info(f"Found {len(tweets)} tweets for query: {query}")
            return tweets
            
        except Exception as e:
            self.logger.error(f"Twitter search error: {str(e)}")
            return []
    
    def _search_tweets(self, query: str, max_results: int) -> List[Dict]:
        """Internal method to search tweets (runs in executor)"""
        try:
            # Search for tweets
            tweets = tweepy.Paginator(
                self.client.search_recent_tweets,
                query=query,
                tweet_fields=['created_at', 'author_id', 'public_metrics', 'context_annotations', 'lang'],
                user_fields=['name', 'username', 'verified'],
                expansions=['author_id'],
                max_results=min(max_results, 100)
            ).flatten(limit=max_results)
            
            # Process results
            tweet_data = []
            users_dict = {}
            
            # Get user information if available
            includes = getattr(tweets, 'includes', {})
            if 'users' in includes:
                for user in includes['users']:
                    users_dict[user.id] = user
            
            for tweet in tweets:
                # Get user info
                user_info = users_dict.get(tweet.author_id, {})
                
                tweet_dict = {
                    "id": tweet.id,
                    "text": tweet.text,
                    "created_at": tweet.created_at.isoformat() if tweet.created_at else "",
                    "author": {
                        "id": tweet.author_id,
                        "name": getattr(user_info, 'name', ''),
                        "username": getattr(user_info, 'username', ''),
                        "verified": getattr(user_info, 'verified', False)
                    },
                    "metrics": {
                        "retweet_count": tweet.public_metrics.get('retweet_count', 0) if tweet.public_metrics else 0,
                        "like_count": tweet.public_metrics.get('like_count', 0) if tweet.public_metrics else 0,
                        "reply_count": tweet.public_metrics.get('reply_count', 0) if tweet.public_metrics else 0
                    },
                    "url": f"https://twitter.com/i/status/{tweet.id}",
                    "source": "twitter",
                    "language": getattr(tweet, 'lang', 'en')
                }
                
                # Add context annotations if available
                if hasattr(tweet, 'context_annotations') and tweet.context_annotations:
                    contexts = []
                    for annotation in tweet.context_annotations:
                        if hasattr(annotation, 'entity') and annotation.entity:
                            contexts.append(annotation.entity.get('name', ''))
                    tweet_dict["contexts"] = contexts
                
                tweet_data.append(tweet_dict)
            
            return tweet_data
            
        except Exception as e:
            self.logger.error(f"Tweet search execution error: {str(e)}")
            return []
    
    async def get_trending_topics(self, location_id: int = 1) -> List[Dict]:
        """Get trending topics (requires API v1.1)"""
        try:
            # Note: This would require Twitter API v1.1 authentication
            # For now, return empty list as v2 doesn't have trends endpoint
            self.logger.warning("Trending topics requires Twitter API v1.1 - not implemented")
            return []
            
        except Exception as e:
            self.logger.error(f"Trending topics error: {str(e)}")
            return []
    
    async def search_users(self, query: str) -> List[Dict]:
        """Search for Twitter users"""
        try:
            loop = asyncio.get_event_loop()
            users = await loop.run_in_executor(
                None,
                self._search_users,
                query
            )
            
            self.logger.info(f"Found {len(users)} users for query: {query}")
            return users
            
        except Exception as e:
            self.logger.error(f"User search error: {str(e)}")
            return []
    
    def _search_users(self, query: str) -> List[Dict]:
        """Internal method to search users"""
        try:
            # Note: User search is limited in Twitter API v2
            # This is a placeholder implementation
            self.logger.warning("User search has limited functionality in Twitter API v2")
            return []
            
        except Exception as e:
            self.logger.error(f"User search execution error: {str(e)}")
            return []