#!/bin/bash

# Chimpi AI Launcher Script
# Makes it easy to run Chimpi AI in different modes

echo "🤖 Chimpi AI - Intelligent Question Answering Robot"
echo "=================================================="
echo ""

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not found. Please install Python 3."
    exit 1
fi

# Change to script directory
cd "$(dirname "$0")"

# Function to install dependencies
install_deps() {
    echo "📦 Installing dependencies..."
    python3 -m pip install -r requirements.txt
    echo "✅ Dependencies installed!"
    echo ""
}

# Function to check if dependencies are installed
check_deps() {
    python3 -c "
import sys
import os
sys.path.insert(0, '.')
try:
    from chimpi.main import Chimpi
    print('✅ All dependencies are installed')
except ImportError as e:
    print(f'❌ Missing dependencies: {e}')
    print('Run: ./launch.sh install')
    sys.exit(1)
" 2>/dev/null
}

# Menu function
show_menu() {
    echo "Choose how you want to use Chimpi AI:"
    echo ""
    echo "1) 💬 Interactive Chat (Recommended)"
    echo "2) 🌐 Web Interface" 
    echo "3) 💻 Quick Question"
    echo "4) 🔌 API Server"
    echo "5) 🖥️  Simple Desktop Mode"
    echo "6) 📦 Install Dependencies"
    echo "7) ❓ Help"
    echo "8) 🚪 Exit"
    echo ""
    read -p "Enter your choice (1-8): " choice
}

# Main menu loop
while true; do
    show_menu
    
    case $choice in
        1)
            echo "💬 Starting Interactive Chat Mode..."
            echo "📱 Best user experience - like chatting with an AI assistant!"
            echo ""
            check_deps && python3 run_interactive.py
            ;;
        2) 
            echo "🌐 Starting Web Interface..."
            echo "📝 Open your browser to: http://localhost:8501"
            echo "⏹️  Press Ctrl+C to stop"
            echo ""
            check_deps && python3 run_web.py
            ;;
        3)
            echo "💻 Quick Question Mode"
            echo "📝 Enter your question:"
            read -p "Question: " question
            if [ -n "$question" ]; then
                check_deps && python3 run_chimpi.py "$question"
            else
                echo "❌ No question entered"
            fi
            echo ""
            ;;
        4)
            echo "🔌 Starting API Server..."
            echo "📝 API available at: http://localhost:8000"
            echo "📖 Documentation: http://localhost:8000/docs"
            echo "⏹️  Press Ctrl+C to stop"
            echo ""
            check_deps && python3 run_api.py
            ;;
        5)
            echo "🖥️  Starting Simple Desktop Mode..."
            echo "📝 Terminal-based interface (GUI alternative)"
            echo ""
            check_deps && python3 run_gui.py
            ;;
        6)
            install_deps
            ;;
        7)
            echo "❓ Chimpi AI Help"
            echo "================"
            echo ""
            echo "🤖 About Chimpi AI:"
            echo "   Chimpi is an intelligent AI that searches the web,"
            echo "   social media, and uses AI models to answer questions."
            echo ""
            echo "🔧 Setup (Optional but Recommended):"
            echo "   1. Copy .env.example to .env"
            echo "   2. Add your API keys for enhanced functionality:"
            echo "      - OpenAI API key for GPT responses"
            echo "      - Google API key for search and Gemini"
            echo "      - Twitter Bearer token for social media"
            echo "      - Reddit credentials for Reddit search"
            echo ""
            echo "💡 Usage Tips:"
            echo "   - Chimpi works even without API keys"
            echo "   - Be specific in your questions for better results"
            echo "   - Try different interfaces to see what works best"
            echo ""
            echo "📁 Project Structure:"
            echo "   - run_gui.py: Desktop application"
            echo "   - run_web.py: Web interface (Streamlit)"
            echo "   - run_api.py: REST API server"
            echo "   - run_chimpi.py: Command line interface"
            echo ""
            ;;
        8)
            echo "👋 Goodbye! Thanks for using Chimpi AI!"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Please enter 1-8."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to return to menu..."
    clear
done