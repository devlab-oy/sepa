module Sepa
  # Contains OP specific soap building functionality
  module OpSoapRequest
    private

    def set_receiver_id
      set_node @template, 'bxd|ReceiverId', 'OKOYFIHH'
    end

    def cert_ns
      OP_PKI
    end
  end
end
