require 'rails_helper'
require 'json'

describe Api::MountedDefaultApiUnderTest, type: :api do

  let(:user) { FactoryGirl.create :user }
  let(:token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: "public" }
  let(:unscoped_token) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: "" }
  let(:custom_scope) { FactoryGirl.create :clientless_access_token, resource_owner_id: user.id, scopes: "custom_scope" } #not a default scope

  before (:example) do
    WineBouncer.configure do |c|
      c.auth_strategy = :default

      c.define_resource_owner do
        User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
      end
    end
  end

  context 'tokens and scopes' do
    it 'gives access when the token and scope are correct' do
      get '/default_api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
    end

    it 'gives access when tokens are correct and an non doorkeeper default scope is used.' do
      get '/default_api/oauth2_custom_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{custom_scope.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('oauth2_custom_scope')
    end

    it 'raises an authentication error when the token is invalid' do
      expect { get '/default_api/protected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}-invalid" }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an oauth authentication error when no token is given' do
      expect { get '/default_api/protected' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an auth forbidden authentication error when the user scope is not correct' do
      expect { get '/default_api/protected_with_private_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
    end
  end

  context 'unprotected endpoint' do
    it 'allows to call an unprotected endpoint without token' do
      get '/default_api/unprotected'

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end

    it 'allows to call an unprotected endpoint with token' do
      get '/default_api/unprotected', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('unprotected world')
    end
  end

  context 'protected_without_scopes' do

    it 'allows to call an protected endpoint without scopes' do
      get '/default_api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('protected unscoped world')
    end

    it 'raises an error when an protected endpoint without scopes is called without token ' do
      expect { get '/default_api/protected_without_scope' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end

    it 'raises an error because the user does not have the default scope' do
      expect { get '/default_api/protected_without_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{unscoped_token.token}" }.to raise_exception(WineBouncer::Errors::OAuthForbiddenError)
    end
  end

  context 'oauth2_dsl' do
    it 'allows to call an protected endpoint without scopes' do
      get '/default_api/oauth2_dsl', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('oauth2 dsl')
    end

    it 'allows to call custom scopes' do
      get '/default_api/oauth2_dsl_custom_scope', nil, 'HTTP_AUTHORIZATION' => "Bearer #{custom_scope.token}"
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('oauth2 dsl custom scope')
    end

    it 'raises an error when an protected endpoint without scopes is called without token ' do
      expect { get '/default_api/oauth2_dsl' }.to raise_exception(WineBouncer::Errors::OAuthUnauthorizedError)
    end
  end


  context 'not_described_world' do
    it 'allows to call an endpoint without description' do
      get '/default_api/not_described_world'
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to have_key('hello')
      expect(json['hello']).to eq('non described world')
    end
  end

  context 'resource_owner' do
    it 'is available in the endpoint' do
      get '/default_api/protected_user', nil, 'HTTP_AUTHORIZATION' => "Bearer #{token.token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)

      expect(json).to have_key('hello')
      expect(json['hello']).to eq(user.name)
    end
  end
end
