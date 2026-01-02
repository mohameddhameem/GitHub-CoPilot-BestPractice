---
applyTo: "**/*.ts,**/*.tsx"
---

# React TypeScript Frontend

## Project Structure
```
src/
  components/     # Reusable UI components
  features/       # Feature-specific components
  hooks/          # Custom hooks
  services/       # API calls and external services
  types/          # TypeScript type definitions
  utils/          # Helper functions
  constants/      # Application constants
  styles/         # Global styles
```

## Component Patterns
- Functional components with hooks only
- One component per file
- Component naming: PascalCase (UserProfile.tsx)
- Utility naming: camelCase (dateFormatter.ts)
- Maximum 250 lines per component

```typescript
interface UserCardProps {
  userId: string;
  onDelete: (id: string) => void;
}

export const UserCard = ({ userId, onDelete }: UserCardProps) => {
  const { data: user, isLoading, error } = useUser(userId);
  
  const handleDelete = useCallback(() => {
    onDelete(userId);
  }, [userId, onDelete]);
  
  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return null;
  
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <button onClick={handleDelete}>Delete</button>
    </div>
  );
};
```

## TypeScript
- Strict mode enabled
- No `any` types; use `unknown` with type guards
- Define interfaces for all props, state, and API responses
- Use type inference where obvious; explicit types for public APIs

## State Management
- React Context for global state
- React Query/SWR for server state
- useState for UI-only state
- useReducer for complex state logic
- Avoid prop drilling beyond 2 levels

## Performance
- useMemo for expensive calculations
- useCallback for callbacks passed to children
- React.memo for pure components with expensive renders
- Lazy load routes and heavy components
- Virtualize long lists

## API Integration
- Centralize API calls in services/
- Type all API responses
- Handle loading and error states consistently

```typescript
interface User {
  id: string;
  name: string;
  email: string;
}

export const userService = {
  async getUser(id: string): Promise<User> {
    const response = await api.get<User>(`/users/${id}`);
    return response.data;
  }
};
```

## Error Handling
- Error boundaries for component trees
- Graceful degradation for failed features
- User-friendly error messages

## Accessibility
- Semantic HTML elements
- ARIA labels where needed
- Keyboard navigation support
- Focus management for modals

## Testing
- Test user interactions, not implementation
- Use React Testing Library
- Mock API calls in tests
- Test error states and edge cases

## Code Quality
- ESLint with strict rules
- No console.log in production
- Remove unused imports

## Formatting
Run before commit:
```bash
npm run lint
npm run format
```

## Anti-Patterns to Avoid
- No inline styles; use CSS modules or styled-components
- No nested ternary operators
- No giant useEffect hooks; split into focused effects
- No unescaped HTML injection
