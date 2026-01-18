# Code Review Checklist

Use this prompt when reviewing code changes across any project in this repository.

## Review Focus Areas

### 1. Code Quality
- [ ] Follows project-specific coding standards
- [ ] No unused imports or dead code
- [ ] Functions are focused and under 50 lines
- [ ] Appropriate error handling

### 2. Type Safety
- [ ] All functions have type hints (Python) or proper types (TypeScript)
- [ ] No `any` types in TypeScript
- [ ] Pydantic models for data validation

### 3. Testing
- [ ] New code includes tests
- [ ] Tests cover happy path and error cases
- [ ] Mocks external dependencies appropriately

### 4. Security
- [ ] No secrets in code
- [ ] Input validation present
- [ ] No SQL injection vulnerabilities
- [ ] Proper authentication/authorization checks

### 5. Performance
- [ ] No N+1 queries
- [ ] Appropriate caching
- [ ] Async operations used correctly

## Questions to Ask
1. Is this change backward compatible?
2. Does this require a database migration?
3. Are there any breaking API changes?
4. Is documentation updated?
