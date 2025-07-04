# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::InviteMembersMutation, type: :request do
  describe '.resolve' do
    let_it_be(:author) { create(:user) }
    let_it_be(:board) { create(:board) }
    let_it_be(:invite_permission) { create(:permission, identifier: 'invite_members') }
    let_it_be(:invitee1) { build_stubbed(:user) }
    let_it_be(:invitee2) { build_stubbed(:user) }
    let_it_be(:membership1) { build_stubbed(:membership, board: board, user: invitee1) }
    let_it_be(:membership2) { build_stubbed(:membership, board: board, user: invitee2) }

    let(:request) do
      post '/graphql', params: { query: query(board_slug: board.slug,
                                              email: "#{invitee1.email},#{invitee2.email}") }
    end

    before do
      create(:membership, board: board, user: author)
      create(:board_permissions_user, permission: invite_permission, user: author, board: board)
    end

    before do
      sign_in author
      allow_any_instance_of(Boards::FindUsersToInvite)
        .to receive(:call)
        .and_return([invitee1, invitee2])
      allow_any_instance_of(Boards::InviteUsers)
        .to receive(:call)
        .and_return(Dry::Monads.Success([membership1, membership2]))
    end

    it 'returns a list of memberships' do
      request

      expect(json_body.dig('data', 'inviteMembers', 'memberships')).to match_array(
        [
          {
            'id' => membership1.id,
            'ready' => membership1.ready,
            'board' => {
              'id' => membership1.board_id.to_s
            },
            'user' => {
              'id' => membership1.user_id.to_s
            }
          },
          {
            'id' => membership2.id,
            'ready' => membership2.ready,
            'board' => {
              'id' => membership2.board_id.to_s
            },
            'user' => {
              'id' => membership2.user_id.to_s
            }
          }
        ]
      )
    end
  end

  def query(board_slug:, email:)
    <<~GQL
      mutation {
        inviteMembers(
          input: {
            boardSlug: "#{board_slug}"
            email: "#{email}"
          }
        ) {
          memberships {
            id
            ready
            user {
              id
            }
            board {
              id
            }
          }
          errors {
            fullMessages
          }
        }
      }
    GQL
  end
end
