# Devlab / SEPA

[![Code Climate](https://codeclimate.com/github/devlab-oy/sepa.png)](https://codeclimate.com/github/devlab-oy/sepa)
[![Code Climate](https://codeclimate.com/github/devlab-oy/sepa/coverage.png)](https://codeclimate.com/github/devlab-oy/sepa)
[![Build Status](https://travis-ci.org/devlab-oy/sepa.svg?branch=master)](https://travis-ci.org/devlab-oy/sepa)
[![Gem Version](https://badge.fury.io/rb/sepafm.svg)](http://badge.fury.io/rb/sepafm)

This project aims to create an open source implementation of SEPA Financial Messages using Web Services. Project implementation is done in Ruby.

Currently we have support for SEPA Web Services for:

* Nordea
* Danske Bank

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sepafm'
```

And then execute:

```bash
$ bundle
```

Or install it with:

```bash
$ gem install sepafm
```

## Usage

### Require the gem

```ruby
require 'sepafm'
```

### Communicating with the bank

Define parameters hash for client, ie. get Nordea bank statement;

```ruby
params = {
  bank: :nordea,
  command: :download_file,
  signing_private_key: "...your signing private key...",
  own_signing_certificate: "...your signing certificate...",
  customer_id: '11111111',
  target_id: '11111111A1',
  file_type: 'TITO',
  file_reference: "11111111A12006030329501800000014"
}
```

Initialize a new instance of the client and pass the params hash

```ruby
client = Sepa::Client.new params
```

Send request to bank

```ruby
response = client.send_request
```

### Interacting with the response

Make sure response is valid

```ruby
response.valid?
```

Get response content

```ruby
response.content
```

### Downloading Nordea certificate

Define parameters hash for client

```ruby
params = {
  pin: '1234567890',
  bank: :nordea,
  command: :get_certificate,
  customer_id: '11111111',
  environment: 'test',
  signing_csr: "...your signing certificate signing request..."
}
```

Initialize a new instance of the client and pass the params hash

```ruby
client = Sepa::Client.new params
```

Send request to bank

```ruby
response = client.send_request
```

Make sure the response is valid

```ruby
response.valid?
```

Get the certificate from the response

```ruby
response.own_signing_certificate
```

### Downloading Danske bank certificates

#### Bank's certificates

Define parameters hash for client

```ruby
params = {
  bank: :danske,
  target_id: 'DABAFIHH',
  command: :get_bank_certificate,
  customer_id: '360817',
  environment: 'test'
}
```

Initialize a new instance of the client and pass the params hash

```ruby
client = Sepa::Client.new params
```

Send request to bank

```ruby
response = client.send_request
```

Make sure the response is valid

```ruby
response.valid?
```

Get the certificates from the response

```ruby
# Bank's encryption certificate
response.bank_encryption_certificate

# Bank's signing certificate
response.bank_signing_certificate

# Bank's root certificate
response.bank_root_certificate
```

#### Own certificates

Define parameters hash

``` ruby
params = {
  bank: :danske,
  bank_encryption_certificate: '...banks encryption certificate...',
  command: :create_certificate,
  customer_id: '360817',
  environment: 'production',
  encryption_csr: '...encryption certificate signing request...',
  signing_csr: '...signing certificate signing request...',
  pin: '1234'
}
```

Initialize a new instance of the client and pass the params hash

```ruby
client = Sepa::Client.new params
```

Send request to bank

```ruby
response = client.send_request
```

Make sure the response is valid

```ruby
response.valid?
```

Get the certificates from the response

```ruby
# Own encryption certificate
response.own_encryption_certificate

# Own signing certificate
response.own_signing_certificate

# CA Certificate used for signing own certificates
response.ca_certificate
```

---

### Parameter breakdown

* **bank** - The bank you want to send the request to as a symbol. Either :nordea or :danske
* **signing_private_key** - Your signing private key in plain text format
* **signing_certificate** - Your signing certificate in plain text format
* **encryption/signing_csr** - Your certificate signing request in plain text format
* **command** - Must be one of:
    * download_file_list
    * upload_file
    * download_file
    * get_user_info
    * get_certificate
    * get_bank_certificate
    * create_certificate
* **customer_id** - Your customer id with the bank.
* **environment** - Must be either production or test
* **status** - For filtering stuff. Must be either NEW, DOWNLOADED or ALL
* **target_id** - Some specification of the folder which to access in the bank (Nordea only)
* **language** - Language must be either FI, EN or SV
* **file_type** - File types to upload or download:
    * LMP300 = Laskujen maksupalvelu (lähtevä)
    * LUM2 = Valuuttamaksut (lähtevä)
    * KTL = Saapuvat viitemaksut (saapuva)
    * TITO = Konekielinen tiliote (saapuva)
    * NDCORPAYS = Yrityksen maksut XML (lähtevä)
    * NDCAMT53L = Konekielinen XML-tiliote (saapuva)
    * NDCAMT54L = Saapuvat XML viitemaksu (saapuva)
* **content** - The payload to send.
* **file_reference** - File reference for :download_file command
* **pin** - Your personal pin-code provided by the bank

---

## Upcoming features

* Parse responses
    * Bank-to-Customer Statement
        * ISO standard "BankToCustomerStatementV02"
        * XML schema "camt.053.001.02"
    * Bank-to-Customer Debit/Credit Notification
        * ISO standard "BankToCustomerDebitCreditNotificationV02"
        * XML schma "camt.054.001.02"
* Create payloads
    * Customer-to-Bank Statement
        * ISO standard "CustomerCreditTransferInitiationV03"
        * XML schema "pain.001.001.03"

---

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request

## License

Released under the [MIT License](http://opensource.org/licenses/MIT).
