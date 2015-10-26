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

## Example of a Grand Unified Receipt

```ruby
decoder = ItunesReceiptDecoder.new(base64_encoded_receipt)
decoder.decode # => ItunesReceiptDecoder::Decode::UnifiedReceipt

decoder.receipt # =>
{
  :application_version=>"1",
  :original_application_version=>"1.0",
  :environment=>"ProductionSandbox",
  :bundle_id=>"com.mbaasy.ios.demo",
  :creation_date=>"2015-08-13T07:50:46Z",
  :in_app=> [{
    :expires_date=>"",
    :cancellation_date=>"",
    :quantity=>1,
    :web_order_line_item_id=>0,
    :product_id=>"consumable",
    :transaction_id=>"1000000166865231",
    :original_transaction_id=>"1000000166865231",
    :purchase_date=>"2015-08-07T20:37:55Z",
    :original_purchase_date=>"2015-08-07T20:37:55Z"
  }, {
    :cancellation_date=>"",
    :quantity=>1,
    :product_id=>"monthly",
    :web_order_line_item_id=>1000000030274153,
    :transaction_id=>"1000000166965150",
    :original_transaction_id=>"1000000166965150",
    :purchase_date=>"2015-08-10T06:49:32Z",
    :original_purchase_date=>"2015-08-10T06:49:33Z",
    :expires_date=>"2015-08-10T06:54:32Z"
  }, {
    :cancellation_date=>"",
    :quantity=>1,
    :product_id=>"monthly",
    :web_order_line_item_id=>1000000030274154,
    :transaction_id=>"1000000166965327",
    :original_transaction_id=>"1000000166965150",
    :purchase_date=>"2015-08-10T06:54:32Z",
    :original_purchase_date=>"2015-08-10T06:53:18Z",
    :expires_date=>"2015-08-10T06:59:32Z"
  }, {
    :cancellation_date=>"",
    :quantity=>1,
    :product_id=>"monthly",
    :web_order_line_item_id=>1000000030274165,
    :transaction_id=>"1000000166965895",
    :original_transaction_id=>"1000000166965150",
    :purchase_date=>"2015-08-10T06:59:32Z",
    :original_purchase_date=>"2015-08-10T06:57:34Z",
    :expires_date=>"2015-08-10T07:04:32Z"
  }, {
    :cancellation_date=>"",
    :quantity=>1,
    :product_id=>"monthly",
    :web_order_line_item_id=>1000000030274192,
    :transaction_id=>"1000000166967152",
    :original_transaction_id=>"1000000166965150",
    :purchase_date=>"2015-08-10T07:04:32Z",
    :original_purchase_date=>"2015-08-10T07:02:33Z",
    :expires_date=>"2015-08-10T07:09:32Z"
  }, {
    :cancellation_date=>"",
    :quantity=>1,
    :product_id=>"monthly",
    :web_order_line_item_id=>1000000030274219,
    :transaction_id=>"1000000166967484",
    :original_transaction_id=>"1000000166965150",
    :purchase_date=>"2015-08-10T07:09:32Z",
    :original_purchase_date=>"2015-08-10T07:08:30Z",
    :expires_date=>"2015-08-10T07:14:32Z"
  }, {
    :cancellation_date=>"",
    :quantity=>1,
    :product_id=>"monthly",
    :web_order_line_item_id=>1000000030274249,
    :transaction_id=>"1000000166967782",
    :original_transaction_id=>"1000000166965150",
    :purchase_date=>"2015-08-10T07:14:32Z",
    :original_purchase_date=>"2015-08-10T07:12:34Z",
    :expires_date=>"2015-08-10T07:19:32Z"
  }]
}
```

## Example of a Transaction Receipt

```ruby
decoder = ItunesReceiptDecoder.new(base64_encoded_receipt)
decoder.decode # => ItunesReceiptDecoder::Decode::TransactionReceipt

decoder.receipt # =>
{
  :original_purchase_date_pst=>"2012-04-30 08:05:55 America/Los_Angeles",
  :original_transaction_id=>"1000000046178817",
  :bvrs=>"20120427",
  :transaction_id=>"1000000046178817",
  :quantity=>"1",
  :original_purchase_date_ms=>"1335798355868",
  :product_id=>"consumable",
  :item_id=>"521129812",
  :bid=>"com.mbaasy.ios.demo",
  :purchase_date_ms=>"1335798355868",
  :purchase_date=>"2012-04-30 15:05:55 Etc/GMT",
  :purchase_date_pst=>"2012-04-30 08:05:55 America/Los_Angeles",
  :original_purchase_date=>"2012-04-30 15:05:55 Etc/GMT"
}
```

## Methods and properties

`ItunesReceiptDecoder.new` will return either a `ItunesReceiptDecoder::Decode::UnifiedReceipt` or `ItunesReceiptDecoder::Decode::TransactionReceipt` instance. Both classes have the same public methods available:

`#decode` : Decodes the receipt and returns `self`.

`#receipt` : Returns the receipt properties as a Hash.

`#environment` : Returns the environment as a String.

`#production?` : True if the receipt was created in the Production environment.

`#sandbox?` : True if the receipt was **not** created in the Production environment.

`#style` : Either `:transaction` or `:unified`

## Testing

1. Add [AppleIncRootCertificate.cer](https://www.apple.com/appleca/AppleIncRootCertificate.cer) to the repo root path.
1. `bundle install`
1. `rake`

## Todo

* Better error handeling
* Signature validation

---

Copyright 2015 [mbaasy.com](https://mbaasy.com/). This project is subject to the [MIT Licence](/LICENCE).
