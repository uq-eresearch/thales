
#
# Copyright (C) 2012, The University of Queensland.

require 'digest/sha1'

module Thales
  module Authentication

    class Password

      # Constant used in the auth_type property of the user model
      # to indicate authentication using username and password.

      AUTH_TYPE = 1

      # Check if the plaintext password matches the stored
      # password for a user with the given username.

      def self.authenticate(username, password)

        user = User.where(:auth_name => username,
                          :auth_type => AUTH_TYPE).first
        if user.nil?
          nil # fail
        elsif user.auth_value.nil?
          user # success (no password)
        elsif user.auth_value != one_way_hash(password)
          nil # fail
        else
          user # success
        end
      end

      # Transforms a plaintext password into the form that is stored
      # in the user model.

      def self.one_way_hash(plaintext)
        Digest::SHA1.hexdigest(plaintext)
        # TODO: this needs enhancing for better security
      end

    end
  end
end
