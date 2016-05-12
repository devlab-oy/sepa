# Devlab / SEPA

[![Code Climate](https://codeclimate.com/github/devlab-oy/sepa/badges/gpa.svg)](https://codeclimate.com/github/devlab-oy/sepa)
[![Test Coverage](https://codeclimate.com/github/devlab-oy/sepa/badges/coverage.svg)](https://codeclimate.com/github/devlab-oy/sepa)
[![Build Status](https://travis-ci.org/devlab-oy/sepa.svg?branch=master)](https://travis-ci.org/devlab-oy/sepa)
[![Gem Version](https://badge.fury.io/rb/sepafm.svg)](http://badge.fury.io/rb/sepafm)

This project aims to create an open source implementation of SEPA Financial Messages using Web Services. Project implementation is done in Ruby.

Currently we have support for SEPA Web Services for

* Nordea
* Danske Bank
* OP

## Installation

Add this line to your application's Gemfile

```ruby
gem 'sepafm'
```

And then execute

```bash
$ bundle
```

**Or** install gem with

```bash
$ gem install sepafm
```

And require it in your code

```ruby
require 'sepafm'
```

## Using the Gem

Define parameters hash for client, ie. get Nordea bank statement

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

Make sure response is valid

```ruby
response.valid?
```

Get response content

```ruby
response.content
```

## Getting Started

First, you need certificates from your bank. For basic requests you'll need

* Your signing certificate
* Private key for your signing certificate
* Your encryption certificate (Danske Only)
* Private key for your encryption certificate (Danske Only)
* Banks encryption certificate (Danske Only)

You have to get your bank to sign your signing/encryption certificate(s). For this you need to make

* Your signing certificate signing request
* Your encryption certificate signing request (Danske Only)

You can generate your certificate signing requests with `openssl`

```bash
openssl req -out encryption.csr -new -newkey rsa:2048 -nodes -keyout encryption.key
openssl req -out signing.csr -new -newkey rsa:2048 -nodes -keyout signing.key
```

*(For Nordea the key is 1024 bits)*

Enter your information and you should have four files

```
encryption.csr
encryption.key
signing.csr
signing.key
```

### Downloading Nordea and OP Certificates

Define parameters hash for client

```ruby
params = {
  pin: '1234567890',
  bank: :nordea|:op,
  command: :get_certificate,
  customer_id: '11111111',
  environment: 'test',
  signing_csr: "...your signing.csr content..."
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

Get the certificate from the response and save it in a safe place

```ruby
response.own_signing_certificate
```

### Downloading Danske Bank Certificates

**Bank's certificates**

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

Get the certificates from the response and save them in a safe place

```ruby
# Bank's encryption certificate
response.bank_encryption_certificate

# Bank's signing certificate
response.bank_signing_certificate

# Bank's root certificate
response.bank_root_certificate
```

**Own certificates**

Define parameters hash

``` ruby
params = {
  bank: :danske,
  bank_encryption_certificate: '...banks encryption certificate content from above...',
  command: :create_certificate,
  customer_id: '360817',
  environment: 'production',
  encryption_csr: '...your encryption.csr content ...',
  signing_csr: '...your signing.csr content...',
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

Get the certificates from the response and save them in a safe place

```ruby
# Own encryption certificate
response.own_encryption_certificate

# Own signing certificate
response.own_signing_certificate

# CA Certificate used for signing own certificates
response.ca_certificate
```

## Client Parameters

Not all parameters are needed in every request.

Parameter | Description
--- | ---
bank | Bank you want to send the request to. Either `:nordea`, `:danske`, or `:op`
customer_id | Customer id from bank.
command | Must be one of: `:download_file_list`, `:upload_file`, `:download_file`, `:get_user_info`, `:get_certificate`, `:get_bank_certificate`, `:create_certificate`, `:get_service_certificates` or `:renew_certificate`.
content | Content to be sent to the bank in `upload_file`.
environment | Bank's environment where the request is sent. Has to be `production` or `test`.
language | Language of the response. Must be either `FI`, `EN`, or `SV`.
target_id | Code used to categorize files. Can be retrieved with `get_user_info` -command. Only used by Nordea.
file_type | Type of the file(s) your are going to download or send. These differ by bank. With Nordea they can be retrieved with `get_user_info` -command.
file_reference | File's unique identification for downloading a file. Retrieved with `download_file_list` -command.
status | Status for the file to be retrieved. Has to be `NEW`, `DOWNLOADED`, or `ALL`.
signing_private_key | Your private key of your signing certificate for signing the request.
encryption_private_key | Your private key of your encryption certificate for decrypting the response.
own_signing_certificate | Your signing certificate, signed by the bank.
bank_encryption_certificate | Encryption certificate of the bank for encrypting the request.
pin | One-time code retrieved from bank which can be used to download new certificates.
signing_csr | Signing certificate signing request.
encryption_csr | Encryption certificate signing request.

## Upcoming Features

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

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request

## License

Released under the [MIT License](http://opensource.org/licenses/MIT).
