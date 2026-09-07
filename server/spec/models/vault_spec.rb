require 'rails_helper'

RSpec.describe Vault, type: :model do
  it 'generates a unique uuid and api_key upon creation' do
    vault = Vault.create!(name: 'My Vault')
    expect(vault.id).to be_present
    expect(vault.api_key).to start_with('spk_')
  end
end
