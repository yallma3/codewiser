---
name: test-infrastructure
description: Setup, configuration, and conventions for the project's test runner, coverage thresholds, CI integration, and test environment. Use when initializing or modifying the test harness.
license: MIT
---

# Test Infrastructure Guidelines

## Purpose

A well-configured test infrastructure ensures tests run consistently across environments, fail fast on violations, and integrate smoothly with CI. This skill covers the project's test runner setup, coverage configuration, and environment conventions.

## When to Use

- Setting up a new project or module with tests for the first time
- Configuring coverage thresholds or CI test steps
- Debugging flaky tests, slow suites, or environment mismatches
- Adding a new test type (e2e, integration, snapshot, performance)

## Test Runner Configuration

### Choose a Runner

Use the project's established runner (detect from `package.json`, `jest.config.*`, `vitest.config.*`, `pytest.ini`, etc.). If none exists, use the framework-recommended default.

### Vitest / Jest (TypeScript/JavaScript)

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      thresholds: {
        branches: 80,
        functions: 80,
        lines: 80,
        statements: 80,
      },
    },
  },
});
```

### Pytest (Python)

```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
addopts = -v --tb=short --cov=src --cov-report=term-missing --cov-fail-under=80
```

## Procedure

### 1. Detect or Create Config

Check for existing config files. If missing, create one matching the project's framework and language. Place it at the project root.

### 2. Configure Coverage Thresholds

Set coverage floors that are ambitious but achievable. Start at 60% for an untested project, 80% for well-tested code. Adjust per module if needed.

Add a `coverage` section to the test config (see templates above).

### 3. Set Up Test Helpers & Globals

Create a `test/setup.ts` (or equivalent) that runs before every test suite:

```ts
// test/setup.ts
import { beforeAll, afterAll, beforeEach } from 'vitest';

beforeAll(() => {
  process.env.NODE_ENV = 'test';
  process.env.DATABASE_URL = 'sqlite::memory:';
});

afterAll(() => {
  // Cleanup shared resources
});

beforeEach(() => {
  // Reset any global state between tests
});
```

### 4. Set Up Environment

| Concern | Convention |
|---|---|
| Database | Use an in-memory or containerized instance (SQLite for unit, Testcontainers for integration) |
| Environment variables | Set in `test/setup.ts` or a `.env.test` file loaded by the runner |
| File system | Use `os.tmpdir()` + `randomUUID()` for temp directories; clean up in `afterEach` |
| Network | Never reach real external services — use fakes or a recorded HTTP server (Polly, WireMock, etc.) |

### 5. Add CI Steps

Add a test step to the CI config (GitHub Actions example):

```yaml
- name: Run tests
  run: npm test
- name: Check coverage
  run: npm run coverage -- --thresholds
```

Ensure the CI step fails the build if coverage is below threshold or any test fails.

### 6. Verify Locally

Run the full suite:

```bash
npm test        # or pytest, cargo test, etc.
```

Confirm:
- All tests pass
- Coverage report matches thresholds
- No flaky or timing-dependent failures
- Run duration is reasonable (< 1 min for unit, < 5 min for integration)

### 7. Verify in CI

Push a branch and confirm CI runs the test step and reports pass/fail correctly.

## Best Practices

- **Deterministic by default** — no random ports, no time-dependent assertions, no shared mutable state between test files.
- **Fast unit feedback** — unit tests should complete in seconds. If they don't, restructure or move slow tests to a separate integration suite.
- **Isolate integration tests** — integration tests that hit a real DB or API go in a separate directory (`test/integration/`) with a separate config and longer timeout.
- **Fail fast** — configure the runner to stop on the first failure in CI (`--bail`). In dev, keep running all tests for full feedback.
- **Clean up after yourself** — every `beforeAll`/`beforeEach` setup must have a matching `afterAll`/`afterEach` teardown. Leaked state is the #1 cause of flaky tests.

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| Test passes in isolation, fails in suite | Shared mutable state | Add `beforeEach` reset for shared objects |
| Flaky network-dependent test | Real external call | Replace with a fake or recorded response |
| Coverage below threshold | Missing tests for new code | Write tests or adjust threshold with team agreement |
| Slow test suite (> 2 min) | Integration tests mixed with unit tests | Separate into `test/unit/` and `test/integration/` with different configs |
| Environment variable missing in CI | .env not loaded | Add CI secret or use `.env.test` with CI-specific defaults |

## File Conventions

```
test/
├── setup.ts                    # Global setup (env vars, DB, etc.)
├── helpers.ts                   # Shared test utilities
├── doubles/                     # Fakes, stubs, spies
│   └── fake-db.ts
├── unit/                        # Fast unit tests
├── integration/                 # Slow integration tests
└── factories/                   # Test data factories
    └── user.factory.ts
```
