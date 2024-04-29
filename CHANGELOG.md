## [Unreleased]

## [0.8.9] - 2024-04-29

### Added

- Using yadr as a standard documentation tool;

### Changed

- Upgrade README;
- Updating CI to run lint;

## [0.8.8] - 2024-04-25

### Added

- Auction start reminder sent to participants;
- I18n time format;

### Fixed:

- I18n messages for winner and auction participant emails;

## [0.8.7] - 2024-04-23

### Added

- Removing default values from relations;
- Rebuild factories to not contain default values;
- Add automated tests for auction relations;

## [0.8.6] - 2024-04-23

### Added

- Auction finalization configured for each type of auction;
- Add operations for winner and participant of an auction;
- Configure background job to work with unique jobs;
- Add 'sidekiq-unique-jobs' to be responsible for finishing penny auctions;

### Changed:

- General improvements on seed data;

### Fixed:

- NameError: uninitialized constant AuctionFunCore::Workers::ApplicationJob::Sidekiq (NameError)

## [0.8.5] - 2024-04-03

### Added

- Seed data for rapid develpment

## [0.8.4] - 2024-03-15

- Adjusting dependencies so that they are automatically loaded by the external Gemfile.

## [0.8.3] - 2024-03-12

### Added

- Processing actions to pause and unpause an auction.

## [0.8.1] - 2024-03-06

### Added

- Added configuration constants module to store fixed values referring to business rules.

## [0.8.0] - 2024-03-06

### Added

- Bid entity and your context to handle bid creation business rules.
- Internal Processor module in bids to handle specific types.

### Fixed

- auction migration name fix.

## [0.7.0] - 2024-02-29

### Added

- Auction entity and your context to handle auction creation business rules.
- Internal Processor module in auctions to handle specific actions.
- User-defined Data Types (custom types) for postgres.

### Fixed

- `en-US` i18n contract messages.

## [0.6.1] - 2024-02-28

### Added

- Add configuration to handle monetary values.
- Add required environment variable `DEFAULT_CURRENCY` to set the default currency.
- Tests for entities.

## [0.6.0] - 2024-02-24

### Added

- Redis as database for background processing.
- Add sidekiq as background processing.
- Add required environment variable `REDIS_URL` for redis server connection.
- Add background job as provider application.
- Add exponential backoff for handle possible scenario failures in background.

### Changes

- UserContext::Registration operation to generate email confirmation and send email with token.
- Syntax standardization for erb files.
- Refactoring some tests removing unecessary code.

## [0.5.0] - 2024-02-23

### Added

- Layer for external services.
- Creation of first external service: email.
- Configure email as application provider.
- Mandatory environment variables for communication with email service.
- Configuring development environment to run email service on local machine.
- Using `idlemailer` dependency to build emails and triggers.

## Changes

- I18n locale directory from `config/locales` to root path of project.
- Scope i18n messages by locale.

## [0.4.1] - 2024-02-20

### Added

- Authentication for staff members.
- Only active staff member can authenticate.

## [0.4.0] - 2024-02-20

### Added

- Staff entity and your context to handle staff business rules
- Context for new staff registration
- Add postgresql enum for staff kind

### Fixed

- Fix rake task for create migrations

## [0.3.1] - 2024-02-17

### Added

- Authentication for people (users).
- Only active users can authenticate.

### Changed

- [Standardization] Refactoring return monads in operation classes.

## [0.2.0] - 2024-02-17

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
