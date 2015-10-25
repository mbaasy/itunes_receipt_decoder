# iTunes Receipt Decoder

Decode iTunes OS X and iOS receipts without remote server-side validation by using the Apple Inc Root Certificate.

[![Code Climate](https://codeclimate.com/github/mbaasy/itunes_receipt_decoder/badges/gpa.svg)](https://codeclimate.com/github/mbaasy/itunes_receipt_decoder)
[![Test Coverage](https://codeclimate.com/github/mbaasy/itunes_receipt_decoder/badges/coverage.svg)](https://codeclimate.com/github/mbaasy/itunes_receipt_decoder/coverage)
[![Build Status](https://travis-ci.org/mbaasy/itunes_receipt_decoder.svg?branch=master)](https://travis-ci.org/mbaasy/itunes_receipt_decoder)
[![Gem Version](https://badge.fury.io/rb/itunes_receipt_decoder.svg)](https://badge.fury.io/rb/itunes_receipt_decoder)

## Install

Install from the command line:

```bash
$ gem install itunes_receipt_decoder
```

Or include it in your Gemfile:

```ruby
gem 'itunes_receipt_decoder'
```

## Setup

Download [AppleIncRootCertificate.cer](https://www.apple.com/appleca/AppleIncRootCertificate.cer) file from [Apple's certificate authority page](https://www.apple.com/certificateauthority/), then reference the certificate path like so:

```ruby
ItunesReceiptDecoder::Config.certificate_path = 'path/to/AppleIncRootCertificate.cer'
```

## Usage

```ruby
receipt = ItunesReceiptDecoder::Decode.new(base64_encoded_receipt)
receipt.decode

# result
{
  :application_version => "1",
  :original_application_version => "1.0",
  :environment => "ProductionSandbox",
  :bundle_id => "com.mbaasy.ios.demo",
  :creation_date => 2015-08-13 07:50:46 UTC,
  :in_app => [{
    :expires_date => nil,
    :cancellation_date => nil,
    :quantity => 1,
    :web_order_line_item_id => 0,
    :product_id => "consumable",
    :transaction_id => "1000000166865231",
    :original_transaction_id => "1000000166865231",
    :purchase_date => 2015-08-07 20:37:55 UTC,
    :original_purchase_date => 2015-08-07 20:37:55 UTC
  }, {
    :cancellation_date => nil,
    :quantity => 1,
    :product_id => "monthly",
    :web_order_line_item_id => 1000000030274153,
    :transaction_id => "1000000166965150",
    :original_transaction_id => "1000000166965150",
    :purchase_date => 2015-08-10 06:49:32 UTC,
    :original_purchase_date => 2015-08-10 06:49:33 UTC,
    :expires_date => 2015-08-10 06:54:32 UTC
  }, {
    :cancellation_date => nil,
    :quantity => 1,
    :product_id => "monthly",
    :web_order_line_item_id => 1000000030274154,
    :transaction_id => "1000000166965327",
    :original_transaction_id => "1000000166965150",
    :purchase_date => 2015-08-10 06:54:32 UTC,
    :original_purchase_date => 2015-08-10 06:53:18 UTC,
    :expires_date => 2015-08-10 06:59:32 UTC
  }, {
    :cancellation_date => nil,
    :quantity => 1,
    :product_id => "monthly",
    :web_order_line_item_id => 1000000030274165,
    :transaction_id => "1000000166965895",
    :original_transaction_id => "1000000166965150",
    :purchase_date => 2015-08-10 06:59:32 UTC,
    :original_purchase_date => 2015-08-10 06:57:34 UTC,
    :expires_date => 2015-08-10 07:04:32 UTC
  }, {
    :cancellation_date => nil,
    :quantity => 1,
    :product_id => "monthly",
    :web_order_line_item_id => 1000000030274192,
    :transaction_id => "1000000166967152",
    :original_transaction_id => "1000000166965150",
    :purchase_date => 2015-08-10 07:04:32 UTC,
    :original_purchase_date => 2015-08-10 07:02:33 UTC,
    :expires_date => 2015-08-10 07:09:32 UTC
  }, {
    :cancellation_date => nil,
    :quantity => 1,
    :product_id => "monthly",
    :web_order_line_item_id => 1000000030274219,
    :transaction_id => "1000000166967484",
    :original_transaction_id => "1000000166965150",
    :purchase_date => 2015-08-10 07:09:32 UTC,
    :original_purchase_date => 2015-08-10 07:08:30 UTC,
    :expires_date => 2015-08-10 07:14:32 UTC
  }, {
    :cancellation_date => nil,
    :quantity => 1,
    :product_id => "monthly",
    :web_order_line_item_id => 1000000030274249,
    :transaction_id => "1000000166967782",
    :original_transaction_id => "1000000166965150",
    :purchase_date => 2015-08-10 07:14:32 UTC,
    :original_purchase_date => 2015-08-10 07:12:34 UTC,
    :expires_date => 2015-08-10 07:19:32 UTC
  }]
}
```
The example above is using [this receipt file](/spec/fixtures/receipt.txt).

## Testing

1. Add [AppleIncRootCertificate.cer](https://www.apple.com/appleca/AppleIncRootCertificate.cer) to the repo root path.
1. `bundle install`
1. `rake`

## Todo

* Parse `SKPaymentTransaction#transactionReceipt` style receipts, currently only Grand Unified Receipts from `appStoreReceiptURL` are being parsed.
* Better error handeling and signature validation.

---

Copyright 2015 [mbaasy.com](https://mbaasy.com/). This project is subject to the [MIT Licence](/LICENCE).
