# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BoardSerializer do
  let_it_be(:board) { create(:board, title: 'my title') }

  subject { described_class.new(board).to_json }

  it 'makes json with id' do
    expect(subject['id']).to be_present
  end

  it 'makes json with title' do
    expect(subject).to include '"title":"my title"'
  end

  it 'makes json with slug' do
    expect(subject['slug']).to be_present
  end

  it 'makes json with created at' do
    expect(subject['created_at']).to be_present
  end

  it 'makes json with users' do
    expect(subject['users']).to be_present
  end

  it 'makes json with users_count' do
    expect(subject['users_count']).to be_present
  end

  it 'makes json with private' do
    expect(subject['private']).to be_present
  end

  it 'makes json with boards_count' do
    expect(subject['boards_count']).to be_present
  end
end
