#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from chimpi.main import Chimpi
import asyncio
import argparse

class ChimpiCLI:
    """Command Line Interface for Chimpi AI"""
    
    def __init__(self):
        self.chimpi = Chimpi()
    
    async def interactive_mode(self):
        """Run Chimpi in interactive mode"""
        print("🤖 Welcome to Chimpi AI!")
        print("Type your questions and I'll search the web and AI models for answers.")
        print("Type 'quit', 'exit', or 'bye' to exit.")
        print("Type 'help' for commands.\n")
        
        while True:
            try:
                question = input("You: ").strip()
                
                if question.lower() in ['quit', 'exit', 'bye', 'q']:
                    print("👋 Goodbye! Thanks for using Chimpi AI!")
                    break
                
                if question.lower() in ['help', 'h']:
                    self.show_help()
                    continue
                
                if question.lower().startswith('sources'):
                    self.show_sources()
                    continue
                
                if not question:
                    continue
                
                print("\n🔍 Searching...")
                response = await self.chimpi.ask(question)
                
                print(f"\n🤖 Chimpi: {response['answer']}")
                
                # Show confidence and sources
                confidence = response.get('confidence', 0)
                sources_count = len(response.get('sources', []))
                
                print(f"\n📊 Confidence: {confidence:.1%} | Sources: {sources_count}")
                
                # Show top sources
                if response.get('sources'):
                    print("\n📚 Top Sources:")
                    for i, source in enumerate(response['sources'][:3], 1):
                        name = source.get('name', 'Unknown')
                        count = source.get('count', 0)
                        print(f"   {i}. {name} ({count} results)")
                
                print("\n" + "-"*50 + "\n")
                
            except KeyboardInterrupt:
                print("\n\n👋 Goodbye!")
                break
            except Exception as e:
                print(f"\n❌ Error: {str(e)}")
                print("Please try again or type 'help' for assistance.\n")
    
    async def single_question(self, question: str, sources: list = None):
        """Process a single question"""
        try:
            print(f"🔍 Processing: {question}")
            response = await self.chimpi.ask(question, sources)
            
            print(f"\n🤖 Answer: {response['answer']}")
            
            # Show metadata
            confidence = response.get('confidence', 0)
            sources_count = len(response.get('sources', []))
            print(f"\n📊 Confidence: {confidence:.1%} | Sources: {sources_count}")
            
            return response
            
        except Exception as e:
            print(f"❌ Error: {str(e)}")
            return None
    
    def show_help(self):
        """Show help information"""
        help_text = """
🤖 Chimpi AI Commands:
        
Basic Usage:
  - Just type your question and press Enter
  - Ask anything: news, facts, explanations, etc.
  
Commands:
  help, h          - Show this help
  sources          - Show available search sources
  quit, exit, bye  - Exit Chimpi AI
  
Examples:
  "What's the latest news about AI?"
  "How does quantum computing work?"
  "What are people saying about climate change?"
  
Tips:
  - Be specific in your questions for better results
  - Chimpi searches web, social media, and uses AI models
  - Results are aggregated from multiple sources
        """
        print(help_text)
    
    def show_sources(self):
        """Show available sources"""
        print("\n📡 Available Sources:")
        
        sources = {
            "Web Search": bool(self.chimpi.web_searcher),
            "OpenAI GPT": bool(self.chimpi.openai_client),
            "Google Gemini": bool(self.chimpi.gemini_client),
            "Twitter": bool(self.chimpi.twitter_searcher),
            "Reddit": bool(self.chimpi.reddit_searcher)
        }
        
        for source, available in sources.items():
            status = "✅ Available" if available else "❌ Not configured"
            print(f"   {source}: {status}")
        print()

def main():
    """Main CLI function"""
    parser = argparse.ArgumentParser(description="Chimpi AI - Intelligent Question Answering")
    parser.add_argument('question', nargs='*', help='Question to ask Chimpi')
    parser.add_argument('--sources', nargs='+', help='Specify sources: web, twitter, reddit, ai')
    parser.add_argument('--interactive', '-i', action='store_true', help='Run in interactive mode')
    
    args = parser.parse_args()
    
    cli = ChimpiCLI()
    
    async def run_cli():
        if args.interactive or not args.question:
            await cli.interactive_mode()
        else:
            question = ' '.join(args.question)
            await cli.single_question(question, args.sources)
    
    try:
        asyncio.run(run_cli())
    except KeyboardInterrupt:
        print("\n👋 Goodbye!")
    except Exception as e:
        print(f"❌ Fatal error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()