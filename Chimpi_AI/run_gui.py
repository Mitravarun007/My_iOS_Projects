#!/usr/bin/env python3
"""
Chimpi AI - Simple Terminal-based Interactive Interface
Compatible fallback when GUI is not available
"""

import sys
import os
import asyncio
from datetime import datetime

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from chimpi.main import Chimpi

class ChimpiInteractive:
    def __init__(self):
        self.chimpi = Chimpi()
        
    def clear_screen(self):
        os.system('clear' if os.name == 'posix' else 'cls')
    
    def print_header(self):
        print("=" * 60)
        print("🤖 CHIMPI AI - INTELLIGENT ASSISTANT")
        print("=" * 60)
        print("💡 Ask me anything and I'll search the web & use AI to help!")
        print("⚡ Type 'quit', 'exit', or 'q' to exit")
        print("🔄 Type 'clear' to clear screen")
        print("❓ Type 'help' for tips")
        print("=" * 60)
        print()
    
    def show_examples(self):
        examples = [
            "What's the latest news about artificial intelligence?",
            "How does quantum computing work?", 
            "Explain machine learning in simple terms",
            "What are the benefits of renewable energy?",
            "Latest developments in space exploration"
        ]
        
        print("💡 Example Questions:")
        for i, example in enumerate(examples, 1):
            print(f"   {i}. {example}")
        print()
        
        choice = input("Choose an example (1-5) or press Enter to type your own: ").strip()
        if choice.isdigit() and 1 <= int(choice) <= 5:
            return examples[int(choice) - 1]
        return None
    
    def show_help(self):
        print("""
🤖 CHIMPI AI HELP
================

What Chimpi can do:
• Search the web for current information
• Use AI models for detailed explanations  
• Check social media for trending topics
• Analyze and summarize from multiple sources

Tips for better results:
• Be specific in your questions
• Ask one thing at a time
• Use clear, simple language

Commands:
• 'examples' - Show example questions
• 'clear' - Clear the screen
• 'help' - Show this help
• 'quit', 'exit', 'q' - Exit the program

Example questions:
• "What is [topic]?"
• "How does [technology] work?"  
• "Latest news about [subject]"
• "Explain [concept] simply"
""")
    
    async def process_question(self, question):
        print(f"\n🔍 Processing: {question}")
        print("=" * 50)
        print("⏳ Searching and analyzing... (this may take a moment)")
        
        try:
            response = await self.chimpi.ask(question)
            
            print("\n🤖 CHIMPI'S RESPONSE:")
            print("=" * 50)
            print(response['answer'])
            
            if response.get('sources'):
                print(f"\n📚 SOURCES ({len(response['sources'])} found):")
                print("-" * 30)
                for i, source in enumerate(response['sources'][:5], 1):
                    name = source.get('name', 'Unknown')
                    count = source.get('count', 0)
                    print(f"   {i}. {name} ({count} results)")
            
            confidence = response.get('confidence', 0)
            print(f"\n📊 Confidence Score: {confidence:.1%}")
            
        except Exception as e:
            print(f"\n❌ Sorry, I encountered an error: {str(e)}")
            print("💡 Please check your internet connection and try again.")
        
        print("\n" + "=" * 60)
    
    def run(self):
        self.clear_screen()
        self.print_header()
        
        while True:
            try:
                print("What would you like to know?")
                question = input("👤 Ask Chimpi: ").strip()
                
                if not question:
                    continue
                
                if question.lower() in ['quit', 'exit', 'q', 'bye']:
                    print("\n👋 Goodbye! Thanks for using Chimpi AI!")
                    break
                
                if question.lower() == 'clear':
                    self.clear_screen()
                    self.print_header()
                    continue
                
                if question.lower() == 'help':
                    self.show_help()
                    continue
                
                if question.lower() == 'examples':
                    example = self.show_examples()
                    if example:
                        question = example
                    else:
                        continue
                
                # Process the question
                asyncio.run(self.process_question(question))
                
            except KeyboardInterrupt:
                print("\n\n👋 Goodbye!")
                break
            except Exception as e:
                print(f"\n❌ Unexpected error: {str(e)}")
                continue

def main():
    try:
        # Try to import tkinter for GUI
        import tkinter as tk
        from tkinter import ttk, scrolledtext, messagebox
        import threading
        
        print("🖥️  Starting Desktop GUI...")
        # If tkinter works, we could start GUI here, but given the macOS issue,
        # let's use the interactive terminal version
        raise ImportError("Using terminal interface for better compatibility")
        
    except ImportError:
        print("💻 Starting Interactive Terminal Interface...")
        print("📝 (GUI not available on this system, using terminal mode)")
        print()
        
        app = ChimpiInteractive()
        app.run()

if __name__ == "__main__":
    main()