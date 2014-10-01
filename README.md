# Happi

Happi - preconfigured faraday client

## Installation

Add this line to your application's Gemfile:

    gem 'happi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install happi

## Usage

    require 'happi'

    Happi::Client.configure do |config|
      config.host = 'http://localhost:3000'
    end

    client = Happi::Client.new(
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

## Configuration

```ruby
Happi::Client.configure do |config|
  config.host = 'http://localhost:8080'
  config.port = 443
  config.timeout = 60
  config.version = 'v1'
  config.use_json = false
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


### Testing

To run the specs

    rspec
