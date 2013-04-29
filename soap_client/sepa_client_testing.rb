require_relative 'sepa_client'

params = {
  private_key: 'keys/nordea.key', # Path for your own private key
  cert: 'keys/nordea.crt',        # Path to your certificate
  command: :get_user_info,   # Command must be one of: :download_file_list, :upload_file, :download_file or :get_user_info. Currently only :download_file_list works but I'm quite hopeful that I will get the others working too.
  customer_id: '11111111',        # Unique customer ID
  status: 'NEW',                  # For filtering stuff. Must be either NEW, DOWNLOADED or ALL
  target_id: '11111111A1',        # Some specification of the folder which to access in the bank. I have no idea how this works however.
  file_type: 'HTMKTO',            # File types to upload or download. HTMKTO is for HTML files. See Nordea's documentation for further details.
  wsdl: 'wsdl/wsdl_nordea.xml'    # The WSDL file used by nordea. Is identical between banks except for the address.
}

sepa_client = SepaClient.new(params) # You just create the client with the parameters described above.
sepa_client.send                     # And use the send method to send the soap request and pray that you get a proper response.