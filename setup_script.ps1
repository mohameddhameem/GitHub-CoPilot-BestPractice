<#
setup_script.ps1
Windows-friendly setup for local lint/format hooks (ruff + black) and dev tools.
Run from workspace root. Uses PowerShell 7+.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=========================================="
Write-Host "Setting up Python formatters for AI Development Workspace (Windows)"
Write-Host "=========================================="

function Assert-Command {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$InstallHint
    )
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' not found. $InstallHint"
    }
}

Assert-Command -Name "python" -InstallHint "Install Python 3.11+ and add it to PATH."

$projects = @(
    @{ Path = "./fastapi-backend"; Name = "FastAPI Backend" },
    @{ Path = "./pytorch-ai-backend"; Name = "PyTorch AI Backend" }
)

foreach ($proj in $projects) {
    $projPath = Resolve-Path $proj.Path -ErrorAction SilentlyContinue
    if (-not $projPath) {
        Write-Warning "Directory $($proj.Path) not found. Skipping $($proj.Name)."
        continue
    }

    Write-Host "`n--- Setting up $($proj.Name) ---"
    Push-Location $projPath

    if (-not (Test-Path "venv") -and -not (Test-Path ".venv")) {
        Write-Host "Creating virtual environment..."
        python -m venv venv
    }

    $venvPath = if (Test-Path "venv") { "venv" } else { ".venv" }
    $activate = Join-Path $venvPath "Scripts/Activate.ps1"
    if (-not (Test-Path $activate)) { throw "Cannot find venv activation script at $activate" }
    . $activate

    Write-Host "Upgrading pip..."
    python -m pip install --upgrade pip

    Write-Host "Installing ruff, black, pre-commit, mypy, pytest..."
    python -m pip install "ruff==0.6.*" "black==24.*" "pre-commit==4.*" mypy pytest pytest-asyncio pytest-cov

    if (-not (Test-Path "pyproject.toml")) {
        Write-Warning "pyproject.toml missing. Copy the template before running formatters."
    } else {
        Write-Host "pyproject.toml found."
    }

    Write-Host "Running initial lint/format..."
    ruff check . --fix -q || Write-Warning "ruff reported issues"
    black . || Write-Warning "black reported issues"

    if (Get-Command pre-commit -ErrorAction SilentlyContinue) {
        pre-commit install
        pre-commit run --all-files || Write-Warning "pre-commit reported issues"
    }

    Pop-Location
}

Write-Host "`n--- Setting up React Frontend (lint/format deps) ---"
$reactPath = Resolve-Path "./react-frontend" -ErrorAction SilentlyContinue
if ($reactPath) {
    Push-Location $reactPath
    if (Test-Path "package.json") {
        npm install --save-dev `
            eslint `
            prettier `
            eslint-config-prettier `
            eslint-plugin-react `
            eslint-plugin-react-hooks `
            @typescript-eslint/eslint-parser `
            @typescript-eslint/eslint-plugin
    } else {
        Write-Warning "package.json not found. Initialize the project first."
    }
    Pop-Location
} else {
    Write-Warning "react-frontend directory not found."
}

Write-Host "`n--- Ansible lint setup ---"
$ansiblePath = Resolve-Path "./ansible-infra" -ErrorAction SilentlyContinue
if ($ansiblePath) {
    Push-Location $ansiblePath
    try {
        python -m pip install --user ansible-lint yamllint
    } catch {
        Write-Warning "Unable to install ansible-lint/yamllint: $_"
    }
    Pop-Location
} else {
    Write-Warning "ansible-infra directory not found."
}

Write-Host "`nSetup complete. Run tests manually after lint/format." -ForegroundColor Green
