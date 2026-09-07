require 'rails_helper'

RSpec.describe 'Sync API', type: :request do
  let(:vault) { Vault.create!(name: 'Cloud Vault') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{vault.api_key}", 'Content-Type' => 'application/json' } }

  it 'returns 401 when unauthorized' do
    post '/api/v1/sync/delta', params: {}.to_json, headers: { 'Content-Type' => 'application/json' }
    expect(response).to have_http_status(:unauthorized)
  end

  it 'syncs incoming deltas and returns server updates' do
    payload = {
      since: nil,
      deltas: [
        {
          relative_path: '01_Daily/2026-09-02.md',
          encrypted_body: 'ENCRYPTED_BLOB_AAA',
          frontmatter: { title: 'Day 2', tags: ['sre'] },
          content_hash: 'hash_111',
          deleted: false
        }
      ]
    }

    post '/api/v1/sync/delta', params: payload.to_json, headers: auth_headers
    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json['applied_count']).to eq(1)
    expect(json['server_deltas'].length).to eq(1)
    expect(json['server_deltas'][0]['relative_path']).to eq('01_Daily/2026-09-02.md')
  end
end
