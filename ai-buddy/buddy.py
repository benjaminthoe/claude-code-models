#!/usr/bin/env python3
"""
Claude AI Buddy - Interactive terminal chatbot powered by Claude.

Usage:
    python buddy.py                  # Start interactive chat
    python buddy.py -m "question"    # Ask a single question
    python buddy.py --model sonnet   # Use a specific model (sonnet/haiku/opus)
"""

import argparse
import os
import sys
import signal
import readline
from datetime import datetime

try:
    from anthropic import Anthropic
except ImportError:
    print("\033[91mError: anthropic package not installed.\033[0m")
    print("Run: pip install anthropic")
    sys.exit(1)

# ─── Theme ───────────────────────────────────────────────────────────────────

COLORS = {
    "reset":    "\033[0m",
    "bold":     "\033[1m",
    "dim":      "\033[2m",
    "cyan":     "\033[36m",
    "magenta":  "\033[35m",
    "green":    "\033[32m",
    "yellow":   "\033[33m",
    "blue":     "\033[34m",
    "red":      "\033[91m",
    "gray":     "\033[90m",
}

MODEL_MAP = {
    "opus":   "claude-opus-4-6",
    "sonnet": "claude-sonnet-4-6",
    "haiku":  "claude-haiku-4-5-20251001",
}

SYSTEM_PROMPT = (
    "You are Claude AI Buddy, a friendly and helpful AI assistant in the terminal. "
    "Keep responses concise and well-formatted for terminal display. "
    "Use markdown sparingly — prefer plain text with clear structure. "
    "Be warm, direct, and genuinely helpful."
)

# ─── Helpers ─────────────────────────────────────────────────────────────────

def c(color: str, text: str) -> str:
    return f"{COLORS.get(color, '')}{text}{COLORS['reset']}"


def print_banner():
    banner = f"""
{c("cyan", "╔══════════════════════════════════════════════╗")}
{c("cyan", "║")}  {c("bold", c("magenta", "Claude AI Buddy"))}                             {c("cyan", "║")}
{c("cyan", "║")}  {c("dim", "Your friendly AI companion in the terminal")}   {c("cyan", "║")}
{c("cyan", "╚══════════════════════════════════════════════╝")}
"""
    print(banner)


def print_help():
    print(f"""
{c("bold", "Commands:")}
  {c("yellow", "/help")}       Show this help message
  {c("yellow", "/clear")}      Clear conversation history
  {c("yellow", "/model")}      Show or switch model (e.g. /model sonnet)
  {c("yellow", "/history")}    Show conversation turn count
  {c("yellow", "/exit")}       Quit AI Buddy

{c("bold", "Tips:")}
  - Press {c("cyan", "Ctrl+C")} to cancel a response
  - Press {c("cyan", "Ctrl+D")} to exit
  - Use {c("cyan", "Up/Down")} arrows to recall previous inputs
""")


# ─── Chat Engine ─────────────────────────────────────────────────────────────

class AIBuddy:
    def __init__(self, model_key: str = "sonnet"):
        self.client = Anthropic()
        self.set_model(model_key)
        self.messages = []

    def set_model(self, model_key: str):
        key = model_key.lower().strip()
        if key in MODEL_MAP:
            self.model = MODEL_MAP[key]
            self.model_label = key.capitalize()
        elif key.startswith("claude-"):
            self.model = key
            self.model_label = key
        else:
            print(c("red", f"Unknown model '{model_key}'. Using Sonnet."))
            self.model = MODEL_MAP["sonnet"]
            self.model_label = "Sonnet"

    def clear(self):
        self.messages = []
        print(c("green", "Conversation cleared."))

    def chat(self, user_input: str) -> str:
        self.messages.append({"role": "user", "content": user_input})

        try:
            print(f"\n{c('magenta', 'Buddy')} {c('dim', '·')} ", end="", flush=True)

            response = self.client.messages.create(
                model=self.model,
                max_tokens=4096,
                system=SYSTEM_PROMPT,
                messages=self.messages,
            )

            reply = response.content[0].text
            self.messages.append({"role": "assistant", "content": reply})

            # Overwrite the "Buddy · " prefix and print full response
            print(f"\r{c('magenta', 'Buddy')} {c('dim', '·')} {reply}\n")
            return reply

        except KeyboardInterrupt:
            print(f"\n{c('yellow', '[response cancelled]')}\n")
            # Remove the unanswered user message
            self.messages.pop()
            return ""
        except Exception as e:
            print(f"\r{c('red', f'Error: {e}')}\n")
            self.messages.pop()
            return ""


# ─── REPL ────────────────────────────────────────────────────────────────────

def repl(buddy: AIBuddy):
    print_banner()
    print(f"  {c('dim', 'Model:')} {c('cyan', buddy.model_label)}  {c('dim', '|')}  {c('dim', 'Type')} {c('yellow', '/help')} {c('dim', 'for commands')}\n")

    # Enable readline history
    histfile = os.path.expanduser("~/.ai_buddy_history")
    try:
        readline.read_history_file(histfile)
    except FileNotFoundError:
        pass
    readline.set_history_length(500)

    try:
        while True:
            try:
                user_input = input(f"{c('green', 'You')} {c('dim', '·')} ").strip()
            except EOFError:
                print(f"\n{c('cyan', 'Goodbye! See you next time.')}")
                break

            if not user_input:
                continue

            # Slash commands
            if user_input.startswith("/"):
                cmd_parts = user_input.split(maxsplit=1)
                cmd = cmd_parts[0].lower()

                if cmd in ("/exit", "/quit", "/q"):
                    print(c("cyan", "Goodbye! See you next time."))
                    break
                elif cmd == "/help":
                    print_help()
                elif cmd == "/clear":
                    buddy.clear()
                elif cmd == "/history":
                    turns = len([m for m in buddy.messages if m["role"] == "user"])
                    print(f"{c('dim', f'Conversation: {turns} turn(s)')}\n")
                elif cmd == "/model":
                    if len(cmd_parts) > 1:
                        buddy.set_model(cmd_parts[1])
                        print(f"{c('green', f'Switched to {buddy.model_label}')}\n")
                    else:
                        print(f"{c('dim', 'Current model:')} {c('cyan', buddy.model_label)} ({buddy.model})")
                        print(f"{c('dim', 'Available: sonnet, haiku, opus')}\n")
                else:
                    print(f"{c('yellow', f'Unknown command: {cmd}. Type /help')}\n")
                continue

            buddy.chat(user_input)

    finally:
        try:
            readline.write_history_file(histfile)
        except OSError:
            pass


# ─── Single-shot mode ───────────────────────────────────────────────────────

def single_shot(buddy: AIBuddy, message: str):
    buddy.chat(message)


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Claude AI Buddy - Terminal Chatbot")
    parser.add_argument("-m", "--message", help="Send a single message and exit")
    parser.add_argument("--model", default="sonnet",
                        help="Model to use: sonnet (default), haiku, opus")
    args = parser.parse_args()

    # Verify API key
    if not os.environ.get("ANTHROPIC_API_KEY"):
        print(c("red", "Error: ANTHROPIC_API_KEY environment variable not set."))
        print(f"Set it with: {c('cyan', 'export ANTHROPIC_API_KEY=your-key-here')}")
        sys.exit(1)

    buddy = AIBuddy(model_key=args.model)

    if args.message:
        single_shot(buddy, args.message)
    else:
        repl(buddy)


if __name__ == "__main__":
    main()
