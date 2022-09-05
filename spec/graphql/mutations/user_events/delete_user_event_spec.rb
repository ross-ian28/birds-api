require 'rails_helper'

RSpec.describe Mutations::DeleteUserEvent, type: :request do
  describe '.resolve' do
    it 'destroys a user event' do
      @user1 = User.create(user_name: 'Garnet', email: 'garnet@universe.com',
                           image: 'https://user-images.githubusercontent.com/99059063/187045147-667959c8-70f2-4fb3-b089-ca81f23a0310.png', description: 'We are a married lesbian couple with kids. We love to play sports and go on adventures!', zip_code: 80220, lat: '39.73', lng: '-104.91')
      @user2 = User.create(user_name: 'Pearl', email: 'pearl@universe.com',
                           image: 'https://user-images.githubusercontent.com/99059063/187045202-04577eee-4d6b-4a6e-8d71-5b96aef2f6fc.png', description: 'I am a non-binary single parent looking for other enby parents.', zip_code: 80220, lat: '39.73', lng: '-104.91')
      @event1 = @user1.events.create(title: 'Lunch at Denison Park',
                                     description: 'We are getting together for a meet-and-greet at Denison Park.', time: '18:00:00', date: '2022-10-09', lat: '39.733', lng: '-104.904', address: '1105 Quebec St', city: 'Denver', state: 'CO', zip: 80220, host: @user1.id)

      @rsvp = UserEvent.create(user_id: @user2.id, event_id: @event1.id)

      expect(UserEvent.count).to eq(2)

      post '/graphql', params: { query: destroy_query(user_id: @user2.id, event_id: @event1.id) }

      json = JSON.parse(response.body)

      data = json['data']['deleteUserEvent']

      expect(data).to include(
        'userId' => @user2.id,
        'eventId' => @event1.id
      )

      expect(UserEvent.count).to eq(1)
    end
  end

  def destroy_query(user_id:, event_id:)
    <<~GQL
      mutation {
        deleteUserEvent(input: {
          userId: #{user_id}
          eventId: #{event_id}
       }) {
          userId
          eventId
          createdAt
        }
      }
    GQL
  end
end
