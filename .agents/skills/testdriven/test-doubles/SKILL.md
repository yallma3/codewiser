---
name: test-doubles
description: Conventions for using test doubles — dummies, stubs, spies, mocks, and fakes. Use when a test needs to isolate the system under test from its dependencies.
license: MIT
---

# Test Doubles Guidelines

## Purpose

Test doubles replace real dependencies to isolate the code under test, control inputs, and verify interactions. Using the right type of double keeps tests meaningful and avoids brittle, over-specified tests.

## The Five Types

| Type | Purpose | Example |
|---|---|---|
| **Dummy** | Passed around but never used | A logger argument that's never called |
| **Stub** | Returns canned values | An API client that returns a fixed response |
| **Spy** | Records calls for later assertion | A callback that logs how many times it was invoked |
| **Mock** | Pre-programmed with expectations | An email service that expects `send()` to be called once |
| **Fake** | Lightweight working implementation | An in-memory database instead of a real one |

## Decision Guide

```
Can I use the real implementation?
├─ Yes → Use the real thing. No double needed.
└─ No → What makes it unusable?
    ├─ Slow (network, DB, file I/O) → Fake (in-memory)
    ├─ Side effects (emails, payments) → Stub or Spy
    ├─ Non-deterministic (random, clock) → Stub
    ├─ Not available in test env → Stub or Fake
    └─ Need to verify it was called → Spy
```

**Default to the simplest double that works.** Dummy → Stub → Spy → Mock (most complex, most brittle).

## Procedure

### 1. Prefer Real Objects

Before reaching for a double, ask: "Can I construct the real dependency quickly and safely?" Real objects catch more bugs and don't need maintenance when the API changes.

### 2. Identify the Boundary

The double sits at your code's boundary — the function argument, constructor parameter, or injected service. Double the interface, not the implementation.

### 3. Choose the Simplest Double

Consult the decision guide above. If a stub suffices, don't use a mock.

### 4. Inject the Double

Pass the double through normal dependency injection — constructor parameters, function arguments, or a simple options object. Never use module-level mocking (e.g., `jest.mock(...)`) when dependency injection is possible.

### 5. Verify (Only What Matters)

- **Stubs**: Assert on the system's output, not that the stub was called.
- **Spies**: Assert only what the test cares about (e.g., "called once with X", not "called exactly 3 times with exact arguments").
- **Mocks**: Assert the expected interaction occurred. Prefer spies over mocks — they verify behavior without pre-programming expectations.

## Templates

### Stub

```ts
// Dependency
interface EmailService {
  send(to: string, body: string): Promise<void>;
}

// Stub
class StubEmailService implements EmailService {
  async send(_to: string, _body: string): Promise<void> {
    // no-op
  }
}

// Test
test('registers user without sending email', async () => {
  const emailer = new StubEmailService();
  const result = await registerUser({ email: 'a@b.com' }, emailer);
  expect(result.ok).toBe(true);
});
```

### Spy

```ts
class SpyEmailService implements EmailService {
  calls: Array<{ to: string; body: string }> = [];

  async send(to: string, body: string): Promise<void> {
    this.calls.push({ to, body });
  }
}

test('sends welcome email on registration', async () => {
  const emailer = new SpyEmailService();
  await registerUser({ email: 'a@b.com' }, emailer);
  expect(emailer.calls).toEqual([
    { to: 'a@b.com', body: 'Welcome!' },
  ]);
});
```

### Fake

```ts
class FakeUserRepository implements UserRepository {
  private store = new Map<number, User>();

  async findById(id: number): Promise<User | null> {
    return this.store.get(id) ?? null;
  }

  async save(user: User): Promise<void> {
    this.store.set(user.id, user);
  }
}
```

## Anti-Patterns

- **Over-mocking** — mocking every dependency means every test is a test of wiring, not behavior. If a test has 3+ mocks, consider a fake or integration test instead.
- **Testing internals** — mocking a private method or internal module couples the test to implementation details. Test through the public API.
- **Mock-all-the-things** — using `jest.mock('../../db')` at the module level hides the dependency and makes refactoring harder. Pass dependencies explicitly.
- **Over-specifying** — asserting on every call argument or exact call count makes tests brittle. Only assert what the test is about.
- **Mocking what you don't own** — mocking third-party libraries is fragile. Create a thin wrapper and double that instead.

## When to Use Fakes

Fakes are the most valuable double because they exercise real logic paths. Use them for:

- In-memory databases (replace PostgreSQL/SQLite in unit tests)
- In-memory message queues
- Fake HTTP clients backed by a hash map
- Fake file systems

Keep fakes simple and in a `test/doubles/` directory. They are not production code — if a fake grows complex, the real dependency may need a cleaner interface.
