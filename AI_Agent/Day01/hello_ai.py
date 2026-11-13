
import os
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables from .env
load_dotenv()

# Initialize OpenAI client
client = OpenAI(
    base_url=os.getenv("BASE_URL"),
    api_key=os.getenv("API_KEY")
)

# Send request to OpenAI
response = client.chat.completions.create(
    model=os.getenv("MODEL"),
    messages=[
        {"role": "user", 
         "content": "what is the fundamental of Swift language"
        }
    ]
)

# Print AI response
print(response.choices[0].message.content)
