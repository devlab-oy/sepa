require 'sepa'

params = {
          bank: :danske,
          target_id: 'Danske FI',
          language: 'EN',
          command: :get_bank_certificate,
          bank_root_cert_serial: '1111110002',
          customer_id: '360817',
          environment: 'TEST',
}

sepa_client = Sepa::Client.new(params)

sepa_client.send