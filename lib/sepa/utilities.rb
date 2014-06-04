module Sepa
  module Utilities
    def calculate_digest(node)
      sha1 = OpenSSL::Digest::SHA1.new

      canon_node = node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces=nil, with_comments=false
      )

      Base64.encode64(sha1.digest(canon_node)).gsub(/\s+/, "")
    end

    # Takes a certificate, adds begin and end
    # certificate texts and splits it into multiple lines so that OpenSSL
    # can read it.
    def process_cert_value(cert_value)
      cert = "-----BEGIN CERTIFICATE-----\n"
      cert += cert_value.to_s.gsub(/\s+/, "").scan(/.{1,64}/).join("\n")
      cert += "\n"
      cert + "-----END CERTIFICATE-----"
    end
  end
end