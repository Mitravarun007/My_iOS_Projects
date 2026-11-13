#!/usr/bin/env python3

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from chimpi.main import Chimpi
import asyncio

async def main():
    chimpi = Chimpi()
    
    if len(sys.argv) > 1:
        question = " ".join(sys.argv[1:])
        response = await chimpi.ask(question)
        
        print(f"\n🤖 Chimpi's Response:")
        print(f"{response['answer']}\n")
        
        if response.get('sources'):
            print("📚 Sources:")
            for source in response['sources'][:3]:
                print(f"  • {source.get('name', 'Unknown')}")
    else:
        print("🤖 Chimpi AI - Intelligent Question Answering Robot")
        print("Usage: python3 run_chimpi.py 'Your question here'")
        print("Example: python3 run_chimpi.py 'What is artificial intelligence?'")

if __name__ == "__main__":
    asyncio.run(main())