# Devlab / SEPA

This project aims to create an open source implementation of SEPA Financial Messages using Web Services. Project implementation will be done in Ruby. We will also create a REST API for this module.

## First milestone

* Support for SEPA Web Services
* Customer-to-Bank Statement. ISO standard "CustomerCreditTransferInitiationV03", XML schema "pain.001.001.03"
* Bank-to-Customer Statement. ISO standard "BankToCustomerStatementV02", XML schema "camt.053.001.02"
* Bank-to-Customer Debit/Credit Notification. ISO standard "BankToCustomerDebitCreditNotificationV02", XML schma "camt.054.001.02"
* Update README

## Installation

Add this line to your application's Gemfile:

    gem 'sepa'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sepa

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the [MIT License](http://opensource.org/licenses/MIT).
