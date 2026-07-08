---
name: test-fixtures
description: Patterns and conventions for creating and managing test data — factories, builders, fixtures, and seed data. Use when writing tests that need realistic or repeatable data.
license: MIT
---

# Test Fixtures Guidelines

## Purpose

Test fixtures provide consistent, repeatable test data. Using factories and builders instead of ad-hoc objects in each test reduces duplication, makes tests more readable, and localizes the impact of schema changes.

## When to Use

- A test needs an instance of a model, entity, or DTO
- Multiple tests share the same object shape with minor variations
- A schema change would require updating many test files
- Test data setup is longer than the test's assertion

## Patterns

### 1. Factory Functions

A function that returns a default instance with overridable fields.

**Good:**
```ts
function createUser(overrides: Partial<User> = {}): User {
  return {
    id: 1,
    name: 'Default User',
    email: 'user@example.com',
    role: 'viewer',
    createdAt: new Date('2025-01-01'),
    ...overrides,
  };
}

test('updates user name', () => {
  const user = createUser({ id: 42 });
  // Only id matters; rest are defaults
});
```

**Bad:**
```ts
test('updates user name', () => {
  const user = {
    id: 42,
    name: 'Test',          // irrelevant
    email: 'test@test.com', // irrelevant
    role: 'admin',          // irrelevant,
    createdAt: new Date(),  // varies by run
  };
});
```

### 2. Builder Pattern

A fluent class for complex objects with many optional or interdependent fields.

```ts
class UserBuilder {
  private props: Partial<User> = {};

  withName(name: string) { this.props.name = name; return this; }
  asAdmin() { this.props.role = 'admin'; return this; }
  build(): User { return createUser(this.props); }
}

test('admin can delete posts', () => {
  const admin = new UserBuilder().asAdmin().build();
  // ...
});
```

### 3. Object Mother

Pre-built named fixtures for commonly used states.

```ts
// test/mothers/user.mother.ts
export const Mothers = {
  defaultUser: createUser(),
  adminUser: createUser({ role: 'admin' }),
  inactiveUser: createUser({ active: false }),
  userWithOrders: createUser({ orders: [OrderMother.defaultOrder] }),
};
```

## Procedure

1. **Identify the entity** — each model/schema gets its own factory in a co-located `test/factories/` or `__tests__/factories/` file.
2. **Define sensible defaults** — use valid, database-neutral values. Never use random or time-based defaults unless the test specifically needs them.
3. **Accept overrides** — the factory must accept a `Partial<T>` or builder method so each test can vary only what matters.
4. **Export a factory + mother** — export the factory function for flexibility and a mother object for convenience.
5. **Use in tests** — import the factory, call it with the minimum overrides needed.

## File Conventions

```
src/
├── models/
│   └── user.ts
└── __tests__/
    └── factories/
        ├── user.factory.ts      # createUser() + UserBuilder
        └── mothers.ts           # Common named instances
```

For small projects, a single `factories.ts` file is acceptable.

## Best Practices

- **Deterministic values only** — no `Date.now()`, `uuid()`, or `Math.random()` in defaults. Use fixed values like `new Date('2025-01-01')`.
- **One factory per entity** — avoid mega-factories that produce different types.
- **Keep defaults valid** — a test should be able to call `createUser()` with no overrides and get a valid object.
- **Don't share mutable fixtures** — each test call gets a fresh object. Shared mutable fixtures cause test ordering bugs.
- **Co-locate with the entity** — the factory for `user.ts` lives in a `factories/` directory next to the test file, not in a global `test/` folder.
