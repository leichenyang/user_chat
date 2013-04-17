require 'minitest/autorun'
require 'minitest/reporters'
require 'httparty'
require 'json'

MiniTest::Reporters.use! MiniTest::Reporters::SpecReporter.new

def api_base_address
  "http://localhost:3000"
end

def example_message_query(user_name='Siimar Sapikas', message='Good morning')
  {
    body: {
      'user_name' => user_name,
      'message[text]' => message
    }
  }
end

def example_user_query_data(user_name='Siimar Sapikas')
  {
    body: {
      :user => user_name
    }
  }
end

def unique_user_name 
  "Vello Orumets #{Random.rand(10**6)}"
end

describe 'Chat REST API' do
  describe "creating new user" do
    it "POST /users creates new user" do
      name = unique_user_name
      response = HTTParty.post "#{api_base_address}/users", example_user_query_data(name)
      response.code.must_equal 201
      JSON.parse(response.body)['name'].must_equal name
    end

    it "POST /users twice with same name fails" do
      HTTParty.post "#{api_base_address}/users", example_user_query_data
      response = HTTParty.post "#{api_base_address}/users", example_user_query_data
      response.code.must_equal 422
    end
  end

  describe 'sending messages to chat' do

    it 'succeeds with name and text present in message' do
      name = unique_user_name
      HTTParty.post "#{api_base_address}/users", example_user_query_data(name)
      response = HTTParty.post "#{api_base_address}/messages", example_message_query(name, 'Hello!')
      response.code.must_equal 201
    end

    it 'returns message JSON when succeeding' do
      name = unique_user_name
      HTTParty.post "#{api_base_address}/users", example_user_query_data(name)
      response = HTTParty.post "#{api_base_address}/messages", example_message_query(name, 'Hello!')
      parsed_response = JSON.parse(response.body)
      ['id', 'user_id', 'text'].each do |required_key|
        parsed_response.has_key?(required_key).must_equal true, "Expected parsed response JSON to contain #{required_key}"
      end
    end

    it 'fails when message is sent without username' do
      response = HTTParty.post "#{api_base_address}/messages", example_message_query(nil)
      response.code.must_equal 422
    end
    
    it 'fails with empty message' do
      name = unique_user_name
      HTTParty.post "#{api_base_address}/users", example_user_query_data(name)
      response = HTTParty.post "#{api_base_address}/messages", example_message_query(name, nil)
      response.code.must_equal 422
    end
  end

  describe 'getting previous messages' do
    it 'returns all messages by default' do
      name = unique_user_name
      HTTParty.post "#{api_base_address}/users", example_user_query_data(name)
      10.times do |count|
        HTTParty.post "#{api_base_address}/messages", example_message_query(name, "Zat is a message #{count}")
      end

      response = HTTParty.get "#{api_base_address}/messages"
      JSON.parse(response.body).length.must_be :>=, 10
    end

    it 'provides messages after specified by last_message' do
      # Create user
      name = unique_user_name
      HTTParty.post "#{api_base_address}/users", example_user_query_data(name)
      # 1. Post a message
      first_message_response = HTTParty.post "#{api_base_address}/messages", example_message_query(name, "What a nice first message")
      first_json = JSON.parse first_message_response.body
      # 3. Post another message
      last_post_response = HTTParty.post "#{api_base_address}/messages", example_message_query(name, "Second message is second")
      # 4. Get list of messages after the last message in 2.
      messages_after_first = HTTParty.get "#{api_base_address}/messages", {
        body: {
          last_message: first_json['id']
        }
      }
      # 5. Verify that 4. has the same message posted in 3. 
      after_first = JSON.parse messages_after_first
      after_first.length.must_equal 1
    end
  end
end
