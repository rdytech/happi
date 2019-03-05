# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2019-03-05
### Added
- Set original file names for multipart Happi files

[Unreleased]: https://github.com/jobready/happi/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/jobready/happi/compare/v0.3.0...v0.4.0


## [0.3.0] - 2018-02-23
### Added
- Ability to set `token_type` in configuration and pass this into `FaradayMiddleware::OAuth2` to avoid `faraday_middleware` 0.11.0 warning about using the default token type. Set `token_type: 'bearer'` to only pass the oauth token as an Authorization header instead of both a header and query string parameter.
- This CHANGELOG.

[Unreleased]: https://github.com/jobready/happi/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/jobready/happi/compare/v0.2.0...v0.3.0
