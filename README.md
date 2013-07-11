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
          bank: :nordea,
          private_key_path: "path/to/key", (OR private_key_plain : "Your private key in plain text form ")
          cert_path: "path/to/key", (OR cert_plain : "Your certificate in plain text form ")
          command: :command_as_symbol,
          customer_id: '11111111',
          environment: 'PRODUCTION',
          status: 'NEW',
          target_id: '11111111A1',
          language: 'FI',
          file_type: 'TITO',
          content: payload,
          file_reference: "11111111A12006030329501800000014"
        }

3. Initialize a new instance of the client and pass the params hash

        sepa_client = Sepa::Client.new(params)

4. There is only one method that can be called after initializing the client:

  * Returns the whole soap response as a savon response object:

            response = client.send

### Verifying the response

* Check that the hashes match in the response

        response.hashes_match?

        # You can also provide an optional parameter verbose:true
        # if you want to see which hashes failed to verify.

        response.hashes_match?(verbose: true)

* Check that the signature of the response is valid

        response.signature_is_valid?

* Extract the certificate from the response

        # Will return an OpenSSL::X509::Certificate object
        response.certificate

* Check that the certificate is trusted against a root cert

        # The root cert has to be of type OpenSSL::X509::Certificate
        response.cert_is_trusted?(root_cert)

### Verifying the application response

1. Extract the application request from the request

        ar = response.application_request

* Check that the hashes match in the application response

        ar.hashes_match?

* Check that the signature of the application response is valid

        ar.signature_is_valid?

* Extract the certificate from the application response

        # Will return an OpenSSL::X509::Certificate object
        ar.certificate

* Check that the certificate is trusted against a root cert

        # The root cert has to be of type OpenSSL::X509::Certificate
        ar.cert_is_trusted?(root_cert)

### For downloading Nordea certificate

1. Require the gem:

        require 'sepa'

2. Define the hash that will be passed to the gem when initializing it:

        params = {
          bank: :nordea,
          command: :get_certificate,
          customer_id: '11111111',
          environment: 'TEST',
          csr_path: "path_to_your_local_csr_file", (OR csr_plain: "your csr in plain text format")
          service: 'service'
        }

3. Initialize a new instance of the client and pass the params hash

        sepa_client = Sepa::Client.new(params)
        sepa_client.call

4. Save the certificate from the response into a local file

### For downloading Danske bank certificates

1. Require the gem:

        require 'sepa'

2. Define the hash that will be passed to the gem when initializing it:

        params = {
          bank: :danske,
          target_id: 'Danske FI',
          language: 'EN',
          command: :get_bank_certificate,
          bank_root_cert_serial: '1111110002',
          customer_id: '360817',
          environment: 'TEST',
        }

3. Initialize a new instance of the client and pass the params hash

        sepa_client = Sepa::Client.new(params)
        sepa_client.call

4. Save the certificates from the response into a local file

***

### Parameter breakdown

* bank : The bank you want to send the request to as a symbol. Either :nordea or :danske

* private_key_plain: Your private key in plain text format

* private_key_path: Path to your local private key file

* cert_plain: Your certificate in plain text format.

* cert_path: Path to your local certificate file

* csr_plain: Your certificate signing request in plain text format

* csr_path: Path to your local certificate signing request file

* command: Either :download_file_list, :upload_file, :download_file, :get_user_info, :get_certificate or :get_bank_certificate, depending on what you want to do.

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

* content: The actual payload to send. The creation of this file may be supported by the client at some point.

* file_reference: File reference for :download_file command

* pin: Your personal pin-code provided by the bank

* service: For testing value is service, otherwise ISSUER

* bank_root_cert_serial: Serial number for Danske bank certificate download (1111110002)

***

### Parsing data from bank response xml
Parsing based on specifications by Federation of Finnish Financial Services provided xml examples account statement [XML account statement](http://www.fkl.fi/teemasivut/sepa/tekninen_dokumentaatio/Dokumentit/FI_camt_053_sample.xml.xml) and debit credit notification [XML debit credit notification](http://www.fkl.fi/teemasivut/sepa/tekninen_dokumentaatio/Dokumentit/FI_camt_054_sample.xml.xml) and ISO20022 transaction reporting guide [ISO20022 Transaction reporting guide](http://www.fkl.fi/en/themes/sepa/sepa_documents/Dokumentit/ISO20022_Payment_Guide.pdf)
* Hardcode wanted specs into app_response.rb methods get_account_statement_content/get_debit_credit_notification_content
* Create new instance of ApplicationResponse
* method get_account_statement_content takes a bank statement file (xml) as a parameter and returns selected info in a hash
* method get_debit_credit_notification_content takes a debit credit notification file (xml) as a parameter and returns selected info in a hash
* method animate_response takes a full application response xml as a parameter and parses data into objects, can be used to take out different formats of Content-field, without predefined parameter specs

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the [MIT License](http://opensource.org/licenses/MIT).
