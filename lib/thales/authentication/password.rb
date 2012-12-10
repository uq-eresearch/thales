#!/bin/env ruby
#
# Module to support username/password authentication.
#
# Copyright (c) 2012, The University of Queensland. (ITEE eResearch Lab)

require 'pbkdf2'
require 'securerandom'

module Thales

  # Module to organise different authentication mechanisms.
  #
  # Currently, only one authentication mechanism has been implemented:
  # Password. But other authentication mechanisms could be added
  # (e.g. OpenID and other forms of federated authentication).

  module Authentication

    # A basic username and password authentication mechanism.

    class Password

      # Constant used in the auth_type property of the user model
      # to indicate authentication using username and password.

      AUTH_TYPE = 1

      # Checks if the plaintext password matches the stored
      # password for a user with the given username.
      #
      # ==== Parameters
      #
      # +username+:: user name
      # +password+:: plaintext password
      #
      # ==== Returns
      #
      # true if xxx
      #
      # ==== Raises
      #
      # nothing
      
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

      # Length (in bytes) of salt generated by +salt_generate+.
      SALT_LENGTH=32 # 256 bits

      # Recommended number of iterations to use.

      DEFAULT_ITERATIONS=10000

      # Prefix for encoded values.
      PREFIX = 'pbkdf2'

      # Returns a new value that can be used as a salt.

      def self.salt_generate()
        SecureRandom.random_bytes(SALT_LENGTH)
      end

      # Calculates a secure hash of the password.
      #
      # ==== Parameters
      #
      # +iterations+:: the number of iterations to apply
      # +salt+:: salt to use      
      # +password+:: plaintext password
      #
      # ==== Returns
      #
      # Encoded value containing algorithm, iterations, salt and hashed value.

      def self.password_to_key(iterations, salt, password)
        PBKDF2.new(:password => password,
                   :salt => salt,
                   :iterations => iterations,
                   :hash_function => 'SHA256').bin_string
      end

      def self.match?(iterations, salt, key, password)
        return (password_to_key(iterations, salt, password) == key)
      end

      # Returns an encoded value of the hashed password.
      #
      # ==== Parameters
      #
      # +iterations+:: the number of iterations to apply
      # +salt+:: salt to use
      # +password+:: plaintext password
      #
      # ==== Returns
      #
      # Encoded value containing algorithm, iterations, salt and hashed value.

      def self.encode(iterations, salt, password)
        if salt.nil?
          salt = salt_generate
        end
        k = password_to_key(iterations, salt, password)
        "#{PREFIX}/#{iterations}/#{salt.unpack('H*')[0]}/#{k.unpack('H*')[0]}"
      end

      # Decodes the value
      #
      # ==== Parameters
      #
      # +value+:: encoded value
      #
      # ===== Returns
      #
      # "abc".decode # => [i, s, k]

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
