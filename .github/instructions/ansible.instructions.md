---
applyTo: "ansible-infra/**/*.yml,ansible-infra/**/*.yaml"
---

# Ansible Infrastructure

## Playbook Structure
- Use role-based organization
- One task per file when appropriate
- Meaningful role and task names
- Use block for error handling with rescue and always

## Variables
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
- All tasks must be idempotent
- Use changed_when to control change reporting
- Use check_mode compatible modules
- Test playbooks in check mode before execution

## Security
- Use Ansible Vault for sensitive data
- Never commit unencrypted secrets
- Use no_log: true for sensitive output
- Implement least privilege for SSH and sudo
- Rotate vault keys periodically

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

## Code Quality
- Run ansible-lint and fix all issues
- YAML formatting: 2-space indentation
- Use full module names (ansible.builtin.*, not short forms)
- Document complex conditionals

## Execution Strategy
- Set serial and max_fail_percentage for controlled rollout
- Tune forks for environment size
- Default to linear strategy for predictable ordering

## Documentation
- Document inventory structure
- Document required variables
- Include sample execution commands
- Keep role meta/main.yml updated

## Testing
- Test against multiple OS versions
- Use --syntax-check before execution
- Validate with --check mode
- Use Molecule for role testing
