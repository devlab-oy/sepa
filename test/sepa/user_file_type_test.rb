require File.expand_path('../../test_helper.rb', __FILE__)

class UserFileTypeTest < MiniTest::Test
  def setup
    @single = Sepa::Filetypeservice.new
    @fts = []
    10.times { @fts<<Sepa::Filetypeservice.new }

    @container = Sepa::Userfiletype.new
    @container.filetypeServices = []
  end

  def test_should_add_incoming_parameter_into_array
    assert @container.add_filetypeservice(@single)
  end

  def test_get_filetypeservices_should_return_array
    @container.filetypeServices = @fts
    assert @container.get_filetypeservices.kind_of?(Array), "Does not return an array"
  end
end