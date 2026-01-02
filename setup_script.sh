#!/bin/bash
# setup_formatters.sh
# Setup script for Python formatting tools across all Python projects (use in WSL/macOS/Linux)

set -e

echo "=========================================="
echo "Setting up Python formatters for AI Development Workspace"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to setup Python project
setup_python_project() {
    local project_dir=$1
    local project_name=$2
    
    echo -e "\n${BLUE}Setting up: ${project_name}${NC}"
    
    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}Directory $project_dir does not exist. Skipping...${NC}"
        return
    fi
    
    cd "$project_dir"
    
    # Check if virtual environment exists
    if [ ! -d "venv" ] && [ ! -d ".venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    if [ -d "venv" ]; then
        source venv/bin/activate
    elif [ -d ".venv" ]; then
        source .venv/bin/activate
    fi
    
    # Upgrade pip
    echo "Upgrading pip..."
    pip install --upgrade pip
    
    # Install formatting tools
    echo "Installing ruff, black, and pre-commit..."
    pip install "ruff==0.6.*" "black==24.*" "pre-commit==4.*"
    
    # Install additional dev tools
    echo "Installing additional dev tools..."
    pip install mypy pytest pytest-asyncio pytest-cov
    
    # Copy pyproject.toml if it doesn't exist
    if [ ! -f "pyproject.toml" ]; then
        echo "Please copy pyproject.toml template into $(pwd) before running formatters."
    else
        echo -e "${GREEN}✓ pyproject.toml present${NC}"
    fi
    
    # Run initial formatting
    echo "Running initial lint/format..."
    ruff check . --fix || true
    black . || true

    if command -v pre-commit >/dev/null 2>&1; then
        pre-commit install || true
        pre-commit run --all-files || true
    fi
    
    echo -e "${GREEN}✓ ${project_name} setup complete${NC}"
    
    cd - > /dev/null
}

# Main execution
echo -e "\n${BLUE}Step 1: Setting up Python projects${NC}"

# Setup FastAPI Backend
setup_python_project "./fastapi-backend" "FastAPI Backend"

# Setup PyTorch AI Backend
setup_python_project "./pytorch-ai-backend" "PyTorch AI Backend"

# Setup React Frontend (npm packages)
echo -e "\n${BLUE}Step 2: Setting up React Frontend${NC}"
if [ -d "./react-frontend" ]; then
    cd ./react-frontend
    
    if [ ! -f "package.json" ]; then
        echo -e "${RED}package.json not found. Please initialize npm project first.${NC}"
    else
        echo "Installing ESLint and Prettier..."
        npm install --save-dev \
            eslint \
            prettier \
            eslint-config-prettier \
            eslint-plugin-react \
            eslint-plugin-react-hooks \
            @typescript-eslint/eslint-parser \
            @typescript-eslint/eslint-plugin \
            || true
        
        echo -e "${GREEN}✓ React Frontend setup complete${NC}"
    fi
    
    cd - > /dev/null
else
    echo -e "${RED}React Frontend directory not found. Skipping...${NC}"
fi

# Setup Ansible
echo -e "\n${BLUE}Step 3: Setting up Ansible${NC}"
if [ -d "./ansible-infra" ]; then
    cd ./ansible-infra
    
    # Check if ansible-lint is installed globally
    if ! command -v ansible-lint &> /dev/null; then
        echo "Installing ansible-lint globally..."
        pip install --user ansible-lint
    else
        echo -e "${GREEN}✓ ansible-lint already installed${NC}"
    fi
    
    cd - > /dev/null
else
    echo -e "${RED}Ansible directory not found. Skipping...${NC}"
fi

# Create workspace .github directory if it doesn't exist
echo -e "\n${BLUE}Step 4: Setting up GitHub Copilot instructions${NC}"
mkdir -p .github

echo -e "\n${GREEN}=========================================="
echo "Setup Complete!"
echo "==========================================${NC}"

echo -e "\n${BLUE}Next Steps:${NC}"
echo "1. Copy the GitHub Copilot instruction files to each project:"
echo "   - Root workspace: .github/copilot-instructions.md"
echo "   - fastapi-backend/.github/copilot-instructions.md"
echo "   - pytorch-ai-backend/.github/copilot-instructions.md"
echo "   - react-frontend/.github/copilot-instructions.md"
echo "   - ansible-infra/.github/copilot-instructions.md"
echo ""
echo "2. Copy pyproject.toml to each Python project"
echo ""
echo "3. Copy .vscode/settings.json to workspace root"
echo ""
echo "4. Install VS Code extensions:"
echo "   - Python (Microsoft)"
echo "   - Ruff (charliermarsh.ruff)"
echo "   - Black Formatter (ms-python.black-formatter)"
echo "   - Pylance (ms-python.vscode-pylance)"
echo "   - SonarLint (SonarSource.sonarlint-vscode)"
echo "   - ESLint (dbaeumer.vscode-eslint)"
echo "   - Prettier (esbenp.prettier-vscode)"
echo "   - Ansible (redhat.ansible)"
echo "   - GitHub Copilot (GitHub.copilot)"
echo ""
echo "5. Restart VS Code to apply all settings"
echo ""
echo "6. Run formatters in each Python project:"
echo "   cd <project-dir>"
echo "   ruff check . --fix"
echo "   black ."
echo ""

echo "Setup complete."