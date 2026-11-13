# Chimpi AI - Intelligent Question Answering Robot

Chimpi is an AI-powered chatbot that can search the web, social media platforms, and integrate with various AI services to provide comprehensive answers to your questions.

## Features

- 🔍 **Web Search**: Google, Bing search integration
- 📱 **Social Media**: Twitter, Reddit, Instagram, Facebook integration
- 🤖 **AI Integration**: OpenAI GPT, Google Gemini, GitHub Copilot API
- 💬 **Multiple Interfaces**: CLI, Web UI, Discord Bot, Telegram Bot
- 🌐 **Web Scraping**: Intelligent content extraction
- 📊 **Analytics**: Search result analysis and insights
- ⚡ **Real-time**: Async processing for fast responses

## Quick Start

1. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Setup Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

3. **Run Chimpi**
   ```bash
   # CLI Interface
   python chimpi/main.py

   # Web Interface
   streamlit run chimpi/web_interface.py

   # API Server
   uvicorn chimpi.api:app --reload
   ```

## Configuration

Create a `.env` file with your API keys:
- OpenAI API key for GPT integration
- Google API key for Gemini and Search
- Social media platform tokens
- GitHub token for Copilot API access

## Project Structure

```
chimpi_ai/
├── chimpi/
│   ├── __init__.py
│   ├── main.py              # CLI interface
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py        # Configuration management
│   │   ├── logger.py        # Logging setup
│   │   └── database.py      # Database models
│   ├── ai/
│   │   ├── __init__.py
│   │   ├── openai_client.py # OpenAI integration
│   │   ├── gemini_client.py # Google Gemini integration
│   │   └── copilot_client.py # GitHub Copilot integration
│   ├── search/
│   │   ├── __init__.py
│   │   ├── web_search.py    # Google/Bing search
│   │   ├── scraper.py       # Web scraping
│   │   └── aggregator.py    # Result aggregation
│   ├── social/
│   │   ├── __init__.py
│   │   ├── twitter.py       # Twitter integration
│   │   ├── reddit.py        # Reddit integration
│   │   ├── instagram.py     # Instagram integration
│   │   └── facebook.py      # Facebook integration
│   ├── interfaces/
│   │   ├── __init__.py
│   │   ├── cli.py           # Command line interface
│   │   ├── web_interface.py # Streamlit web UI
│   │   ├── discord_bot.py   # Discord bot
│   │   └── telegram_bot.py  # Telegram bot
│   └── utils/
│       ├── __init__.py
│       ├── text_processor.py # NLP utilities
│       └── cache.py         # Caching system
├── tests/
├── docs/
├── requirements.txt
├── .env.example
├── .gitignore
└── README.md
```

## Usage Examples

### CLI
```bash
python chimpi/main.py "What's the latest news about AI?"
```

### Python API
```python
from chimpi import Chimpi

chimpi = Chimpi()
response = await chimpi.ask("Explain quantum computing")
print(response.answer)
```

### Web Interface
Visit http://localhost:8501 after running `streamlit run chimpi/web_interface.py`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

For support, please open an issue on GitHub or contact the development team.