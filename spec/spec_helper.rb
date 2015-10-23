require 'awesome_print'
require 'itunes_receipt_decoder'

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end
