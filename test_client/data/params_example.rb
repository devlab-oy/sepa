# frozen_string_literal: true

PAYLOAD = File.read("#{ROOT_PATH}/test_client/data/payload.xml")

NORDEA_GET_CERTIFICATE_PARAMS = {
  pin:         '1234567890',
  bank:        :nordea,
  command:     :get_certificate,
  customer_id: '11111111',
  environment: 'test',
  signing_csr: NORDEA_CSR,
}.freeze

NORDEA_RENEW_CERTIFICATE_PARAMS = {
  bank: :nordea,
  command: :renew_certificate,
  customer_id: '11111111',
  environment: 'PRODUCTION',
  signing_csr: NORDEA_RENEW_CSR,
  own_signing_certificate: NORDEA_CERT,
  signing_private_key: NORDEA_PRIVATE_KEY,
}.freeze

NORDEA_UPLOAD_FILE_PARAMS = {
  bank:                    :nordea,
  own_signing_certificate: NORDEA_CERT,
  signing_private_key:     NORDEA_PRIVATE_KEY,
  command:                 :upload_file,
  customer_id:             '11111111',
  target_id:               '11111111A1',
  file_type:               'NDCORPAYS',
  content:                 PAYLOAD,
}.freeze

NORDEA_DOWNLOAD_FILE_PARAMS = {
  bank:                    :nordea,
  command:                 :download_file,
  own_signing_certificate: NORDEA_CERT,
  signing_private_key:     NORDEA_PRIVATE_KEY,
  customer_id:             '11111111',
  file_type:               'TITO',
  file_reference:          "11111111A12006030319503000000010",
  target_id:               '11111111A1',
  status:                  'NEW',
}.freeze

NORDEA_DOWNLOAD_FILE_LIST_PARAMS = {
  bank:                    :nordea,
  command:                 :download_file_list,
  own_signing_certificate: NORDEA_CERT,
  signing_private_key:     NORDEA_PRIVATE_KEY,
  customer_id:             '11111111',
  target_id:               '11111111A1',
  status:                  'NEW',
  file_type:               'NDCORPAYL',
}.freeze

NORDEA_GET_USER_INFO_PARAMS = {
  bank:                    :nordea,
  command:                 :get_user_info,
  own_signing_certificate: NORDEA_CERT,
  signing_private_key:     NORDEA_PRIVATE_KEY,
  customer_id:             '11111111',
  environment:             'TEST',
}.freeze

DANSKE_GET_BANK_CERT_PARAMS = {
  environment: 'test',
  bank:        :danske,
  command:     :get_bank_certificate,
  customer_id: '',
}.freeze

DANSKE_CREATE_CERT_PARAMS = {
  bank:                        :danske,
  bank_encryption_certificate: DANSKE_BANK_ENC_CERT,
  command:                     :create_certificate,
  customer_id:                 '',
  environment:                 'test',
  encryption_csr:              DANSKE_ENC_CERT_REQUEST,
  signing_csr:                 DANSKE_SIGNING_CERT_REQUEST,
  pin:                         '1234',
}.freeze

DANSKE_DOWNLOAD_FILE_LIST_PARAMS = {
  bank: :danske,
  command: :download_file_list,
  own_signing_certificate: NORDEA_CERT,
  signing_private_key: NORDEA_PRIVATE_KEY,
  bank_encryption_certificate: DANSKE_BANK_ENC_CERT,
  encryption_private_key: NORDEA_PRIVATE_KEY,
  customer_id: '123456',
  environment: 'production',
  file_type: 'KTL',
}.freeze

OP_GET_CERTIFICATE_PARAMS = {
  bank:        :op,
  environment: :test,
  command:     :get_certificate,
  customer_id: '1234567890',
  pin:         '1234567890123456',
  signing_csr: OP_CSR,
}.freeze

OP_GET_SERVICE_CERTIFICATES_PARAMS = {
  bank:        :op,
  command:     :get_service_certificates,
  customer_id: '',
  environment: 'test',
}.freeze

OP_RENEW_CERTIFICATE_PARAMS = {
  bank: :op,
  command: :renew_certificate,
  customer_id: '1234567890',
  environment: 'test',
  signing_csr: OP_RENEW_CSR,
  own_signing_certificate: OP_CERT,
  signing_private_key: OP_PRIVATE_KEY,
}.freeze

OP_UPLOAD_FILE_PARAMS = {
  bank:                    :op,
  command:                 :upload_file,
  content:                 PAYLOAD,
  customer_id:             '',
  environment:             'test',
  file_type:               'pain.001.001.02',
  own_signing_certificate: OP_CERT,
  signing_private_key:     OP_PRIVATE_KEY,
}.freeze

OP_DOWNLOAD_FILE_PARAMS = {
  bank:                    :op,
  command:                 :download_file,
  customer_id:             '',
  environment:             'test',
  file_reference:          '',
  own_signing_certificate: OP_CERT,
  signing_private_key:     OP_PRIVATE_KEY,
}.freeze

OP_DOWNLOAD_FILE_LIST_PARAMS = {
  bank:                    :op,
  command:                 :download_file_list,
  customer_id:             '',
  environment:             'test',
  file_type:               'pain.002.001.02',
  own_signing_certificate: OP_CERT,
  signing_private_key:     OP_PRIVATE_KEY,
}.freeze
