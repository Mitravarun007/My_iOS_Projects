<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Chimpi AI Project

This is an intelligent AI chatbot project called "Chimpi" that can search the web, social media platforms, and integrate with various AI APIs to provide comprehensive answers to user questions.

## Project Structure

- `chimpi/` - Main package directory
  - `main.py` - Core Chimpi AI class and CLI entry point
  - `core/` - Configuration, logging, and database modules
  - `ai/` - AI service integrations (OpenAI, Google Gemini, GitHub Copilot)
  - `search/` - Web search and result aggregation
  - `social/` - Social media integrations (Twitter, Reddit)
  - `interfaces/` - Various user interfaces (CLI, Web, API)
  - `utils/` - Utility functions for text processing

## Quick Start

1. **Setup Environment Variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Run Chimpi**:
   ```bash
   # CLI Interface
   python3 run_chimpi.py "Your question here"
   
   # Web Interface
   python3 run_web.py
   
   # API Server
   python3 run_api.py
   ```

## Features

- 🔍 Web search integration (Google, Bing)
- 🤖 AI model integration (OpenAI GPT, Google Gemini)
- 📱 Social media search (Twitter, Reddit)
- 💬 Multiple interfaces (CLI, Web UI, REST API)
- 📊 Result aggregation and analysis
- 🎯 Intelligent response generation

## Development Guidelines

- All API integrations are optional and gracefully handle missing credentials
- Async/await patterns used throughout for better performance
- Comprehensive error handling and logging
- Modular design for easy extension and testing
- Configuration managed through environment variables