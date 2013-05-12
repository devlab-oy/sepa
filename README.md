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
### Parsing data from bank response xml
Parsing based on specifications by Federation of Finnish Financial Services provided xml examples account statement [XML account statement](http://www.fkl.fi/teemasivut/sepa/tekninen_dokumentaatio/Dokumentit/FI_camt_053_sample.xml.xml) and debit credit notification [XML debit credit notification](http://www.fkl.fi/teemasivut/sepa/tekninen_dokumentaatio/Dokumentit/FI_camt_054_sample.xml.xml) and ISO20022 transaction reporting guide [ISO20022 Transaction reporting guide](http://www.fkl.fi/en/themes/sepa/sepa_documents/Dokumentit/ISO20022_Payment_Guide.pdf)
* Hardcode wanted specs into app_response.rb methods get_account_statement_content/get_debit_credit_notification_content
* Create new instance of ApplicationResponse
* method get_account_statement_content takes a bank statement file (xml) as a parameter and returns selected info in a hash
* method get_debit_credit_notification_content takes a debit credit notification file (xml) as a parameter and returns selected info in a hash
* method animate_response takes a full application response xml as a parameter and parses data into objects, can be used to take out different formats of "content"-field, without predefined parameter specs

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the [MIT License](http://opensource.org/licenses/MIT).
