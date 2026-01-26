# Ralph Iteration Prompt

You are an autonomous AI agent executing a PRD (Product Requirements Document).

## Your Task

1. Read the PRD at `.planning/ralph/prd.json`
2. Read the progress log at `.planning/ralph/progress.txt`
3. Check `.planning/ralph/AGENTS.md` for codebase patterns and learnings

## Execution Rules

1. Find the FIRST user story where `passes` is `false`
2. Implement that story following existing patterns
3. **Run build and tests to verify** (see Verification section below)
4. If verification passes:
   - Update `prd.json` to set that story's `passes` to `true`
   - Git commit with descriptive message
   - Update `progress.txt` with what you learned
   - Update `AGENTS.md` if you discovered new patterns
5. If verification fails:
   - Do NOT update `passes`
   - Fix the issue and retry

## Verification (REQUIRED)

After implementing each story, you MUST run verification before marking it complete:

1. **Detect project type** and run appropriate commands:
   - Node.js (package.json): `npm run build` (if exists), then `npm test`
   - Python (pyproject.toml/setup.py): `pytest` or `python -m pytest`
   - Go (go.mod): `go build ./...` then `go test ./...`
   - Rust (Cargo.toml): `cargo build` then `cargo test`
   - Ruby (Gemfile): `bundle exec rake` or `bundle exec rspec`
   - Java (pom.xml): `mvn compile` then `mvn test`
   - Java (build.gradle): `./gradlew build`

2. **If no test framework exists**:
   - At minimum, ensure the code compiles/parses without errors
   - Run linting if available (eslint, ruff, golint, etc.)
   - Manually verify the implementation meets acceptance criteria

3. **Only mark `passes: true` if**:
   - Build succeeds (no compilation errors)
   - All tests pass (or no tests exist but code is valid)
   - Acceptance criteria from the story are met

## Completion Signal

When ALL user stories have `passes: true`, output exactly:
```
<promise>COMPLETE</promise>
```

This signals the Ralph loop to exit.

## Important

- Focus on ONE story at a time
- Make small, atomic commits
- Always try to reuse code if possible. Scan for existing implementation before creating a new one
- Keep all the files under 300 lines of code
- **Always run build/tests before marking complete**
- Update progress.txt after each story
- Learn from AGENTS.md before starting
