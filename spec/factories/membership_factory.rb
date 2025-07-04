# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    sequence(:id) { |number| number }
    user
    board
  end
end
