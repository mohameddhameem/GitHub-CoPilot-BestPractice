# Debug Assistance

Use this prompt when debugging issues across any project.

## Information Gathering

Before debugging, collect:
1. **Error message**: Full stack trace or error output
2. **Steps to reproduce**: What actions trigger the issue?
3. **Expected vs actual behavior**: What should happen vs what happens?
4. **Environment**: Local, staging, production? Which versions?

## Common Debugging Strategies

### Python (FastAPI/PyTorch)
```python
import logging
logger = logging.getLogger(__name__)

# Add debug logging
logger.debug("Variable state", extra={"var": var})

# Use breakpoint (Python 3.7+)
breakpoint()
```

### TypeScript/React
```typescript
// Console logging with context
console.log('[ComponentName]', { props, state });

// React DevTools
// Use React DevTools browser extension for component inspection
```

### Ansible
```yaml
# Debug task output
- name: Debug variable
  ansible.builtin.debug:
    var: my_variable

# Verbose mode
# ansible-playbook site.yml -vvv
```

## Checklist
- [ ] Reproduced the issue locally
- [ ] Identified the root cause
- [ ] Confirmed fix resolves the issue
- [ ] Added test to prevent regression
