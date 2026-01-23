# Contributing

Thank you for your interest in contributing to this dotfiles project!

## Getting Started

1. Fork the repository
2. Clone your fork:

   ```bash
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles-fork
   ```

3. Create a feature branch:

   ```bash
   git checkout -b feature/amazing-feature
   ```

## Development Setup

### Prerequisites

- macOS, Linux, or WSL
- Git
- Zsh

### Testing Locally

```bash
# Run tests
make test

# Run linters
make lint

# Dry run bootstrap
bash bootstrap.sh --dry-run
```

## Code Style

### Shell Scripts

- Use `shellcheck` for linting
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellstyle.html)
- Use meaningful variable names
- Add comments for complex logic

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <subject>

[optional body]
```

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `perf`: Performance improvement
- `test`: Adding tests
- `chore`: Maintenance

Examples:

```
feat: add Docker aliases
fix: correct symlink path for nvim config
docs: update README with WSL instructions
```

## Pull Request Process

1. Update documentation if needed
2. Add tests for new functionality
3. Ensure all tests pass: `make test`
4. Ensure linting passes: `make lint`
5. Update CHANGELOG.md
6. Submit PR with clear description

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
How was this tested?

## Checklist
- [ ] Tests pass
- [ ] Linting passes
- [ ] Documentation updated
```

## Adding New Features

### New Aliases

1. Add to appropriate file in `aliases/`
2. Document in `docs/reference/aliases.md`
3. Add to `dothelp` output if applicable

### New Tools

1. Add to `Brewfile` and/or `Brewfile.full`
2. Add configuration if needed
3. Update documentation
4. Add aliases if useful

### New Scripts

1. Add to `scripts/` with appropriate category
2. Follow script template
3. Add documentation in `docs/reference/scripts.md`
4. Add tests if possible

## Testing

### Running Tests

```bash
# All tests
bats tests/

# Specific test file
bats tests/bootstrap.bats

# With verbose output
bats --verbose-run tests/
```

### Writing Tests

Tests use [Bats](https://github.com/bats-core/bats-core):

```bash
@test "description of test" {
    run command_to_test
    assert_success
    assert_output "expected output"
}
```

## Documentation

- Use MkDocs for documentation site
- Keep README.md and docs/ in sync
- Include code examples
- Test all commands before documenting

### Building Docs Locally

```bash
pip install -r requirements-docs.txt
mkdocs serve
# Visit http://localhost:8000
```

## Questions?

Feel free to open an issue for:

- Feature requests
- Bug reports
- Questions about contribution
- Suggestions for improvement

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
