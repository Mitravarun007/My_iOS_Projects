#!/usr/bin/env python3
"""
Chimpi AI - Interactive Chat Interface
Better alternative to GUI with rich terminal experience
"""

import sys
import os
import asyncio
from datetime import datetime

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from chimpi.main import Chimpi

class ChimpiChat:
    def __init__(self):
        self.chimpi = Chimpi()
        
    def clear_screen(self):
        os.system('clear' if os.name == 'posix' else 'cls')
    
    def print_banner(self):
        banner = """
╔══════════════════════════════════════════════════════════════╗
║                    🤖 CHIMPI AI ASSISTANT                    ║
║                                                              ║
║    Your Intelligent Question Answering Robot                 ║
║    • Web Search  • AI Analysis  • Social Media              ║
╚══════════════════════════════════════════════════════════════╝
"""
        print(banner)
        
    def show_welcome(self):
        print("🎉 Welcome! I can help you with:")
        print("   🔍 Current news and information")
        print("   📚 Explanations of complex topics") 
        print("   🌐 Web search and analysis")
        print("   📱 Social media trends")
        print()
        print("💡 Commands:")
        print("   • Type any question to get started")
        print("   • 'examples' - See example questions")
        print("   • 'help' - Get help and tips")
        print("   • 'clear' - Clear the screen")
        print("   • 'quit' - Exit")
        print()
        
    def show_examples(self):
        examples = [
            "What's the latest news about artificial intelligence?",
            "How does quantum computing work?",
            "Explain blockchain technology simply",
            "What are the benefits of renewable energy?",
            "Current trends in space exploration",
            "How does machine learning work?",
            "What is climate change and its effects?",
            "Latest developments in medicine"
        ]
        
        print("\n💡 EXAMPLE QUESTIONS:")
        print("=" * 50)
        for i, example in enumerate(examples, 1):
            print(f"   {i}. {example}")
        print("=" * 50)
        
        while True:
            choice = input("\n🎯 Choose example (1-8), or press Enter for custom question: ").strip()
            
            if not choice:
                return None
            
            if choice.isdigit() and 1 <= int(choice) <= len(examples):
                return examples[int(choice) - 1]
            
            print("❌ Invalid choice. Please enter 1-8 or press Enter.")
    
    def show_help(self):
        help_text = """
🤖 CHIMPI AI HELP GUIDE
======================

🎯 WHAT CHIMPI CAN DO:
━━━━━━━━━━━━━━━━━━━━━━
• Search Google and Bing for current information
• Use AI models (OpenAI GPT, Google Gemini) for analysis
• Check Twitter and Reddit for social media trends  
• Combine multiple sources for comprehensive answers
• Explain complex topics in simple terms

💡 TIPS FOR BETTER RESULTS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Be specific in your questions
• Ask one topic at a time
• Use clear, simple language
• Try rephrasing if results aren't what you expected

🔥 EXAMPLE QUESTION TYPES:
━━━━━━━━━━━━━━━━━━━━━━━━━━
• "What is [topic]?" - Get definitions and explanations
• "How does [technology] work?" - Understand processes
• "Latest news about [subject]" - Get current information
• "Benefits of [concept]" - Learn advantages
• "Explain [complex topic] simply" - Get easy explanations

⚡ QUICK COMMANDS:
━━━━━━━━━━━━━━━━━━
• 'examples' - Show example questions
• 'clear' - Clear the screen
• 'help' - Show this help
• 'quit', 'exit', 'q' - Exit Chimpi

🔧 SETUP (OPTIONAL):
━━━━━━━━━━━━━━━━━━━━
For enhanced features, add API keys to .env file:
• OpenAI API key for GPT responses
• Google API key for enhanced search
• Social media tokens for trend analysis

Note: Chimpi works great even without API keys! 🚀
"""
        print(help_text)
    
    def format_response(self, response):
        """Format the response in a nice, readable way"""
        print("\n" + "="*60)
        print("🤖 CHIMPI'S RESPONSE")
        print("="*60)
        
        # Main answer
        print(response['answer'])
        
        # Sources section
        if response.get('sources'):
            print(f"\n📚 INFORMATION SOURCES ({len(response['sources'])} found):")
            print("-" * 40)
            for i, source in enumerate(response['sources'][:5], 1):
                name = source.get('name', 'Unknown Source')
                count = source.get('count', 0)
                print(f"   {i}. {name} ({count} results)")
        
        # Confidence and metadata
        confidence = response.get('confidence', 0)
        print(f"\n📊 Confidence Level: {confidence:.1%}")
        
        # Timestamp
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"⏰ Response generated at: {timestamp}")
        print("="*60)
    
    async def process_question(self, question):
        print(f"\n🔍 Processing: {question}")
        print("⏳ Searching web, analyzing data, generating response...")
        print("   (This may take 10-30 seconds depending on complexity)")
        
        try:
            response = await self.chimpi.ask(question)
            self.format_response(response)
            
        except Exception as e:
            print("\n" + "="*60)
            print("❌ ERROR OCCURRED")
            print("="*60)
            print(f"Sorry, I encountered an issue: {str(e)}")
            print("\n💡 Troubleshooting:")
            print("   • Check your internet connection")
            print("   • Try rephrasing your question")
            print("   • Make sure you have the required dependencies")
            print("="*60)
    
    def run(self):
        """Main interactive loop"""
        self.clear_screen()
        self.print_banner()
        self.show_welcome()
        
        print("🚀 Ready! What would you like to know?")
        
        while True:
            try:
                print("\n" + "-"*40)
                question = input("👤 Ask Chimpi: ").strip()
                
                if not question:
                    print("💬 Please enter a question or command.")
                    continue
                
                # Handle commands
                if question.lower() in ['quit', 'exit', 'q', 'bye']:
                    print("\n👋 Thank you for using Chimpi AI!")
                    print("🌟 Come back anytime for more intelligent assistance!")
                    break
                
                elif question.lower() == 'clear':
                    self.clear_screen()
                    self.print_banner()
                    print("🧹 Screen cleared! Ready for new questions.")
                    continue
                
                elif question.lower() == 'help':
                    self.show_help()
                    continue
                
                elif question.lower() == 'examples':
                    example = self.show_examples()
                    if example:
                        question = example
                        print(f"\n✨ Selected: {question}")
                    else:
                        continue
                
                # Process the question
                asyncio.run(self.process_question(question))
                
            except KeyboardInterrupt:
                print("\n\n👋 Goodbye! Thanks for using Chimpi AI!")
                break
                
            except Exception as e:
                print(f"\n❌ Unexpected error: {str(e)}")
                print("💡 Please try again or type 'help' for assistance.")

def main():
    print("💻 Starting Chimpi AI Interactive Chat...")
    print("📱 Best alternative to GUI - full-featured terminal interface!")
    
    try:
        chat = ChimpiChat()
        chat.run()
    except Exception as e:
        print(f"❌ Failed to start Chimpi: {str(e)}")
        print("💡 Try running: python3 run_chimpi.py 'test question'")

if __name__ == "__main__":
    main()