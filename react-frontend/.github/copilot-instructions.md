# GitHub Copilot Instructions - React Frontend

## React Best Practices

### Component Structure
- Functional components with hooks only
- One component per file
- Component file naming: PascalCase (e.g., `UserProfile.tsx`)
- Utility file naming: camelCase (e.g., `dateFormatter.ts`)
- Maximum 250 lines per component; refactor if exceeded

### TypeScript Usage
- Strict TypeScript mode enabled
- No `any` types; use `unknown` with type guards if needed
- Define interfaces for all props, state, and API responses
- Use type inference where obvious; explicit types for public APIs
- Generic types for reusable components

### Code Organization
```
src/
├── components/     # Reusable UI components
├── features/       # Feature-specific components
├── hooks/          # Custom hooks
├── services/       # API calls and external services
├── types/          # TypeScript type definitions
├── utils/          # Helper functions
├── constants/      # Application constants
└── styles/         # Global styles
```

### Component Patterns
```typescript
// Good: Typed, clear separation of concerns
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

### State Management
- Use React Context for global state
- Prefer React Query/SWR for server state
- Local state with `useState` for UI-only state
- `useReducer` for complex state logic
- Avoid prop drilling beyond 2 levels

### Performance
- Memoize expensive calculations with `useMemo`
- Memoize callbacks passed to children with `useCallback`
- Use `React.memo` for pure components with expensive renders
- Lazy load routes and heavy components; code-split by route and large feature bundles
- Virtualize long lists with react-window or similar
- Track bundle budgets (set max for main + async chunks); run bundle analyzer before merge
- Prefer suspense-friendly data fetching and streaming where possible

### Routing and Boundaries
- Use a router that supports code-splitting (e.g., React Router with lazy routes)
- Add top-level and feature-level error boundaries; render fallback UIs
- Guard private routes with auth-aware wrappers; redirect unauthenticated users

### Error Handling
- Error boundaries for component trees
- Graceful degradation for failed features
- User-friendly error messages
- Log errors with context to monitoring service

### API Integration
- Centralize API calls in `services/` directory
- Use Axios or Fetch with proper error handling
- Type API responses with interfaces
- Implement retry logic for failed requests
- Handle loading and error states consistently
- Enforce CORS/CSRF protections via server config and client-side token headers

```typescript
// Good: Typed service with error handling
interface CreateUserRequest {
  name: string;
  email: string;
}

interface User {
  id: string;
  name: string;
  email: string;
  createdAt: string;
}

export const userService = {
  async createUser(data: CreateUserRequest): Promise<User> {
    try {
      const response = await api.post<User>('/users', data);
      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        throw new Error(error.response?.data?.message || 'Failed to create user');
      }
      throw error;
    }
  }
};
```

### Testing
- Test user interactions, not implementation details
- Use React Testing Library
- Test error states and edge cases
- Mock API calls in tests
- Aim for meaningful coverage, not percentage targets

### Accessibility
- Semantic HTML elements
- ARIA labels where needed
- Keyboard navigation support
- Focus management for modals and dialogs
- Color contrast compliance (WCAG AA minimum)

### Forms, i18n, and Theming
- Use a form library (React Hook Form/Formik) with schema validation (zod/yup)
- Centralize copy and support i18n-ready strings; avoid hardcoded text
- Define a design token set for spacing/typography/colors; theme via context/provider

### Code Quality
- ESLint with strict rules enabled
- Fix all SonarLint issues immediately
- No console.log in production code; use proper logging
- Remove unused imports and variables
- Consistent formatting (Prettier with IntelliJ-style config)

### Linting and Formatting (local-only pre-commit)
- Formatter: Prettier (TS/JS/CSS) with ESLint for rules
- Install and run locally: `npm run lint` and `npm run format` if defined
- Pre-commit hook should run lint/format only; run tests manually before pushing

### Documentation
- JSDoc for exported functions and complex logic
- README.md with setup instructions and architecture overview
- Document environment variables and configuration
- Update CHANGELOG.md for significant changes

### TODO Management
Maintain TODO.md with:
- Feature implementations pending
- Component refactoring needed
- Performance optimizations identified
- Accessibility improvements required
- Test coverage gaps

## Anti-Patterns to Avoid
- No inline styles; use CSS modules or styled-components
- No component logic in useEffect unless necessary
- No mutating state directly
- No nested ternary operators; extract to variables
- No giant useEffect hooks; split into multiple focused effects
- No unescaped HTML injection; always sanitize and escape user content
