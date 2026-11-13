import streamlit as st
import asyncio
from ..main import Chimpi
from ..core.logger import chimpi_logger

def create_web_interface():
    """Create Streamlit web interface for Chimpi AI"""
    
    st.set_page_config(
        page_title="Chimpi AI - Your Intelligent Assistant",
        page_icon="🤖",
        layout="wide",
        initial_sidebar_state="expanded"
    )
    
    # Header
    st.title("🤖 Chimpi AI")
    st.subheader("Your Intelligent Question Answering Robot")
    
    # Initialize Chimpi
    @st.cache_resource
    def get_chimpi():
        return Chimpi()
    
    chimpi = get_chimpi()
    
    # Sidebar for settings
    with st.sidebar:
        st.header("Settings")
        
        # Source selection
        st.subheader("Search Sources")
        use_web = st.checkbox("Web Search", value=True)
        use_ai = st.checkbox("AI Models", value=True)
        use_social = st.checkbox("Social Media", value=False)
        
        sources = []
        if use_web:
            sources.append("web")
        if use_ai:
            sources.append("ai")
        if use_social:
            sources.extend(["twitter", "reddit"])
        
        # Advanced settings
        st.subheader("Advanced")
        max_results = st.slider("Max Results", 5, 20, 10)
        show_sources = st.checkbox("Show Sources", value=True)
        
        # API Status
        st.subheader("API Status")
        if chimpi.openai_client:
            st.success("✓ OpenAI")
        else:
            st.warning("✗ OpenAI")
        
        if chimpi.gemini_client:
            st.success("✓ Google Gemini")
        else:
            st.warning("✗ Google Gemini")
        
        if chimpi.twitter_searcher:
            st.success("✓ Twitter")
        else:
            st.warning("✗ Twitter")
        
        if chimpi.reddit_searcher:
            st.success("✓ Reddit")
        else:
            st.warning("✗ Reddit")
    
    # Main interface
    col1, col2 = st.columns([2, 1])
    
    with col1:
        # Question input
        question = st.text_input(
            "Ask Chimpi anything:",
            placeholder="What would you like to know?",
            help="Type your question and press Enter"
        )
        
        # Example questions
        st.markdown("**Example questions:**")
        example_questions = [
            "What's the latest news about artificial intelligence?",
            "How does quantum computing work?",
            "What are people saying about climate change on social media?",
            "Explain the recent developments in space exploration"
        ]
        
        for i, example in enumerate(example_questions):
            if st.button(f"💡 {example}", key=f"example_{i}"):
                question = example
                st.experimental_set_query_params(question=question)
    
    with col2:
        st.markdown("### Quick Actions")
        if st.button("🔍 Search Web"):
            sources = ["web"]
        if st.button("🤖 AI Only"):
            sources = ["ai"]
        if st.button("📱 Social Media"):
            sources = ["twitter", "reddit"]
    
    # Process question
    if question:
        with st.spinner("🔍 Chimpi is searching and thinking..."):
            try:
                # Run async function
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                response = loop.run_until_complete(chimpi.ask(question, sources))
                loop.close()
                
                # Display response
                st.markdown("---")
                st.markdown("### 🤖 Chimpi's Response")
                st.markdown(response["answer"])
                
                # Display metadata
                col1, col2, col3 = st.columns(3)
                with col1:
                    st.metric("Confidence", f"{response.get('confidence', 0):.1%}")
                with col2:
                    st.metric("Sources", len(response.get('sources', [])))
                with col3:
                    st.metric("Results", len(response.get('search_results', {})))
                
                # Show sources if enabled
                if show_sources and response.get('sources'):
                    st.markdown("### 📚 Sources")
                    for i, source in enumerate(response['sources'][:5], 1):
                        with st.expander(f"Source {i}: {source.get('name', 'Unknown')}"):
                            if 'results' in source:
                                for result in source['results'][:3]:
                                    st.markdown(f"**{result.get('title', 'No title')}**")
                                    st.markdown(result.get('snippet', 'No description'))
                                    if result.get('url'):
                                        st.markdown(f"[🔗 View Source]({result['url']})")
                                    st.markdown("---")
                
                # Show detailed results in expander
                if response.get('search_results'):
                    with st.expander("🔍 Detailed Search Results"):
                        for source_name, results in response['search_results'].items():
                            if results:
                                st.markdown(f"#### {source_name.title()} Results")
                                for result in results[:3]:
                                    st.json(result)
                
            except Exception as e:
                st.error(f"An error occurred: {str(e)}")
                chimpi_logger.error(f"Web interface error: {str(e)}")
    
    # Footer
    st.markdown("---")
    st.markdown("**Chimpi AI** - Powered by multiple search engines and AI models")

if __name__ == "__main__":
    create_web_interface()