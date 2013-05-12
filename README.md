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

### Communicating with the bank

1. Require the gem:

        require 'sepa'

2. Define the hash that will be passed to the gem when initializing it:

        params = {
          private_key: 'path/to/private/key',
          cert: 'path/to/cert',
          command: :command_as_symbol,
          customer_id: '11111111',
          environment: 'PRODUCTION',
          status: 'NEW',
          target_id: '11111111A1',
          language: 'FI',
          file_type: 'TITO',
          wsdl: 'path/to/wsdl(or url)',
          content: payload,
          file_reference: "11111111A12006030329501800000014"
        }

3. Initialize a new instance of the client and pass the params hash

        sepa_client = Sepa::SepaClient.new(params)

4. There are five methods that can be called after initializing the client:

  * Returns the whole soap response as a hash:
  
            sepa_client.call
  
  * Returns the application request in base64 coded format:
  
            sepa_client.get_ar_as_base64
  
  * Returns the application request as a string:
  
            sepa_client.get_ar_as_string
  
  * Returns the content field of the application request in base64 coded format:
  
            sepa_client.get_content_as_base64
  
  * Returns the content field of the application request as a string:
  
            sepa_client.get_content_as_string

***

### Parameter breakdown

* private_key: The path to your private key file. Sepa client currently only supports unencrypted keys, but support for encypted keys will come shortly.

* cert: The path to your certificate file.

* command: Either :download_file_list, :upload_file, :download_file or :get_user_info, depending on what you want to do.

* customer_id: Your personal id with the bank.

* environment: Must be either PRODUCTION or TEST

* status: For filtering stuff. Must be either NEW, DOWNLOADED or ALL

* target_id: Some specification of the folder which to access in the bank.

* language: Language must be either FI, EN or SV

* file_type: File types to upload or download:

  * LMP300 = Laskujen maksupalvelu (lähtevä)
  
  * LUM2 = Valuuttamaksut (lähtevä)
  
  * KTL = Saapuvat viitemaksut (saapuva)
  
  * TITO = Konekielinen tiliote (saapuva)
  
  * NDCORPAYS = Yrityksen maksut XML (lähtevä)
  
  * NDCAMT53L = Konekielinen XML-tiliote (saapuva)
  
  * NDCAMT54L = Saapuvat XML viitemaksu (saapuva)

  * wsdl: Path to the WSDL file. Is identical at least between finnish banks except for the address.

  * content: The actual payload to send. The creation of this file may be supported by the client at some point.

  * file_reference: File reference for :download_file command

***

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
