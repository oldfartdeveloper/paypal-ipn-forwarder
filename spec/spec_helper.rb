require 'yaml'
require 'rspec'
require 'awesome_print'
require 'timecop'

module PaypalIpnForwarder

  TEST_MODE_ON = true

  YAML_FILE = 'user_context.yml'

  # Load the test user configuration from a YAML file.
  # This is used only for regression testing.
  #
  # @return [Hash] a hash of user configurations key'd by the paypal sandbox ID
  def from_config
    hashes = Psych.load_file(YAML_FILE)
    hashes.keys.each { |key| hashes[key] = UserContext.new(@server, hashes[key], TEST_MODE_ON) }
    hashes
  end

end
