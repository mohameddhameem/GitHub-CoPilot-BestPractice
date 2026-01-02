# GitHub Copilot Instructions - Workspace Root

## Scope and navigation
- Multi-project repo: React frontend, FastAPI backend, PyTorch inference backend, Ansible infra. Keep ownership boundaries strict; no cross-project runtime code.
- Entry points: [ansible-infra/.github/copilot-instructions.md](ansible-infra/.github/copilot-instructions.md), [fastapi-backend/.github/copilot-instructions.md](fastapi-backend/.github/copilot-instructions.md), [pytorch-ai-backend/.github/copilot-instructions.md](pytorch-ai-backend/.github/copilot-instructions.md), [react-frontend/.github/copilot-instructions.md](react-frontend/.github/copilot-instructions.md).
- If you add new subprojects, mirror this pattern and add a path-specific instructions file under `.github/instructions` with an `applyTo` glob.

## Setup (do before edits)
- Run [setup_script.ps1](setup_script.ps1) on Windows or [setup_script.sh](setup_script.sh) on WSL/macOS/Linux to install ruff, black, mypy, pytest, pre-commit.
- For Python projects, copy [pyproject_toml.txt](pyproject_toml.txt) to `pyproject.toml` and keep ruff/black/mypy aligned with project rules.
- Apply workspace settings from [vscode_settings.json](vscode_settings.json) so Copilot and formatters stay in sync.

## Shared standards
- Line length 120, organized imports, typed code, no emojis; prefer self-explanatory naming over comments.
- Structured logging with context before/after state changes or inference; never log secrets or PII.
- Branch naming: feature/<short-name>, bugfix/<id>, chore/<desc>; commits are small, present tense.
- Lint/format locally: Python `ruff check . --fix && black .`; React `npm run lint && npm run format`; Ansible `ansible-lint`. Pre-commit hooks run lint/format only.
- Tests: run each project’s native suite (pytest/pytest-asyncio, React Testing Library, Molecule) and exercise edge/error paths.

## Service boundaries
- React: UI/UX and client data-fetching; keep API calls in services and use server-state libraries.
- FastAPI: business APIs and data access; handlers thin, logic in services/repos; async SQLAlchemy + Alembic migrations.
- PyTorch: inference only; optimize loading/batching/device placement; validate shapes/ranges with Pydantic v2.
- Ansible: deployment/config; idempotent tasks, vault secrets, document inventories and execution commands.

## Documentation and hygiene
- Update README and TODO per project when behavior, APIs, or infra steps change; keep model cards/env docs accurate.
- If you introduce new conventions, add them to the relevant project instructions and (if scoped) a `.github/instructions/<name>.instructions.md` with an `applyTo` glob.

## Copilot usage notes
- Repository-wide instructions live here; path-specific instructions can go under `.github/instructions/` with `applyTo` globs; AGENTS.md files are supported nearest-first if added.
- Prompt files (optional) belong in `.github/prompts/` when `chat.promptFiles` is enabled in VS Code; reference files with Markdown links for extra context.
