require 'sepa'

reqid = SecureRandom.random_number(1000).to_s<<SecureRandom.random_number(1000).to_s
puts "Todays lucky number was #{reqid}"
params = {
          bank: :danske,

          target_id: 'Danske FI',

          language: 'EN',

          command: :get_bank_certificate,

          status: 'NEW',

          bank_root_cert_serial: '1111110002',

          wsdl: 'sepa/wsdl/wsdl_danske_cert.xml',

          request_id: reqid,

          customer_id: '360817',

          environment: 'TEST',

          key_generator_type: 'software'
}

sepa_client = Sepa::Client.new(params)

sepa_client.send