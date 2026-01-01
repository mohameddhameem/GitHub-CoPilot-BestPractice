# GitHub Copilot Instructions - Workspace Root

## Workspace map (read first)
- Multi-project repo: React frontend, FastAPI backend, PyTorch inference backend, Ansible infra. Keep boundaries clear; do not mix runtime code across projects.
- Each project has its own rules: start with [ansible-infra/.github/copilot-instructions.md](ansible-infra/.github/copilot-instructions.md), [fastapi-backend/.github/copilot-instructions.md](fastapi-backend/.github/copilot-instructions.md), [pytorch-ai-backend/.github/copilot-instructions.md](pytorch-ai-backend/.github/copilot-instructions.md), and [react-frontend/.github/copilot-instructions.md](react-frontend/.github/copilot-instructions.md).
- Repo ships as skeletons; if you add code, align folder layouts to the structures described in those project guides (e.g., FastAPI under src/api, React under src/components).

## Required setup
- Run [setup_script.ps1](setup_script.ps1) on Windows or [setup_script.sh](setup_script.sh) on WSL/macOS/Linux before coding; installs ruff, black, pre-commit, mypy, pytest, etc.
- For Python projects, copy [pyproject_toml.txt](pyproject_toml.txt) to pyproject.toml and keep ruff/black/mypy settings in sync with project rules.
- Apply [vscode_settings.json](vscode_settings.json) to enforce formatter/lint integration.

## Coding standards (shared)
- Line length 120; organize imports; no emojis; write self-explanatory, typed code.
- Always use structured logging with context before/after data changes or model inference; scrub PII and never log secrets.
- Branch naming: feature/<short-name>, bugfix/<id>, chore/<desc>; commits small and present tense.
- Run lint/format before push: `ruff check . --fix && black .` for Python; `npm run lint && npm run format` for React; `ansible-lint` for Ansible. Pre-commit hooks should run lint/format only.
- Tests: run the project’s native suite (pytest/pytest-asyncio, React Testing Library, Molecule) and cover edge/error paths before PRs.

## Service expectations
- React frontend owns UI/UX; keep API calls in services and rely on data-fetching libs for server state.
- FastAPI backend owns business APIs and data access; keep handlers thin, logic in services/repos; async SQLAlchemy + Alembic for migrations.
- PyTorch backend is dedicated to model inference; optimize loading, batching, device placement, and validate shapes/ranges with Pydantic v2.
- Ansible automates deploy/config; tasks must be idempotent, vault secrets, and document inventories/exec commands.

## Documentation and TODO hygiene
- Update README and TODO per project whenever behavior, APIs, or infra steps change; keep model cards/env docs accurate.
- When adding new components or rules, extend the relevant project-level copilot instructions so future agents inherit the constraints.
