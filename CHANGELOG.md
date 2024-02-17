## [Unreleased]

## [0.3.1] - 2024-02-27

### Added

- Authentication for people (users).

### Changed

- [Standardization] Refactoring return monads in operation classes.

## [0.2.0] - 2024-02-27

### Added

- User entity and your context to handle people business rules.
- Context for new user registration.
- Bcrypt to handle password issues.
- Phonelib to handle phone issues.
- Logger provider with level configuration.
- Configure i18n.
- `pt-BR` translation.
- `en-US` translation.
- Add `pub/sub` pattern and API with dry-events.
- Add `ActiveSupport` to the main application to facilitate general development.
- Configure database cleaner for suite of tests.

### Fixed

- Adjusting lint with standardrb throughout the code.
- Lifecyle for core provider.

### Changed

- Adjusting directory patterns for test coverage.

## [0.1.0] - 2024-02-06

- Initial release
