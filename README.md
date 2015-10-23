# iTunes Receipt Decoder

Decode iTunes OS X and iOS receipts without remote server-side validation by using the Apple Inc Root Certificate.

[![Code Climate](https://codeclimate.com/repos/562a9bf3e30ba02b00002fe1/badges/af7d413fc6697c2d5139/gpa.svg)](https://codeclimate.com/repos/562a9bf3e30ba02b00002fe1/feed)
[![Test Coverage](https://codeclimate.com/repos/562a9bf3e30ba02b00002fe1/badges/af7d413fc6697c2d5139/coverage.svg)](https://codeclimate.com/repos/562a9bf3e30ba02b00002fe1/coverage)
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

Download [AppleIncRootCertificate.cer](https://www.apple.com/appleca/AppleIncRootCertificate.cer) file from [Apple's certificate authority page](https://www.apple.com/certificateauthority/). Then reference the certificate path like so:

```ruby
ItunesReceiptDecoder::Config.certificate_path = 'path/to/AppleIncRootCertificate.cer'
```

## Usage

```ruby
receipt = ItunesReceiptDecoder::Decode.new(base64_encoded_receipt)
receipt.decode
```

## Todo

* Parse `SKPaymentTransaction#transactionReceipt` style receipts, currently only Grand Unified Receipts from `appStoreReceiptURL` are being parsed.
* Better error handeling and signature validation.

---

Copyright 2015 [mbaasy.com](https://mbaasy.com/). This project is subject to the [MIT Licence](/LICENCE).
