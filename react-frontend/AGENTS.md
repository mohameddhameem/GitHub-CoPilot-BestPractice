# AGENTS.md - React Frontend

## Project Context
This is a React TypeScript frontend. See root [AGENTS.md](../AGENTS.md) for repo-wide guidance.

## Key Files
- `src/App.tsx` - Root component
- `src/components/` - Reusable UI components
- `src/services/` - API integration
- `src/hooks/` - Custom React hooks

## Before Making Changes
1. Check existing components before creating new ones
2. Follow established patterns in `src/services/` for API calls
3. Use proper TypeScript types - no `any`

## Commands
```bash
# Development
npm start

# Lint and format
npm run lint && npm run format

# Test
npm test

# Build
npm run build
```

## Component Guidelines
- One component per file
- Max 250 lines per component
- Use React Query/SWR for server state
