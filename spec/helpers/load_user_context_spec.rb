require 'rspec'
require_relative 'load_user_context'

describe 'LoadUserContext' do

  include LoadUserContext

  let(:server) { double('server') }
  let(:contexts) { user_contexts(server) }

  it 'should be 2 of them' do
    expect(contexts.length).to eq(2)
  end

  it 'should have two keys' do
    expect(contexts.keys).to eq(%w{my_sandbox_id my_sandbox_id_1})
  end


end
