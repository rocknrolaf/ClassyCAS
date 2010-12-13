# TODO: Make User not hard-coded
module ClassyCAS
  module Strategies
    class DeviseDatabase < Base
      attr_accessor :authentication_hash, :password
      
      def valid?
        params_authenticatable? && with_authentication_hash(params)
      end
      
      def authenticate!
        resource = valid_password? && User.find_for_database_authentication(authentication_hash)

        if validate(resource){ resource.valid_password?(password) }
          resource.after_database_authentication
          success!(resource)
        else
          fail(:invalid)
        end
      end
      
      private
      # Simply invokes valid_for_authentication? with the given block and deal with the result.
      def validate(resource, &block)
        result = resource && resource.valid_for_authentication?(&block)

        case result
        when Symbol, String
          fail!(result)
        else
          result
        end
      end

      def valid_password?
        password.present?
      end

      # Check if the model accepts this strategy as params authenticatable.
      def params_authenticatable?
        User.params_authenticatable?(authenticatable_name)
      end

      # Sets the authentication hash and the password from params_auth_hash or http_auth_hash.
      def with_authentication_hash(hash)
        self.authentication_hash = {:email => hash[:username]}
        self.password = hash[:password]
      end

      # Holds the authentication keys.
      def authentication_keys
        @authentication_keys ||= User.authentication_keys
      end

      # Holds the authenticatable name for this class. Devise::Strategies::DatabaseAuthenticatable
      # becomes simply :database.
      def authenticatable_name
        @authenticatable_name ||=
          self.class.name.split("::").last.underscore.sub("_authenticatable", "").to_sym
      end
    end
  end
end

Warden::Strategies.add(:cas_devise_database, ClassyCAS::Strategies::DeviseDatabase)
