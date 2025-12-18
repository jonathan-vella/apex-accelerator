# Version Information

**Current Version:** 3.7.8

**Last Updated:** 2025-12-18

**Build:** 17d6691

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed release notes.

## Semantic Versioning

This project follows [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR** version for incompatible API changes (breaking changes)
- **MINOR** version for new functionality (feat:)
- **PATCH** version for bug fixes (fix:)

## Automated Versioning

Version bumps are automated via GitHub Actions based on [Conventional Commits](https://www.conventionalcommits.org/):

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `feat:` | Minor | `feat: add new agent` |
| `fix:` | Patch | `fix: correct typo` |
| `feat!:` or `BREAKING CHANGE:` | Major | `feat!: redesign workflow` |
| `docs:`, `chore:`, etc. | None | `docs: update README` |
