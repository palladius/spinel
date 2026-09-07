require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:vault) { Vault.create!(name: 'Test Vault') }

  it 'creates and searches frontmatter properties' do
    note = vault.notes.create!(
      relative_path: '01_Daily/today.md',
      encrypted_body: 'enc_data_12345',
      frontmatter: { 'tags' => ['sre', 'cloud'], 'author' => 'Riccardo' },
      content_hash: 'sha256_abcdef'
    )

    expect(note.id).to be_present
    expect(note.version).to eq(1)

    # Test frontmatter search scope
    sre_notes = vault.notes.query_frontmatter('tags', 'sre')
    expect(sre_notes.map(&:id)).to include(note.id)

    author_notes = vault.notes.query_frontmatter('author', 'riccardo')
    expect(author_notes.map(&:id)).to include(note.id)

    other_notes = vault.notes.query_frontmatter('tags', 'ruby')
    expect(other_notes).to be_empty
  end

  it 'handles soft deletes' do
    note = vault.notes.create!(
      relative_path: 'temp.md',
      encrypted_body: 'enc',
      content_hash: 'h1'
    )
    note.soft_delete!
    expect(note.deleted_at).to be_present
    expect(vault.notes.active).not_to include(note)
    expect(vault.notes.deleted).to include(note)
  end
end
