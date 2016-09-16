# Client for testing the gem against banks' test environments
module Testing
  require          "base64"
  require          "sepafm"
  require_relative "data/certs"
  require_relative "data/params"

  content_clients = [
    :nordea_download_file,
    :nordea_download_file_list,
    :nordea_get_user_info,
    :nordea_upload_file,
    :op_download_file,
    :op_download_file_list,
    :op_upload_file,
  ].each_with_object({}) do |i, a|
    a[i] = Sepa::Client.new("#{i.to_s.upcase}_PARAMS".constantize)
  end

  certificate_clients = [
    :danske_create_cert,
    :danske_get_bank_cert,
    :danske_renew_cert,
    :nordea_get_certificate,
    :nordea_renew_certificate,
    :op_get_certificate,
    :op_get_service_certificates,
  ].each_with_object({}) do |i, a|
    a[i] = Sepa::Client.new("#{i.to_s.upcase}_PARAMS".constantize)
  end

  content_clients.each do |name, client|
    response = client.send_request

    if response.response_code == "00"
      puts "\e[32m#{response.response_code} #{response.response_text}\e[0m #{name}"
      puts "\e[31m#{response.errors.full_messages}\e[0m" unless response.valid?
    else
      puts "\e[31m#{response.response_code} #{response.response_text}\e[0m #{name}"
    end

    puts "\n"

    File.write "#{ROOT_PATH}/test_client/log/#{name}.log.xml", response.content
  end

  certificate_clients.each do |name, client|
    response = client.send_request

    if response.response_code == "00"
      puts "\e[32m#{response.response_code} #{response.response_text}\e[0m #{name}"
      puts "\e[31m#{response.errors.full_messages}\e[0m" unless response.valid?
    else
      puts "\e[31m#{response.response_code} #{response.response_text}\e[0m #{name}"
    end

    puts "\n"

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
