if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'awesome_print'
require 'itunes_receipt_decoder'

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end
