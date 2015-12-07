module Testing
  require          "base64"
  require          "sepafm"
  require_relative "data/certs"
  require_relative "data/params"

  content_clients = {
    nordea_download_file:      Sepa::Client.new(NORDEA_DOWNLOAD_FILE_PARAMS),
    nordea_download_file_list: Sepa::Client.new(NORDEA_DOWNLOAD_FILE_LIST_PARAMS),
    nordea_get_user_info:      Sepa::Client.new(NORDEA_GET_USER_INFO_PARAMS),
    nordea_upload_file:        Sepa::Client.new(NORDEA_UPLOAD_FILE_PARAMS),
    op_download_file:          Sepa::Client.new(OP_DOWNLOAD_FILE_PARAMS),
    op_download_file_list:     Sepa::Client.new(OP_DOWNLOAD_FILE_LIST_PARAMS),
    op_upload_file:            Sepa::Client.new(OP_UPLOAD_FILE_PARAMS),
  }

  certificate_clients = {
    danske_create_cert:          Sepa::Client.new(DANSKE_CREATE_CERT_PARAMS),
    danske_get_bank_cert:        Sepa::Client.new(DANSKE_GET_BANK_CERT_PARAMS),
    nordea_get_certificate:      Sepa::Client.new(NORDEA_GET_CERTIFICATE_PARAMS),
    op_get_certificate:          Sepa::Client.new(OP_GET_CERTIFICATE_PARAMS),
    op_get_service_certificates: Sepa::Client.new(OP_GET_SERVICE_CERTIFICATES_PARAMS)
  }

  content_clients.each do |name, client|
    response = client.send_request

    if response.response_code == "00"
      puts "\e[32m#{response.response_code} #{response.response_text}\e[0m #{name}"
      puts "\e[31m#{response.errors.full_messages}\e[0m" unless response.valid?
      puts "\n"
    else
      puts "\e[31m#{response.response_code} #{response.response_text}\e[0m #{name}"
      puts "\n"
    end

    File.write "#{ROOT_PATH}/test_client/log/#{name}.log.xml", response.content
  end

  certificate_clients.each do |name, client|
    response = client.send_request

    if response.response_code == "00"
      puts "\e[32m#{response.response_code} #{response.response_text}\e[0m #{name}"
      puts "\e[31m#{response.errors.full_messages}\e[0m" unless response.valid?
      puts "\n"
    else
      puts "\e[31m#{response.response_code} #{response.response_text}\e[0m #{name}"
      puts "\n"
    end

    contents =
      "# Bank Encryption Certificate:\n#{response.bank_encryption_certificate}\n\n" \
      "# Bank Signing Certificate:\n#{response.bank_signing_certificate}\n\n" \
      "# Bank Root Certificate:\n#{response.bank_root_certificate}\n\n" \
      "# Own Encryption Certificate:\n#{response.own_encryption_certificate}\n\n" \
      "# Own Signing Certificate:\n#{response.own_signing_certificate}\n\n" \
      "# CA Certificate:\n#{response.ca_certificate}\n\n"

    File.write("#{ROOT_PATH}/test_client/log/#{name}.pem", contents)
  end
end
