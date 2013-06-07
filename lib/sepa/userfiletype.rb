module Sepa
  class Userfiletype

    attr_accessor :targetId, :fileType, :fileTypeName, :country, :direction, :filetypeServices
    # Add incoming filetypeservice to array
    def add_filetypeservice(ftservice)
      filetypeServices<<ftservice
    end

    # To get parts of array possible options
    def get_filetypeservices
      # Add condition checking
      filetypeServices
    end
  end
end