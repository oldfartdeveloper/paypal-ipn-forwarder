require 'yaml'
require 'rspec'
require 'awesome_print'
require 'timecop'

module PaypalIpnForwarder

  TEST_MODE_ON = true

  # Load the test user configuration from a YAML file.
  # This is used only for regression testing.
  #
  # @return [Array] an array of user configurations
  def from_config
    my_array = Psych.load_file('user_context.yml')
    my_array.length.should == 2
    my_array.map { |hash| UserContext.new(@server, hash, TEST_MODE_ON) }
  end

end
