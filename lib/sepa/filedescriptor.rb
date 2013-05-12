module Sepa
  class Filedescriptor
    # Internal class for containment
    attr_accessor :fileReference, :targetId, :serviceId, :serviceIdOwnerName, :fileType, :fileTimestamp, :status

    def initialize
    end
  end
end