require 'rails_helper'

RSpec.describe 'Notes Query API', type: :request do
  let(:vault) { Vault.create!(name: 'Query Vault') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{vault.api_key}" } }

  before do
    vault.notes.create!(
      relative_path: 'sre/incident.md',
      encrypted_body: 'enc_body',
      frontmatter: { 'service' => 'CloudSQL', 'priority' => 'P1' },
      content_hash: 'hash_sre'
    )
  end

  it 'queries notes by frontmatter' do
    get '/api/v1/notes/query', params: { key: 'service', value: 'CloudSQL' }, headers: auth_headers
    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json['count']).to eq(1)
    expect(json['notes'][0]['relative_path']).to eq('sre/incident.md')
  end
end
