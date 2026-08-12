# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`happi` is a small Ruby gem (~200 LOC in `lib/`) wrapping Faraday for RESTful APIs whose
URLs look like `https://host/api/v1/resource`. It is a library, not an app — there is
nothing to run, only specs.

## Commands

```bash
bundle install
bundle exec rspec                      # full suite
bundle exec rake spec                  # what CI runs
bundle exec rspec spec/client_spec.rb          # single file
bundle exec rspec spec/client_spec.rb:105      # single example by line
gem build happi.gemspec                # build the .gem
```

Ruby 3.4.8 (`.ruby-version`); gemspec requires >= 3.2.0; GitHub Actions matrix covers
3.2 / 3.3 / 3.4 / 4.0. Note the system `ruby` on macOS is 2.6 and will fail — use a
version manager or the devcontainer (`mcr.microsoft.com/devcontainers/ruby:1-3.4-bullseye`).

No linter is wired up. `cane` is a dev dependency but has no rake task and no config.
SimpleCov runs automatically from `spec/spec_helper.rb` and writes to `coverage/` (gitignored).

`.buildkite/pipeline.yml` is dead — its script pins rbenv 2.1.5. CI of record is
`.github/workflows/ruby.yml`.

## Architecture

Five files, loaded in order by `lib/happi.rb`: `version`, `error`, `configuration`,
`client`, `file`.

### Config resolution is class-ivar based, and does NOT inherit

`Happi::Client.config` memoizes into `@global_config`, a **class-level instance variable**.
Subclasses get their own `@global_config`, initialized from `Happi::Configuration.defaults`
— they do *not* copy the parent's configured values. `Happi::Client#config` is
`self.class.config.dup` (shallow), so per-instance overrides via
`MyClient.new(host: ..., oauth_token: ...)` never leak back to the class.

Consequence, and the reason README leads with it: configuring `Happi::Client` itself is
global state shared by every consumer that hasn't subclassed. Always subclass. The
isolation matrix in `spec/client_spec.rb` (base vs derived × class vs instance) exists to
pin this down — preserve it when touching `config`.

### Request path

`get/post/patch/delete` → `param_check(params)` → `call` → `connection.send(method, ...)`
→ raise on mapped status → `.body.with_indifferent_access`.

- `url(resource)` hardcodes the `/api/#{config.version}/` prefix. Callers pass only the
  resource path.
- `param_check` recurses hashes and swaps any value responding to `#multipart` for
  `value.multipart` — this is the sole hook that turns a `Happi::File` into a
  `Faraday::UploadIO`. Duck-typed on purpose; don't narrow it to `is_a?(Happi::File)`.
- `connection` is memoized per instance. Mutating `client.config` after the first request
  has no effect.

### Faraday 2 migration (recent, load-bearing)

`FaradayMiddleware` is gone as of 1.0.0-rc2 — it was never compatible with Faraday 2.x and
was never actually a declared dependency. The OAuth2 Authorization header is now set by
hand in `connection` (`"#{token_type || 'Bearer'} #{oauth_token}"`), and JSON uses
Faraday's built-in `:json` request/response middleware. `oauth2`, `multi_json`,
`faraday-follow_redirects`, and `faraday-http` were dropped; `activemodel` became
`activesupport`. Do not reintroduce `faraday_middleware`.

`context/` holds the research notes from that migration (`faraday_2.x.md`,
`oauth2.md`, `FARADAY_2_COMPATIBILITY_REPORT.md`). Background reading, not specs.

## Known traps

- **`config.port` and `config.timeout` are inert.** `connection` calls
  `Faraday.new(config.host)` with no options hash. Port must be embedded in `host`.
- **`use_json: false` (the default) registers no response parser.** Faraday 2 leaves the
  body a `String`, and `String` has no `with_indifferent_access`, so reads raise
  `NoMethodError`. In practice callers need `use_json: true`. The specs only exercise
  connection construction, never a real round-trip, so this isn't caught.
- **Error messages are static.** `Happi::Error` subclasses override `#message` with fixed
  strings, discarding the API body passed to `new`. The real payload is only reachable via
  `error.response`. Also `TooManyRequests` (429) is nested under `ServerError`, not
  `ClientError`.
- **`Happi::Error::ServiceableErrors` is unreachable code.** `included` references
  `::NestedError` (top-level) while the class is defined at
  `ServiceableErrors::NestedError`, and its `initialize` defaults `original` to `$1`.
  Nothing includes it; leave it alone unless deliberately fixing it.
- **`.github/copilot-instructions.md` is stale.** It still documents `oauth2`,
  `activemodel`, and `FaradayMiddleware::OAuth2` as current. Prefer this file and the
  gemspec.
- `Gemfile.lock` is gitignored (library gem) though present locally. `Gemfile.rails32` /
  `Gemfile.rails41` are historical and unusable on the supported Ruby versions.
