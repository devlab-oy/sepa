# Devlab / SEPA

[![Code Climate](https://codeclimate.com/github/devlab-oy/sepa.png)](https://codeclimate.com/github/devlab-oy/sepa)
[![Code Climate](https://codeclimate.com/github/devlab-oy/sepa/coverage.png)](https://codeclimate.com/github/devlab-oy/sepa)

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

### Communicating with the bank

Define parameters hash for client, ie. get bank statement;

```ruby
params = {
  bank: :nordea,
  command: :download_file,
  private_key: "...your private key...",
  cert: "...your certificate...",
  customer_id: '11111111',
  file_type: 'NDCAMT53L',
  file_reference: "11111111A12006030329501800000014",
  target_id: '11111111A1',
  status: 'NEW'
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

Get reponse content

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
  environment: 'TEST',
  csr: "...your csr...",
  service: 'service'
}
```

Initialize a new instance of the client and pass the params hash

```ruby
client = Sepa::Client.new params
response = client.send_request
```

Get the certificates from the response

```ruby
response.content
```

### Downloading Danske bank certificates

Define parameters hash for client

```ruby
params = {
  bank: :danske,
  target_id: 'Danske FI',
  language: 'EN',
  command: :get_bank_certificate,
  bank_root_cert_serial: '1111110002',
  customer_id: '360817',
  environment: 'TEST'
}
```

Initialize a new instance of the client and pass the params hash

```ruby
client = Sepa::Client.new params
response = client.send_request
```

Get the certificates from the response

```ruby
response.content
```

---

### Parameter breakdown

* **bank** - The bank you want to send the request to as a symbol. Either :nordea or :danske
* **private_key** - Your private key in plain text format
* **cert** - Your certificate in plain text format
* **csr** - Your certificate signing request in plain text format
* **command** - Must be one of:
    * download_file_list
    * upload_file
    * download_file
    * get_user_info
    * get_certificate
    * get_bank_certificate
* **customer_id** - Your personal id with the bank.
* **environment** - Must be either PRODUCTION or TEST
* **status** - For filtering stuff. Must be either NEW, DOWNLOADED or ALL
* **target_id** - Some specification of the folder which to access in the bank.
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
* **service** - For testing value is service, otherwise ISSUER
* **bank_root_cert_serial** - Serial number for Danske bank certificate download (1111110002)

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
