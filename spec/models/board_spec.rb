# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Board, type: :model do
  let_it_be(:board) { create(:board) }
  let_it_be(:not_a_member) { create(:user) }
  let_it_be(:member) { create(:user) }
  let_it_be(:creator) { create(:user) }
  let_it_be(:membership) { create(:membership, user_id: member.id, board_id: board.id) }
  let_it_be(:creatorship) { create(:membership, user_id: creator.id, board_id: board.id) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(board).to be_valid
    end

    it 'is not valid without a title' do
      expect(build_stubbed(:board, title: nil)).to_not be_valid
    end
  end

  context 'associations' do
    it 'has many cards' do
      expect(board).to respond_to(:cards)
    end

    it 'has many action items' do
      expect(board).to respond_to(:action_items)
    end

    it 'has many memberships' do
      expect(board).to respond_to(:memberships)
    end

    it 'has many users' do
      expect(board).to respond_to(:users)
    end

    it 'has many board_permissions_users' do
      expect(board).to respond_to(:board_permissions_users)
    end
  end

  context 'scopes' do
    let_it_be(:destroy_permission) { create(:permission, identifier: 'destroy_board') }
    let_it_be(:toggle_status_permission) { create(:permission, identifier: 'toggle_ready_status') }
    let_it_be(:board1) { create(:board) }
    let_it_be(:board1_second) { create(:board, previous_board_id: board1.id) }

    before do
      create(:board_permissions_user, permission: destroy_permission,
                                      user: creator, board: board)
      create(:board_permissions_user, permission: toggle_status_permission,
                                      user: creator, board: board)
      create(:board_permissions_user, permission: toggle_status_permission,
                                      user: creator, board: board1)
      create(:board_permissions_user, permission: toggle_status_permission,
                                      user: creator, board: board1_second)
    end

    context '.creator_boards' do
      it 'returns boards that user is a creator' do
        expect(Board.creator_boards(creator)).to include(board)
      end

      it "excludes boards that user isn't a creator" do
        expect(Board.creator_boards(creator)).not_to include(board1)
      end
    end

    context '.member_boards' do
      it 'returns boards  that user is a member' do
        expect(Board.member_boards(creator)).to include(board, board1_second)
      end

      it "excludes boards that is not last in board's history" do
        expect(Board.creator_boards(creator)).not_to include(board1)
      end
    end
  end
end
