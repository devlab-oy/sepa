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

    gem 'sepafm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sepafm

## Usage

### Building the payload

Optional step:

* You can also have an invoice bundle included in a given transaction. If that is the case, you first have to define the invoices as follows:

        invoice_bundle = []
    
        invoice_1 = {
          type: 'CINV',
          amount: '700',
          currency: 'EUR',
          invoice_number: '123456'
        }
        
        invoice_2 = {
          type: 'CINV',
          amount: '300',
          currency: 'EUR',
          reference: '123456789',
        }
        
        invoice_3 = {
          type: 'CREN',
          amount: '-100',
          currency: 'EUR',
          invoice_number: '654321'
        }
        
        invoice_4 = {
          type: 'CREN',
          amount: '-500',
          currency: 'EUR',
          reference: '987654321'
        }
        
        invoice_bundle.push(invoice_1)
        invoice_bundle.push(invoice_2)
        invoice_bundle.push(invoice_3)
        invoice_bundle.push(invoice_4)

1. Define parameters for the transactions. You need at least one and one payment can have multiple. It is also worth noting that one payload can also have multiple payments. Here's how the parameters are defined:

        transactions_params = {

          # Optional id for the transaction. This is returned to the payer only.
          # Max length is 35 characters.
          instruction_id: '70CEF29BEBA8396A1F806005EDA51DEE4CE',

          # Mandatory id for the transaction. This id is also passed on the the
          # beneficiary. Max length is 35 characters.
          end_to_end_id: '629CADFDAD5246AD915BA24A3C8E9FC3313',

          # Amount to be transferred. Decimals separated by a period.
          amount: '30.75',

          # Currency. For Euros EUR etc.
          currency: 'EUR',

          # Bank's unique BIC.
          bic: 'NDEAFIHH',

          # Name of the creditor company or person
          name: 'Testi Saaja Oy',

          # Street and street number of the creditor.
          address: 'Kokeilukatu 66',

          # Creditor's county code.
          country: 'FI',

          # Creditor's postcode.
          postcode: '00200',

          # Creditor's town
          town: 'Helsinki',

          # Creditor's IBAN.
          iban: 'FI7429501800000014',

          # Reference number for the transaction. Mandatory if message not given.
          reference: '00000000000000001245',

          # Message for the transaction. Mandatory if reference not given.
          message: 'Maksu',

          # Optional set of invoices to be bundled in this transaction. If a bundle
          # is provided amount, currency and reference will be automatically taken
          # from that bundle.
          invoice_bundle: invoice_bundle
        }

2. Create an array of Sepa::Transaction objects in which you put all the transactions of a given payment. You need to create an array for each payment separately.

        payment_transactions = []

        payment_transactions.push(Sepa::Transaction.new(transaction_params))

3. Define the parameters for the payment/payments:

        payment_params = {

          # Unique id the payment. Max length is 35 characters.
          payment_info_id: 'F56D46DDA136A981F58C05999479E768C92',

          # Requested executin date for the payment in form YYY-MM-DD.
          execution_date: '2013-08-10',

          # The array of transactions for this payment
          transactions: payment_transactions

          # If this is a payment consisting of salary of pension transactions, you
          # need to provide the following flag.
          salary_or_pension: true
        }

4. Define parameters for the debtor as follows:

        debtor_params = {
          name: 'Testi Maksaja Oy',
          address: 'Testing Street 12',
          country: 'FI',
          postcode: '00100',
          town: 'Helsinki',
          customer_id: '111111111',
          iban: 'FI4819503000000010',
          bic: 'NDEAFIHH'
        }

5. Create an array of Sepa::Payment objects in which you put all the payments that are going to be in the payload.

        payments = []

        payments.push(Sepa::Payment.new(debtor_params, payment_params))

6. Create the actual payload object:

        payload = Sepa::Payload.new(debtor_params, payments)
        
        # Will return the payload as an xml document which can be included in the
        # construction of the SOAP message.
        payload.to_xml

### Communicating with the bank

1. Require the gem:

        require 'sepafm'

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
          content: payload, # You can use the payload you may have constructed earlier. I.e. payload.to_xml
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

        require 'sepafm'

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

        require 'sepafm'

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
