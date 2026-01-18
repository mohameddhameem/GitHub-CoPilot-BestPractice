# Multi-Stack Starter Kit

![VS Code](https://img.shields.io/badge/IDE-Visual%20Studio%20Code-007ACC?logo=visual-studio-code) ![IntelliJ IDEA](https://img.shields.io/badge/IDE-IntelliJ%20IDEA-000000?logo=intellij-idea)

A reference workspace demonstrating GitHub Copilot custom instructions across a multi-project repository. Includes skeletons for React frontend, FastAPI backend, PyTorch inference backend, and Ansible infrastructure.

## Structure

```
.github/
  copilot-instructions.md         # Root Copilot guidance
  instructions/
    python.instructions.md        # All Python files
    fastapi.instructions.md       # FastAPI backend
    pytorch.instructions.md       # PyTorch backend
    typescript.instructions.md    # React/TypeScript files
    ansible.instructions.md       # Ansible YAML files
  prompts/                        # Reusable prompt templates
    code-review.prompt.md
    new-feature.prompt.md
    debug.prompt.md
AGENTS.md                         # AI agent guidance (root)
ansible-infra/                    # Ansible playbooks and roles
  AGENTS.md
fastapi-backend/                  # FastAPI REST API
  AGENTS.md
pytorch-ai-backend/               # PyTorch model inference service
  AGENTS.md
react-frontend/                   # React TypeScript frontend
  AGENTS.md
```

Path-specific instructions under `.github/instructions/` load automatically based on file type using `applyTo` globs.

## Features

- **Copilot Custom Instructions**: Stack-specific guidance for Python, FastAPI, PyTorch, TypeScript, and Ansible
- **AGENTS.md Support**: Hierarchical agent guidance (nearest-first) for AI coding assistants
- **Prompt Templates**: Reusable prompts for code review, feature implementation, and debugging
- **MCP Ready**: Model Context Protocol integration for enhanced AI agent capabilities

## Setup

1. Run the setup script for your platform:
   - Windows: `.\setup_script.ps1`
   - WSL/macOS/Linux: `./setup_script.sh`

2. Copy `pyproject_toml.txt` to `pyproject.toml` in each Python project.

3. **VS Code**: The repository includes a `.vscode` folder with all settings pre-configured. Open the folder in VS Code and the recommended extensions prompt will appear.

4. **IntelliJ / PyCharm / WebStorm**: The `.editorconfig` file provides universal code style settings. Install the EditorConfig plugin if not already enabled.

   > **Note**: GitHub Copilot custom instructions (`.github/instructions/`) are VS Code-specific. JetBrains users can configure Copilot instructions via **Settings → Tools → GitHub Copilot → Customizations**.

5. Install pre‑commit hooks:
   ```bash
   pre-commit install
   pre-commit run --all-files
   ```

## Tooling

| Stack   | Lint/Format              | Test                    |
|---------|--------------------------|-------------------------|
| Python  | ruff, black              | pytest, pytest-asyncio  |
| React   | ESLint, Prettier         | React Testing Library   |
| Ansible | ansible-lint, yamllint   | Molecule                |

## MCP Integration

This repository supports [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) for enhanced AI agent capabilities. Configure MCP servers in `.vscode/mcp.json` to connect external tools and services.

## License

MIT License. See [LICENSE](LICENSE).
