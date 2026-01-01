# Workspace Skeleton and Next Steps

This folder layout mirrors the multi-project workspace. Copy the folders into your real projects and keep each project's `.github/copilot-instructions.md` in place.

```
.
├── .github/
│   └── copilot-instructions.md          # Root guidance
├── ansible-infra/
│   └── .github/copilot-instructions.md  # Ansible guidance
├── fastapi-backend/
│   └── .github/copilot-instructions.md  # FastAPI guidance
├── pytorch-ai-backend/
│   └── .github/copilot-instructions.md  # PyTorch guidance
├── react-frontend/
│   └── .github/copilot-instructions.md  # React guidance
├── pyproject_toml.txt                   # Template for Python projects
├── setup_script.sh                      # WSL/macOS/Linux setup (ruff+black+pre-commit)
├── setup_script.ps1                     # Windows PowerShell setup (ruff+black+pre-commit)
└── vscode_settings.json                 # VS Code workspace settings
```

## How to use
1. Copy the `ansible-infra`, `fastapi-backend`, `pytorch-ai-backend`, and `react-frontend` folders into your workspace (or merge their `.github/copilot-instructions.md` into existing projects).
2. Place `.github/copilot-instructions.md` at your workspace root.
3. Copy `pyproject_toml.txt` as `pyproject.toml` into each Python project root.
4. Apply `vscode_settings.json` to your workspace `.vscode/settings.json`.
5. Pick the setup script for your platform:
   - Windows: `./setup_script.ps1`
   - WSL/macOS/Linux: `./setup_script.sh`

## Required local steps (run these)
1. Run the setup script for your platform to install ruff, black, pre-commit, mypy, pytest, etc.
2. In each Python project, install pre-commit and run once:
   ```bash
   pre-commit install
   pre-commit run --all-files
   ```
3. Run project tests manually (e.g., `pytest` for Python, `npm test` for React).
4. Keep `pyproject.toml` and `.pre-commit-config.yaml` (if you add one) committed.

## Notes
- Formatter stack: ruff (lint/imports) + black (format) for Python; Prettier + ESLint for JS/TS.
- Pre-commit hooks should run lint/format only; run tests manually before pushing.
- Use PowerShell on Windows; bash on WSL/macOS/Linux.
