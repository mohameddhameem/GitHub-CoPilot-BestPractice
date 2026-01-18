---
applyTo: "ansible-infra/**/*.yml,ansible-infra/**/*.yaml"
---

# Ansible Infrastructure

## Precedence
Root guidance in [copilot-instructions.md](../copilot-instructions.md) applies. This file wins for `ansible-infra/`.

## Structure
- Role-based organization; meaningful role and task names
- Use `block`/`rescue`/`always` for error handling
- Use handlers for service restarts with `daemon_reload: true`

## Variables
- Use `group_vars/` and `host_vars/`; prefix role variables with role name
- Validate with `ansible.builtin.assert` before use

## Idempotency
- All tasks must be idempotent; use `changed_when` appropriately
- Prefer `ansible.builtin.systemd` over shell for services
- Test with `--check` mode before execution

## Security
- Ansible Vault for secrets (AES256); rotate quarterly
- Use `no_log: true` for sensitive output
- Least privilege for SSH and sudo

## Error Handling
```yaml
- name: Deploy
  block:
    - name: Start service
      ansible.builtin.systemd:
        name: app
        state: started
  rescue:
    - ansible.builtin.debug:
        msg: "Failed: {{ ansible_failed_result.msg }}"
  always:
    - ansible.builtin.file:
        path: /tmp/deploy
        state: absent
```

## Execution
- `serial: 20%`, `max_fail_percentage: 20%`, strategy: linear
- Document required variables and execution commands

## Testing
- Use Molecule for role testing; run `--syntax-check` first

## Formatting
```bash
ansible-lint && yamllint ansible-infra
```
