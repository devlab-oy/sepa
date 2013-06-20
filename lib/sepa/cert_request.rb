# module Sepa
#    class CertRequest
#     def initialize(params)
#       @command = params.fetch(:command)
#       @sender_id = params.fetch(:customer_id)
#       @ar = ApplicationRequest.new(params).get_as_base64

#       template_path = File.expand_path('../xml_templates/soap/', __FILE__)

#       @body = load_body_template(template_path, @command)
#     end

#     def to_xml
#       construct(@body, @command, @sender_id, @ar).to_xml
#     end

#     private

#       def construct(body, command, sender_id, ar)
#         set_body_contents(body, ar, sender_id)
#       end

#       def load_body_template(template_path, command)
#         case command
#         when :get_certificate
#           path = "#{template_path}/get_certificate.xml"
#         end

#         body_template = File.open(path)
#         body = Nokogiri::XML(body_template)
#         body_template.close

#         body
#       end

#       def set_body_contents(body, ar, sender_id)
#         set_node(body, 'cer|ApplicationRequest', ar)
#         set_node(body, 'cer|SenderId', sender_id)
#         set_node(body, 'cer|RequestId', SecureRandom.hex(17))
#         set_node(body, 'cer|Timestamp', Time.now.iso8601)

#         body
#       end

#       def set_node(doc, node, value)
#         doc.at_css(node).content = value
#       end
#   end
# end