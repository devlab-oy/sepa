require_relative 'application_request'
require_relative 'soap_request'
require_relative 'sepa_client'

params = { private_key: 'keys/nordea.key', cert: 'keys/nordea.crt', command: 'download_file_list', customer_id: '11111111', status: 'NEW', target_id: '11111111A1', file_type: 'HTMKTO' }

ar = ApplicationRequest.new(params)
soap = SoapRequest.new(params, ar.get_as_base64)
wsdl = 'wsdl/wsdl_nordea.xml'

sepa_client = SepaClient.new(wsdl, soap)
sepa_client.send