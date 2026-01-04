---
applyTo: "ansible-infra/**/*.yml,ansible-infra/**/*.yaml"
---

# Ansible Infrastructure

## Precedence
- Root guidance in [.github/copilot-instructions.md](../copilot-instructions.md) applies. This file governs Ansible YAML; if conflicts arise, these Ansible rules win for `ansible-infra`.

## Playbook Structure
- Goal: readable, role-driven, and recoverable playbooks.
- Use role-based organization
- One task per file when appropriate
- Meaningful role and task names
- Use block for error handling with rescue and always
- Handlers: use handlers for service restarts; pair with `daemon_reload: true` when managing systemd units.

## Variables
- Goal: predictable variable scoping and validation.
- Use group_vars/ and host_vars/ for organization
- Prefix role variables with role name
- Validate variables with assert module before use

```yaml
- name: Validate required variables
  ansible.builtin.assert:
    that:
      - app_version is defined
      - app_port is defined
    fail_msg: "Required variables not set"
```

## Idempotency
- Goal: reruns produce no unintended changes.
- All tasks must be idempotent
- Use changed_when to control change reporting
- Use check_mode compatible modules
- Test playbooks in check mode before execution
- Good: `ansible.builtin.copy` with checksum/force=no. Bad: `command: restart service` without `creates`/`unless`.
- Services: prefer `ansible.builtin.systemd` with handlers; avoid `shell`/`command` for service control.

## Security
- Goal: prevent secret leakage and enforce least privilege.
- Use Ansible Vault for sensitive data
- Never commit unencrypted secrets
- Use no_log: true for sensitive output
- Implement least privilege for SSH and sudo
- Rotate vault keys periodically
- Vault: use AES256; rotate vault password at least quarterly; document rotation in repo docs.

## Error Handling
```yaml
- name: Deploy application
  block:
    - name: Start service
      ansible.builtin.systemd:
        name: app-service
        state: started
        enabled: true
      register: result
      
  rescue:
    - name: Log failure
      ansible.builtin.debug:
        msg: "Failed: {{ ansible_failed_result.msg }}"
        
  always:
    - name: Cleanup temp files
      ansible.builtin.file:
        path: /tmp/deploy
        state: absent
```

Goal: fail fast, log context, and leave hosts clean.

## Code Quality
- Goal: maintain consistent linted playbooks.
- Run ansible-lint and fix all issues
- YAML formatting: 2-space indentation
- Use full module names (ansible.builtin.*, not short forms)
- Document complex conditionals

## Execution Strategy
- Goal: predictable rollouts with bounded blast radius.
- Set serial and max_fail_percentage for controlled rollout
- Tune forks for environment size
- Default to linear strategy for predictable ordering
- Defaults: serial 20%, max_fail_percentage 20%, strategy linear unless overridden per inventory/env.

## Documentation
- Goal: make roles and inventories self-explanatory.
- Document inventory structure
- Document required variables
- Include sample execution commands
- Keep role meta/main.yml updated

## Testing
- Goal: verify idempotency and compatibility before rollout.
- Test against multiple OS versions
- Use --syntax-check before execution
- Validate with --check mode
- Use Molecule for role testing
- Molecule: run for any role that changes tasks/handlers/defaults/templates.

## Formatting and CI hooks
- Goal: enforce lint and syntax checks pre-merge.
- Run before commit:
```bash
ansible-lint
yamllint ansible-infra
```
*CI expectation*: same commands; include Molecule runs for roles when changed; fail CI on vault policy violations or missing handlers for service restarts.
