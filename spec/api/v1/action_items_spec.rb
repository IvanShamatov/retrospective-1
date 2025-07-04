# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::V1::ActionItemsController, type: :controller do
  let_it_be(:author) { create(:user) }
  let_it_be(:assignee) { create(:user) }
  let_it_be(:board) { create(:board) }
  let_it_be(:pending_action_item) { create(:action_item, author: author, assignee: assignee) }
  let_it_be(:resolved_action_item) do
    create(:action_item, status: :done, author: author, assignee: assignee)
  end

  let_it_be(:item_attrs) do
    %w[id body times_moved status author assignee]
  end

  before do
    login_as author
    allow(author).to receive(:allowed?).with('create_action_items', board).and_return(true)
    allow(author).to receive(:allowed?).with('update_action_items', board).and_return(true)
    allow(author).to receive(:allowed?).with('destroy_action_items', board).and_return(true)
    allow(author).to receive(:allowed?).with('close_action_items', board).and_return(true)
    allow(author).to receive(:allowed?).with('complete_action_items', board).and_return(true)
    allow(author).to receive(:allowed?).with('reopen_action_items', board).and_return(true)
  end

  describe 'GET /api/v1/action_items/index' do
    before { login_as assignee }

    subject(:response) { get :index }

    it { is_expected.to have_http_status(:ok) }

    it 'returns action_items' do
      expect(json_body.size).to eq(2)
      expect(json_body.first.keys).to match_array(item_attrs)
    end

    it 'should be sorted' do
      expect(json_body.first['status']).to eq('pending')
      expect(json_body.second['status']).to eq('done')
    end
  end

  describe 'POST /api/v1/action_items' do
    subject(:response) do
      post :create, params: { body: 'test item', board_slug: board.slug, assignee_id: author.id }
    end

    it { is_expected.to have_http_status(:ok) }

    it 'return created action item' do
      expect(json_body['body']).to eq('test item')
    end

    it 'create action item in db' do
      expect { subject }.to change { ActionItem.count }.by(1)
    end

    it 'broadcast created item' do
      expect { subject }.to have_broadcasted_to(board).from_channel(ActionItemsChannel)
                                                      .with(start_with('{"data":{"actionItem":'))
    end
  end

  describe 'PUT /api/v1/action_items/:id' do
    let_it_be(:new_assignee) { create(:user) }
    let_it_be(:action_item) { create(:action_item, board: board) }

    subject(:response) do
      put :update, params: { id: action_item.id, body: 'new text', assignee_id: new_assignee.id }
    end

    it { is_expected.to have_http_status(:ok) }

    it 'return updated action item' do
      expect(json_body['body']).to eq('new text')
    end

    it 'broadcast updated item' do
      expect { subject }.to have_broadcasted_to(board).from_channel(ActionItemsChannel)
    end
  end

  describe 'DELETE /api/v1/action_items/:id' do
    let_it_be(:action_item) { create(:action_item, board: board) }

    subject(:response) { delete :destroy, params: { id: action_item.id } }

    it { is_expected.to have_http_status(:ok) }

    it 'delete action item in db' do
      expect { subject }.to change { ActionItem.count }.by(-1)
    end

    it 'broadcast deleted item' do
      expect { subject }.to have_broadcasted_to(board).from_channel(ActionItemsChannel)
    end
  end

  describe 'PUT /api/v1/action_items/:id/close' do
    let_it_be(:action_item) { create(:action_item, board: board) }

    subject(:response) { put :close, params: { id: action_item.id, board_slug: board.slug } }

    it { is_expected.to have_http_status(:ok) }

    it 'action item became closed' do
      expect { subject }.to change { action_item.reload.status }.from('pending').to('closed')
    end

    it 'return closed action item' do
      expect(json_body.keys).to match_array(item_attrs)
    end

    it 'broadcast closed item' do
      expect { subject }.to have_broadcasted_to(board).from_channel(ActionItemsChannel)
    end
  end

  describe 'PUT /api/v1/action_items/:id/compete' do
    let_it_be(:action_item) { create(:action_item, board: board) }

    subject(:response) { put :complete, params: { id: action_item.id, board_slug: board.slug } }

    it { is_expected.to have_http_status(:ok) }

    it 'action item became competed' do
      expect { subject }.to change { action_item.reload.status }.from('pending').to('done')
    end

    it 'return completed action item' do
      expect(json_body.keys).to match_array(item_attrs)
    end

    it 'broadcast completed item' do
      expect { subject }.to have_broadcasted_to(board).from_channel(ActionItemsChannel)
    end
  end

  describe 'PUT /api/v1/action_items/:id/reopen' do
    let_it_be(:action_item) { create(:action_item, board: board, status: 'done') }

    subject(:response) { put :reopen, params: { id: action_item.id, board_slug: board.slug } }

    it { is_expected.to have_http_status(:ok) }

    it 'action item became reopen' do
      expect { subject }.to change { action_item.reload.status }.from('done').to('pending')
    end

    it 'return reopened action item' do
      expect(json_body.keys).to match_array(item_attrs)
    end
  end

  describe 'PUT /api/v1/action_items/:id/move' do
    let_it_be(:new_board) { create(:board) }
    let_it_be(:action_item) { create(:action_item, board: board) }

    subject(:response) { put :move, params: { id: action_item.id, board_slug: new_board.slug } }

    before do
      allow(author).to receive(:allowed?).with('move_action_items', new_board).and_return(true)
    end

    it { is_expected.to have_http_status(:ok) }

    it 'action item became move' do
      expect { subject }.to change { action_item.reload.times_moved }.by(1)
    end

    it 'return moved action item' do
      expect(json_body.keys).to match_array(item_attrs)
    end
  end
end
