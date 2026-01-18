# AGENTS.md - Multi-Stack Starter Kit

This file provides guidance for AI coding agents (GitHub Copilot Agent mode, Gemini Code Assist, etc.) when working across this multi-project repository.

## Repository Overview

| Project | Tech | Purpose |
|---------|------|---------|
| `fastapi-backend/` | Python, FastAPI | Business APIs and data access |
| `pytorch-ai-backend/` | Python, PyTorch | Model inference service |
| `react-frontend/` | TypeScript, React | User interface |
| `ansible-infra/` | Ansible | Infrastructure automation |

## Agent Guidelines

### Code Changes
1. **Stay in scope**: Only modify files within the project you're working on
2. **Follow stack instructions**: Each project has `.github/instructions/<stack>.instructions.md`
3. **Run formatters**: Always run the project's lint/format commands before committing

### Cross-Project Work
- API contracts between frontend and backend must be defined in both projects
- Database schema changes require corresponding Alembic migrations
- Infrastructure changes should be reflected in Ansible playbooks

### Testing Requirements
- All code changes must include tests
- Run `pytest` for Python, `npm test` for React
- Check coverage thresholds before PR

### Common Tasks
| Task | Command |
|------|---------|
| Lint Python | `ruff check <project> --fix && black <project>` |
| Lint React | `npm run lint && npm run format` |
| Lint Ansible | `ansible-lint && yamllint ansible-infra` |
| Run tests | `pytest` (Python) / `npm test` (React) |

## MCP Integration

This project supports [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) for enhanced agent capabilities. Agents can use MCP to:
- Access external documentation
- Query databases for schema information
- Interact with CI/CD systems

Configure MCP servers in `.vscode/mcp.json` or equivalent.
