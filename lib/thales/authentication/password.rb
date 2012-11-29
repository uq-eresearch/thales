#!/bin/env ruby
#
# Module to support username/password authentication.
#
# Copyright (C) 2012, The University of Queensland. (ITEE eResearch Lab)

require 'pbkdf2'
require 'securerandom'

# $LOAD_PATH.unshift File.dirname(__FILE__) + '/../../..'
# require 'app/models/user'

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
        else
          (i, s, k) = decode(user.auth_value)
          if match?(i, s, k, password)
            user # success
          else
            nil # fail
          end
        end
      end

      # Transforms a plaintext password into the form that is stored
      # in the user model.

      SALT_LENGTH=32 # 256 bits
      DEFAULT_ITERATIONS=10000
      PREFIX = 'pbkdf2'

      def self.salt_generate()
        SecureRandom.random_bytes(SALT_LENGTH)
      end

      def self.password_to_key(iterations, salt, password)
        PBKDF2.new(:password => password,
                   :salt => salt,
                   :iterations => iterations,
                   :hash_function => 'SHA256').bin_string
      end

      def self.match?(iterations, salt, key, password)
        return (password_to_key(iterations, salt, password) == key)
      end


      def self.encode(iterations, salt, password)
        if salt.nil?
          salt = salt_generate
        end
        k = password_to_key(iterations, salt, password)
        "#{PREFIX}/#{iterations}/#{salt.unpack('H*')[0]}/#{k.unpack('H*')[0]}"
      end

      def self.decode(value)
        (id, i, s, k) = value.split(/\//)

        iterations = i.to_i

        raise "internal error: not #{PREFIX}" if id != PREFIX
        raise "internal error: iterations bad format" if iterations == 0

        salt = [s].pack('H*')
        key = [k].pack('H*')
        [iterations, salt, key]
      end

    end
  end
end

#EOF
