# AGENTS.md - Ansible Infrastructure

## Project Context
This is Ansible infrastructure automation. See root [AGENTS.md](../AGENTS.md) for repo-wide guidance.

## Key Files
- `site.yml` - Main playbook
- `inventory.ini` - Host inventory
- `roles/` - Reusable roles
- `group_vars/` - Group variables

## Before Making Changes
1. All tasks must be idempotent
2. Use full module names (`ansible.builtin.*`)
3. Encrypt secrets with Ansible Vault

## Commands
```bash
# Syntax check
ansible-playbook site.yml --syntax-check

# Dry run
ansible-playbook site.yml --check

# Execute
ansible-playbook -i inventory.ini site.yml

# Lint
ansible-lint && yamllint .
```

## Vault Operations
```bash
# Encrypt
ansible-vault encrypt secrets.yml

# Edit encrypted file
ansible-vault edit secrets.yml
```
