---
applyTo: "react-frontend/**/*.ts,react-frontend/**/*.tsx"
---

# React TypeScript Frontend

## Precedence
Root guidance in [copilot-instructions.md](../copilot-instructions.md) applies. This file wins for `react-frontend/` files.

## Project Structure
```
src/
  components/   # Reusable UI
  features/     # Feature-specific components
  hooks/        # Custom hooks
  services/     # API calls
  types/        # Type definitions
```

## Component Patterns
- Functional components with hooks only; one per file
- PascalCase for components, camelCase for utilities
- Max 250 lines per component

```typescript
interface UserCardProps {
  userId: string;
  onDelete: (id: string) => void;
}

export const UserCard = ({ userId, onDelete }: UserCardProps) => {
  const { data: user, isLoading, error } = useUser(userId);
  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  return <div className="user-card">{user?.name}</div>;
};
```

## TypeScript
- Strict mode; no `any`; interfaces for all props/state/API responses

## State Management
- React Context for global; React Query/SWR for server state
- Avoid prop drilling beyond 2 levels

## Performance
- useMemo/useCallback for expensive ops; React.memo for pure components
- Lazy load routes and heavy components

## Testing
- React Testing Library; test interactions, not implementation
- Happy path + one error state per async component

## Formatting
```bash
npm run lint && npm run format && npm test -- --watch=false
```

## Anti-Patterns
- No inline styles; use CSS modules
- No nested ternaries; no giant useEffect hooks
