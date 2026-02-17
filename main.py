import openai
import os
from dotenv import load_dotenv
from rich.console import Console
from rich.panel import Panel
from rich.markdown import Markdown
from rich.live import Live
from rich.spinner import Spinner

# Initialize Rich console
console = Console()

# Load environment variables
load_dotenv()

# Get API Key from environment
API_KEY = os.getenv("NVIDIA_API_KEY")

if not API_KEY:
    console.print("[bold red]Error:[/] NVIDIA_API_KEY not found in .env file.", style="red")
    exit(1)

# Initialize the client for NVIDIA API (OpenAI Compatible)
client = openai.OpenAI(
    base_url="https://integrate.api.nvidia.com/v1",
    api_key=API_KEY
)

def chat():
    console.print(Panel.fit(
        "[bold green]NVIDIA Premium CLI Chatbot[/]\n"
        "[dim]Powered by Meta Llama 3.1 8B via NVIDIA NIM[/]",
        border_style="bright_green"
    ))
    console.print("Type [bold red]'exit'[/], [bold red]'quit'[/], or [bold red]'bye'[/] to end.\n")
    
    # Initialize conversation history
    messages = [
        {"role": "system", "content": "You are a helpful and friendly AI assistant. Use markdown for better formatting when appropriate."}
    ]

    while True:
        try:
            # Get user input
            user_input = console.input("[bold yellow]You:[/] ").strip()
            
            if user_input.lower() in ['exit', 'quit', 'bye']:
                console.print("\n[bold yellow]Bot:[/] Goodbye! Have a great day! 👋")
                break
                
            if not user_input:
                continue

            # Add user message to history
            messages.append({"role": "user", "content": user_input})

            # Get response from NVIDIA with a spinner
            with console.status("[bold blue]Thinking...", spinner="dots"):
                response = client.chat.completions.create(
                    model="meta/llama-3.1-8b-instruct",
                    messages=messages,
                    temperature=0.2,
                    top_p=0.7,
                    max_tokens=1024,
                )

            # Extract the response text
            bot_response = response.choices[0].message.content
            
            console.print("\n[bold sky_blue1]Assistant:[/]")
            console.print(Markdown(bot_response))
            console.print("-" * 50 + "\n")

            # Add bot response to history
            messages.append({"role": "assistant", "content": bot_response})

        except KeyboardInterrupt:
            console.print("\n[bold yellow]Bot:[/] Session ended. Goodbye! 👋")
            break
        except Exception as e:
            console.print(f"\n[bold red]Error:[/] {str(e)}")
            break

if __name__ == "__main__":
    chat()
