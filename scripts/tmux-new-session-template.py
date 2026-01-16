# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "rich",
#     "typer",
#     "jinja2",
# ]
# ///

# TODO: unify with tmux-select-session.sh script
# TODO: Add option to edit the template in the editor before saving
# TODO: Add an option to create a new template for this session but not save it in tmuxinator sessions

import pathlib

import jinja2
from rich.prompt import Prompt, Confirm
from rich.console import Console
from rich.syntax import Syntax
import typer

TMUXINATOR_SESSIONS_DIR = pathlib.Path.home() / ".config" / "tmuxinator"
TMUXINATOR_TEMPLATE = TMUXINATOR_SESSIONS_DIR / "_template.yml.jinja"

if not TMUXINATOR_TEMPLATE.exists():
    print(f"Error: Template file '{TMUXINATOR_TEMPLATE}' does not exist.")
    exit(1)

console = Console(force_interactive=True)

def ask_for_path(prompt: str, *, default: str) -> pathlib.Path:
    while True:
        input = Prompt.ask(prompt, default=default)

        try:
            root_path = pathlib.Path(input)
        except Exception as e:
            console.print(f"[bold red]Error:[/] Invalid path: {e.__class__.__name__}: {e}")
            continue

        if not root_path.expanduser().resolve().exists():
            console.print(f"[bold yellow]WARNING:[/] The path [bold green]{root_path}[/] does not exist.")
            confirm = Prompt.ask("Do you want to create it first?", choices=["y", "n"], default="y", case_sensitive=False)

            if confirm.lower() == "y":
                root_path.expanduser().resolve().mkdir(parents=True, exist_ok=True)
                console.print(f"Created path: [bold green]{root_path}[/]")

        return root_path

def generate_template(**kwargs) -> str:
    template_content = TMUXINATOR_TEMPLATE.read_text()
    template = jinja2.Template(template_content)
        
    return template.render(**kwargs)

def main(session_name: str | None = typer.Argument(None, help="Name of the tmux session to create")):
    if not session_name:
        session_name = console.input("Enter the tmux session name: ")

    existing_templates = [
        f
        for ext in ["yml", "yaml"]
        for f in TMUXINATOR_SESSIONS_DIR.glob(f"*.{ext}", case_sensitive=False)
    ]

    if session_name.lower() in [t.stem.lower() for t in existing_templates]:
        console.print(
            f"[bold red]Error:[/] A template with the name [bold green]{session_name}[/] already exists."
        )
        exit(1)

    root_path = ask_for_path("Enter the root path for the session", default=f"~/dev/side/{session_name}")

    rendered_content = generate_template(
        name=session_name,
        root=root_path,
    )

    console.print("\nGenerated tmux session configuration:\n")
    console.print(Syntax(rendered_content, "yaml", theme="monokai"))
    console.print()

    if not Confirm.ask("Do you want to save this configuration?", default=True):
        console.print("[bold red]Aborting without saving.[/]")
        exit(1)

    output_file = TMUXINATOR_SESSIONS_DIR / f"{session_name}.yml"
    output_file.write_text(rendered_content)

    console.print(f"[bold green]Success:[/] Session configuration saved to [bold green]{output_file}[/]")
    

if __name__ == "__main__":
    typer.run(main)
