# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'itunes_receipt_decoder/version'

Gem::Specification.new do |spec|
  spec.name = 'itunes_receipt_decoder'
  spec.version = ItunesReceiptDecoder::VERSION
  spec.summary = 'Decode iTunes OS X and iOS receipts'
  spec.description = <<-EOF
    Decode iTunes OS X and iOS receipts without remote server-side validation
    by using the Apple Inc Root Certificate.
  EOF
  spec.license = 'MIT'
  spec.authors = ['mbaasy.com']
  spec.email = 'hello@mbaasy.com'
  spec.homepage = 'https://github.com/mbaasy/itunes_receipt_decoder'

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir['lib/**/*.rb'].reverse
  spec.require_paths = ['lib']

  spec.add_dependency 'CFPropertyList', '~> 2.3'

  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubygems-tasks', '~> 0.2'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.5'
  spec.add_development_dependency 'rubocop', '~> 0.40'
end
