# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-12
Supersedes the `1.0.0-rc` and `1.0.0-rc2` pre-releases; everything below is relative
to 0.6.0.

### Changed
- **BREAKING**: OAuth2 tokens are sent only as an `Authorization` header. `FaradayMiddleware::OAuth2`
  defaulted to its `'param'` token type, which appended the token as an `access_token` query string
  parameter *and* set an `Authorization: Token token="…"` header; that applied whenever `token_type`
  was unset or explicitly `'param'`. Servers reading the token from the query string will no longer
  receive it. The scheme now defaults to `Bearer` and is overridden by `token_type`; no header is set
  when `oauth_token` is blank.
- **BREAKING**: `token_type` has changed meaning. It was a mode selector for
  `FaradayMiddleware::OAuth2` accepting `'param'` or `'bearer'`; it is now interpolated verbatim as
  the `Authorization` scheme. Two consequences for 0.6.0 consumers:
  - `token_type: 'param'` produces the malformed header `Authorization: param <token>` and no query
    parameter. There is no replacement for the query-string mode in 1.0.0 — remove the setting and
    have the server read the token from the `Authorization` header. Tokens in query strings end up
    in access logs, proxy caches and `Referer` headers, which is why the mode is gone.
  - `token_type: 'bearer'` now emits `bearer <token>` where 0.6.0 normalised it to `Bearer <token>`.
    Scheme names are case-insensitive per RFC 7235 §2.1, so conforming servers are unaffected.
- **BREAKING**: Removed the `oauth2`, `multi_json`, `faraday-follow_redirects` and `faraday-http`
  dependencies. Applications using these directly must add them to their own Gemfile.
- **BREAKING**: Minimum Ruby is now 3.2.0.
- Replaced `activemodel` with `activesupport` - only ActiveSupport features were used.
- Widened `faraday` to `>= 1.10.0` and `mime-types` to `>= 2.4.0`. Faraday 1.10 is the earliest
  release that registers the `:json` request/response middleware this gem relies on.
- Packaged gem now contains only runtime files. Specs (and their 2MB fixture), research notes and
  CI/editor config are no longer shipped, taking the gem from ~2.1MB to ~14KB. The deprecated
  `spec.test_files` directive was removed along with them.

### Removed
- **BREAKING**: `Happi::Client#connection_options`. It built an options hash for
  `FaradayMiddleware::OAuth2` and has had no callers since that middleware was dropped —
  `#connection` never consulted it. Subclasses that overrode it were already having no effect.
- All `FaradayMiddleware` usage. The gem was never compatible with Faraday 2.x and was not a
  declared dependency of Happi.
- Travis and Buildkite CI configuration, superseded by the GitHub Actions workflow (Buildkite
  still provisioned Ruby 2.1.5).

### Fixed
- Requests no longer fail with `NoMethodError: undefined method 'new' for JSON:Module`. The
  connection passed the `::JSON` module itself to `f.use` as response middleware; it now uses
  Faraday's built-in `:json` response middleware.
- `Happi::Client` requires `logger` itself rather than relying on Faraday to load it, which
  raised `NameError: uninitialized constant Logger` under Faraday 1.x.
- JSON responses are parsed regardless of `use_json`, restoring 0.6.0 behaviour where
  `ParseJson` was registered unconditionally. `use_json` selects the request encoding only -
  JSON body versus multipart/url-encoded. In `1.0.0-rc2` response parsing was moved inside the
  `use_json` branch, so clients on the default `use_json: false` received an unparsed `String`
  body and raised `NoMethodError` on `with_indifferent_access`.

### Added
- GitHub Actions workflow running the suite against Ruby 3.2, 3.3, 3.4 and 4.0.
- Dev container definition for local development.
- Substantially expanded specs covering the error hierarchy, file handling, configuration
  isolation between base and derived clients, and round trips that exercise the real Faraday
  middleware stack rather than a stubbed connection.
- Contributor documentation (`CLAUDE.md`, Copilot instructions) and Faraday 2.x migration notes
  under `context/`.

## [0.6.0] - 2024-11-13
### Added
- Adds support for Ruby 3.2


## [0.4.0] - 2019-03-05
### Added
- Set original file names for multipart Happi files

[Unreleased]: https://github.com/rdytech/happi/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/rdytech/happi/compare/v0.6.0...v1.0.0
[0.6.0]: https://github.com/rdytech/happi/compare/v0.4.0...v0.6.0
[0.4.0]: https://github.com/rdytech/happi/compare/v0.3.0...v0.4.0


## [0.3.0] - 2018-02-23
### Added
- Ability to set `token_type` in configuration and pass this into `FaradayMiddleware::OAuth2` to avoid `faraday_middleware` 0.11.0 warning about using the default token type. Set `token_type: 'bearer'` to only pass the oauth token as an Authorization header instead of both a header and query string parameter.
- This CHANGELOG.

[Unreleased]: https://github.com/rdytech/happi/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/rdytech/happi/compare/v0.2.0...v0.3.0
