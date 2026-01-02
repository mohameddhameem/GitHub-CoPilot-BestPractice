# Multi-Stack Starter Kit

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
ansible-infra/                    # Ansible playbooks and roles
fastapi-backend/                  # FastAPI REST API
pytorch-ai-backend/               # PyTorch model inference service
react-frontend/                   # React TypeScript frontend
```

Path-specific instructions under `.github/instructions/` load automatically based on file type using `applyTo` globs.

## Setup

1. Run the setup script for your platform:
   - Windows: `.\setup_script.ps1`
   - WSL/macOS/Linux: `./setup_script.sh`

2. Copy `pyproject_toml.txt` to `pyproject.toml` in each Python project.

3. Copy `vscode_settings.json` to `.vscode/settings.json` in the workspace root.

4. Install pre-commit hooks:
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

## License

MIT License. See [LICENSE](LICENSE).
