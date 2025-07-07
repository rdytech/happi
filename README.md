# Happi

Happi is a pre-configured Faraday client designed for easy access to RESTful
HTTP APIs. It assumes URLS of the form `https://hostname.com/api/v1/something`.

## Installation

Add this line to your application's Gemfile:

    gem 'happi'

And then execute:

    $ bundle

## Usage

Happi stores its configuration as class-level state, so it's important to
derive your own client from `Happi::Client` rather than using it directly,
which can cause requests to be sent to the wrong endpoint.

```ruby
require 'happi'

class MyClient < Happi::Client
end

MyClient.configure do |config|
  config.host = 'http://localhost:3000'
end

client = Myclient.new(
  oauth_token: '63ba06720acf97959f5ba3e3fe1020bf69a7596e2fe3091f821a35cdfe615ceb')

templates = client.get('templates')[:templates]
templates.each do |template|
  puts template[:name]
end

response = client.post('templates', template: {name: 'test',
                                               file: Happi::File.new(File.join(File.dirname(__FILE__), 'spec/fixtures/award.docx')) } )
template = response[:template]

templates = client.get('templates')[:templates]
template = client.get('templates/1')[:template]

template = client.patch("templates/#{template[:id]}",
  template: {id: template[:id],
  name: 'test' }
)[:template]

client.get('documents')[:documents].each do |document|
  puts document[:name]
end

document = client.post('documents',
    document: {template_id: template[:id],
    name: 'Test Document',
    params: JSON.dump({name: 'Test'}) } )[:document]

puts document[:id]
```

## Configuration

```ruby
MyClient.configure do |config|
  config.host = 'http://localhost:8080'
  config.port = 443
  config.timeout = 60
  config.version = 'v1'
  config.use_json = false
  config.log_level = :debug
end
```

A class deriving from `Happi::Client` can be configured with the following
paramters:

- **config.host** - the hostname of the server
- **config.port** - the TCP port to which requests will be sent.
- **config.timeout** - the maximum time to allow requests to take.
- **config.version** - the API version to interpolate in the URL
- **config.use_json** - when `true`, encode requests as JSON, and intepret
responses as JSON.
- **config.log_level** - when set to `:debug`, will log full request bodies and
paramaters, but will only log URL otherwise. Be aware: setting this to `:debug`
in data-heavy applications can lead to very large log files.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


### Testing

To run the specs

    rspec
