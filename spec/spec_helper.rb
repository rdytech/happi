require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require 'rspec'
require 'happi'

Dir[File.expand_path('../../spec/support/**/*.rb', __FILE__)].map(&method(:require))

RSpec.configure do |config|
end
