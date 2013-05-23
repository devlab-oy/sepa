module Sepa
  class Client
    def initialize(params)
      check_required_params(params)
      # Initialize savon client with params
      @client = Savon.client(wsdl: params[:wsdl], pretty_print_xml: true, log_level: :warn)
      @soap = SoapRequest.new(params)
      @command = params[:command]
    end

    # Call savon to make the actual request to the server
    def send
      @client.call(@command, xml: @soap.to_xml)
    end

    def get_ar_as_base64
      response = send.body
      command_out = (@command.to_s + "out").to_sym
      response[command_out][:application_response]
    end

    def get_ar_as_string
      Base64.decode64(get_ar_as_base64)
    end

    def get_content_as_base64
      ar = Nokogiri::XML(get_ar_as_string)
      ar.remove_namespaces!
      (ar.at_css "Content").content
    end

    def get_content_as_string
      Base64.decode64(get_content_as_base64)
    end

    # Check that the parameters that are needed for all the commands are provided
    def check_required_params(params)
      if params[:private_key].nil?
        raise ArgumentError, "You didn't provide a private key in the params hash."
      elsif params[:cert].nil?
        raise ArgumentError, "You didn't provide a certificate in the params hash."
      elsif !([:get_user_info, :download_file_list, :download_file, :upload_file]
        .include?(params[:command]))
        raise ArgumentError, %(Your didn't provide a proper command.
        Accepted values are :get_user_info, download_file_list, download_file or
        :upload_file.)
      elsif params[:customer_id].nil?
        raise ArgumentError, "You didn't provide a customer id."
      elsif !(["PRODUCTION", "TEST"].include?(params[:environment]))
        raise ArgumentError, %(You didn't provide a proper environment.
          Accepted environments are PRODUCTION or TEST.)
      elsif params[:wsdl].nil?
        raise ArgumentError, "You didn't provide a WSDL file in the params hash."
      end
    end
  end
end