class Userfiletype

  attr_accessor :targetId, :fileType, :fileTypeName, :country, :direction

  targetId,fileType,fileTypeName,country,direction = ''
  filetypeServices = []

  #add incoming filetypeservice to array
  def add_filetypeservice(ftservice)
    filetypeServices<<ftservice 
  end

  #to get the full array with possible options
  def get_filetypeservices
    ftservices = Array.new
    filetypeServices.each do |ftservice|
      ftservices<<ftservice
    end
    ftservices
  end

end