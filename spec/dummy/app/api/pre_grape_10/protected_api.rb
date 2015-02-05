module Api
  module PreGrape10
    ###
    # Api under test, default doorkeeper scope is 'account'
    ##
    class MountedProtectedApiUnderTest < Grape::API
      desc 'Protected method with public', auth: { scopes: ['public'] }
      get '/protected' do
        { hello: 'world' }
      end

      desc 'Protected method with private', auth: { scopes: ['private'] }
      get '/protected_with_private_scope' do
        { hello: 'scoped world' }
      end

      desc 'Unprotected method'
      get '/unprotected', auth: false do
        { hello: 'unprotected world' }
      end

      desc 'Protected method with public that returns the user name', auth: { scopes: ['public'] }
      get '/protected_user' do
        { hello: resource_owner.name }
      end

      desc 'This method uses Doorkeepers default scopes'
      get '/protected_without_scope' do
        { hello: 'protected unscoped world' }
      end
    end

    class ProtectedApiUnderTest < Grape::API
      default_format :json
      format :json
      use ::WineBouncer::OAuth2
      mount PreGrape10::MountedProtectedApiUnderTest
    end
  end
end
