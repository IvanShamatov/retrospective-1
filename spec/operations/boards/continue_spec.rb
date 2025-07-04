# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Boards::Continue do
  include Dry::Monads[:result]

  let!(:prev_creator) { create(:user) }
  let!(:current_user) { create(:user) }
  let!(:prev_board) { create(:board) }
  let!(:creatorship) { create(:membership, board: prev_board, user: prev_creator, ready: true) }
  let!(:membership) { create(:membership, board: prev_board, user: current_user) }

  subject { described_class.new(prev_board, current_user).call }

  context 'when prev_board was previously continued' do
    before do
      allow_any_instance_of(described_class)
        .to receive(:prev_board_continued?)
        .and_return(true)
    end

    it { is_expected.to be_a(Dry::Monads::Result::Failure) }
    it 'fails with standard error' do
      expect(subject.failure).to be_a(StandardError)
      expect(subject.failure.message)
        .to eq 'This board was already continued! Only one continuation per board is allowed!'
    end
  end

  context 'when prev_board was not previously continued' do
    let(:permission) { create(:permission) }
    let!(:board_permissions_user) do
      create(:board_permissions_user, permission: permission, user: current_user, board: prev_board)
    end

    before do
      allow_any_instance_of(described_class)
        .to receive(:prev_board_continued?)
        .and_return(false)
    end

    it { is_expected.to be_a(Dry::Monads::Result::Success) }
    it 'returns board in the result value' do
      expect(subject.value!).to be_instance_of(Board)
    end
    it 'duplicates memberships from the previous board' do
      expect { subject }.to change(Membership, :count).by(prev_board.memberships.count)
    end
    it 'assigns duplicated memberships to the new board' do
      expect(subject.value!.users).to contain_exactly(*prev_board.users)
    end
    it 'sets dupicated memberships ready statuses to false' do
      expect(subject.value!.memberships).not_to include(be_ready)
    end
    it 'sets previous privacy settings to new board' do
      expect(subject.value!.private).to eq prev_board.private
    end
    it 'sets previous title to the new board' do
      expect(subject.value!.title).to eq("#{prev_board.title} #2")
    end
    it 'duplicates board_permissions_users from the previous board' do
      expect { subject }.to change(BoardPermissionsUser, :count).by(1)
    end
    it 'assigns duplicated permissions for the board to the same user' do
      expect(subject.value!.board_permissions_users.first.user_id).to eq(current_user.id)
    end
    it 'assigns the same permission for user to the new board' do
      expect(subject.value!.board_permissions_users.first.permission_id).to eq(permission.id)
    end
  end
end
