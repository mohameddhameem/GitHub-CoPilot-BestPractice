# GitHub Copilot Instructions - Workspace Root

## Scope and Navigation
Multi-project repo: React frontend, FastAPI backend, PyTorch inference, Ansible infra. Keep ownership boundaries strict.

**Instruction Loading:**
- Root: this file
- Path-specific: `.github/instructions/<stack>.instructions.md` (auto-loaded via `applyTo` globs)
- Agent mode: `AGENTS.md` files (nearest-first)
- Prompts: `.github/prompts/*.prompt.md` (when `chat.promptFiles` enabled)

## Setup
1. Run `./setup_script.sh` (Linux/macOS) or `.\setup_script.ps1` (Windows)
2. Copy `pyproject_toml.txt` to `pyproject.toml` in Python projects
3. Apply workspace settings from `vscode_settings.json`

## Shared Standards
- Line length: 120 | Organized imports | Typed code | No emojis
- Structured logging with context; never log secrets/PII
- Branch naming: `feature/<name>`, `bugfix/<id>`, `chore/<desc>`
- Commits: small, present tense

## Service Boundaries
| Service | Responsibility |
|---------|---------------|
| React | UI/UX, client data-fetching |
| FastAPI | Business APIs, data access |
| PyTorch | Inference only |
| Ansible | Deployment, config |

## Formatting
```bash
# Python
ruff check . --fix && black .

# React
npm run lint && npm run format

# Ansible
ansible-lint && yamllint ansible-infra
```

## MCP Integration
This repo supports [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) for enhanced AI agent capabilities. Configure MCP servers in `.vscode/mcp.json` to:
- Connect to external documentation
- Query database schemas
- Integrate with CI/CD systems

## Documentation
- Update README per project when APIs/behavior change
- Add new conventions to relevant `.github/instructions/` files
