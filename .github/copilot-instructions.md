# Happi - AI Coding Instructions

## Project Overview
Happi is a lightweight Ruby gem that provides a pre-configured Faraday HTTP client wrapper for RESTful APIs. It assumes URL patterns like `https://hostname.com/api/v1/something` and handles OAuth2 authentication, multipart file uploads, and JSON/form-encoded requests.

## Architecture & Design Patterns

### Class-Based Configuration (Critical)
**Never use `Happi::Client` directly** - always create a derived class. Configuration is stored as class-level state, so using the base class directly causes cross-contamination between different API endpoints.

```ruby
# CORRECT: Derive your own client
class MyClient < Happi::Client; end
MyClient.configure { |config| config.host = 'http://api.example.com' }

# WRONG: Never use base class directly
Happi::Client.configure { ... }  # Will pollute all clients
```

This pattern is tested extensively in [spec/client_spec.rb](spec/client_spec.rb#L5-L85) which validates config isolation between base/derived classes at both class and instance levels.

### Configuration Hierarchy
Config precedence: instance-level > class-level > defaults (from `Happi::Configuration.defaults`).

Instance config is set via initializer: `MyClient.new(oauth_token: 'abc123', timeout: 30)`

## Key Components

- **[lib/happi/client.rb](lib/happi/client.rb)**: Main HTTP client with REST verbs (get/post/patch/delete), error handling, OAuth2 middleware integration
- **[lib/happi/configuration.rb](lib/happi/configuration.rb)**: Config object with defaults for host, port, timeout, version, use_json, log_level, token_type
- **[lib/happi/file.rb](lib/happi/file.rb)**: Handles file uploads with MIME type detection, converts to Faraday::UploadIO for multipart requests
- **[lib/happi/error.rb](lib/happi/error.rb)**: HTTP error hierarchy mapping status codes (400-504) to specific exception classes

## Developer Workflows

### Testing
```bash
# Run all specs
bundle exec rspec

# Run specific spec file
bundle exec rspec spec/client_spec.rb
```

RSpec is configured with SimpleCov for coverage reports (see [coverage/index.html](coverage/index.html)).

### Gemfile Variations
- `Gemfile`: Standard dependencies
- `Gemfile.rails32`, `Gemfile.rails41`: Legacy Rails compatibility testing (historical, not actively maintained)

## Critical Conventions

### Multipart File Handling
When a hash value responds to `#multipart`, it's automatically converted by `param_check` method. This enables seamless file uploads:

```ruby
client.post('templates', template: {
  name: 'test',
  file: Happi::File.new('/path/to/file.docx')  # Automatically becomes multipart
})
```

### JSON vs Form Encoding
Controlled by `config.use_json` flag:
- `false` (default): Uses multipart/form-encoded requests
- `true`: Encodes requests as JSON and parses JSON responses

### OAuth2 Token Types
Set `token_type: 'bearer'` to pass OAuth tokens only as Authorization header (not as query param). This avoids faraday_middleware warnings. See [CHANGELOG.md](CHANGELOG.md#L30) for context.

### Logging Behavior
- `log_level: :debug` logs full request bodies/params (can generate large logs)
- `log_level: :info` (default) logs only HTTP method and URL
- Rails logger auto-detected via `Rails.try(:logger)`, falls back to STDOUT

### URL Construction
URLs automatically prefixed with `/api/#{version}/`. The `version` config defaults to `'v1'`. Example:
```ruby
client.get('templates')  # Requests /api/v1/templates
```

## Dependencies
- **faraday ~> 2.13**: Core HTTP client
- **oauth2 ~> 2.0**: Authentication (via FaradayMiddleware::OAuth2)
- **activemodel >= 6.0**: Provides `with_indifferent_access` for response hashes
- **mime-types**: File MIME type detection
- Ruby >= 3.2.0

## Testing Patterns
Specs extensively test configuration isolation, multipart param checking, and connection options. When adding features:
1. Test class-level vs instance-level config behavior
2. Verify derived classes don't pollute base class state
3. Use fixtures from [spec/fixtures/](spec/fixtures/) for file upload tests
