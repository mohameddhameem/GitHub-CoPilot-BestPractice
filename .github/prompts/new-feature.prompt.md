# New Feature Implementation

Use this prompt when implementing a new feature in any project.

## Before You Start

1. **Understand the scope**: What exactly needs to be built?
2. **Identify the project**: Which project(s) does this affect?
3. **Check existing code**: Are there similar patterns to follow?

## Implementation Steps

### For API Endpoints (FastAPI/PyTorch)
1. Define Pydantic request/response models in `src/models/`
2. Implement service logic in `src/services/`
3. Create route handler in `src/api/routes/`
4. Add tests in `tests/`
5. Update OpenAPI docs if needed

### For React Components
1. Create component file in appropriate directory
2. Define TypeScript interfaces for props
3. Implement component with proper hooks
4. Add to parent component/router
5. Write tests using React Testing Library

### For Infrastructure (Ansible)
1. Create or update role in `roles/`
2. Define variables in `group_vars/` or `host_vars/`
3. Update `site.yml` if needed
4. Test with `--check` mode
5. Document in role README

## Post-Implementation
- [ ] All tests pass
- [ ] Linting passes
- [ ] Documentation updated
- [ ] Ready for code review
