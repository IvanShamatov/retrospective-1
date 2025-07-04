# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let_it_be(:user) { build_stubbed(:user) }
  let_it_be(:board) { build_stubbed(:board) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      expect(build_stubbed(:user, email: nil)).to_not be_valid
    end
  end

  context 'associations' do
    it 'has many memberships' do
      expect(user).to respond_to(:memberships)
    end

    it 'has many boards' do
      expect(user).to respond_to(:boards)
    end

    it 'has many cards' do
      expect(user).to respond_to(:cards)
    end

    it 'has many teams' do
      expect(user).to respond_to(:teams)
    end

    it 'has many action items' do
      expect(user).to respond_to(:action_items)
    end

    it 'has many board_permissions' do
      expect(user).to respond_to(:board_permissions)
    end

    it 'has many card_permissions' do
      expect(user).to respond_to(:card_permissions)
    end

    it 'has many comment_permissions' do
      expect(user).to respond_to(:comment_permissions)
    end

    it 'has many board permissions users' do
      expect(user).to respond_to(:board_permissions_users)
    end

    it 'has many card permissions users' do
      expect(user).to respond_to(:card_permissions_users)
    end

    it 'has many comment permissions users' do
      expect(user).to respond_to(:comment_permissions_users)
    end
  end

  describe '.from_omniauth' do
    subject { described_class.from_omniauth(*args) }

    context 'when the user exists in the database' do
      let_it_be(:user) do
        create(:user, provider: 'provider', uid: 'uid',
                      email: 'whoever@wherever.com', nickname: 'user_nick')
      end

      context 'when method receives args with matching provider & uid & email & nickname' do
        let(:args) { ['provider', 'uid', { email: 'whoever@wherever.com', nickname: 'user_nick' }] }

        it 'returns db user' do
          expect { subject }.not_to change { described_class.count }

          expect(subject).to eq user
          expect(subject.persisted?).to eq true
          expect(subject).to have_attributes(provider: 'provider', uid: 'uid',
                                             email: 'whoever@wherever.com',
                                             nickname: 'user_nick')
        end
      end

      context 'when method receives args with matching provider & uid & different email' do
        let(:args) { ['provider', 'uid', { email: 'whoeverelse@wherever.com' }] }

        it 'return db user with updated email' do
          expect { subject }.not_to change { described_class.count }

          expect(subject).to eq user
          expect(subject.persisted?).to eq true
          expect(subject).to have_attributes(provider: 'provider', uid: 'uid',
                                             email: 'whoeverelse@wherever.com')
        end
      end

      context 'when method receives args with different provider or uid & matching email' do
        let(:args) { ['other_provider', 'other_uid', { email: 'whoever@wherever.com' }] }

        it 'return db user with updated provider & uid' do
          expect { subject }.not_to change { described_class.count }

          expect(subject).to eq user
          expect(subject.persisted?).to eq true
          expect(subject).to have_attributes(provider: 'other_provider', uid: 'other_uid',
                                             email: 'whoever@wherever.com')
        end
      end
    end

    context 'when the user does not exist in the database' do
      context 'when method receives valid args' do
        let(:args) { ['provider', 'uid', { email: 'whoever@wherever.com', nickname: 'user_nick' }] }

        it 'creates db user' do
          expect { subject }.to change { described_class.count }.by(1)

          expect(subject).to be_a described_class
          expect(subject.persisted?).to eq true
          expect(subject).to have_attributes(provider: 'provider', uid: 'uid',
                                             email: 'whoever@wherever.com',
                                             nickname: 'user_nick')
        end
      end

      context 'when method receives invalid args' do
        let(:args) { ['provider', 'uid', { email: nil }] }

        it 'returns non persised user' do
          expect { subject }.not_to change { described_class.count }

          expect(subject).to be_a described_class
          expect(subject.persisted?).to eq false
        end
      end
    end
  end

  context '#allowed?' do
    context 'with board permissions' do
      subject { user.allowed?('some_identifier', board) }

      context 'when permission exists' do
        let_it_be(:permission) { create(:permission, identifier: 'some_identifier') }
        before { create(:board_permissions_user, user: user, board: board, permission: permission) }

        it { is_expected.to be true }
      end

      context 'when permission does not exist' do
        it { is_expected.to be false }
      end
    end

    context 'with card permissions' do
      let_it_be(:card) { build_stubbed(:card) }
      subject { user.allowed?('some_identifier', card) }

      context 'when permission exists' do
        let_it_be(:permission) { create(:permission, identifier: 'some_identifier') }
        before { create(:card_permissions_user, user: user, card: card, permission: permission) }

        it { is_expected.to be true }
      end

      context 'when permission does not exist' do
        it { is_expected.to be false }
      end
    end

    context 'with comment permissions' do
      let_it_be(:comment) { build_stubbed(:comment) }
      subject { user.allowed?('some_identifier', comment) }

      context 'when permission exists' do
        let_it_be(:permission) { create(:permission, identifier: 'some_identifier') }
        before do
          create(:comment_permissions_user, user: user, comment: comment, permission: permission)
        end

        it { is_expected.to be true }
      end

      context 'when permission does not exist' do
        it { is_expected.to be false }
      end
    end
  end

  describe '#creator?' do
    subject { user.creator?(board) }

    context 'when user is a creator of the board' do
      let_it_be(:permission) { create(:permission, identifier: Permission::MASTER_CREATOR_ID) }
      before do
        create(:board_permissions_user, user: user, board: board, permission: permission)
      end

      it { is_expected.to be true }
    end

    context 'when user is not a creator of the board' do
      it { is_expected.to be false }
    end
  end
end
