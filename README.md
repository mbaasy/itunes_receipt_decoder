# itunes_receipt_decoder
Decode iTunes OS X and iOS receipts without remote server-side validation by using the Apple Inc Root Certificate.

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

---

Copyright 2015 [mbaasy.com](https://mbaasy.com/). This project is subject to the [MIT Licence](/LICENCE).
