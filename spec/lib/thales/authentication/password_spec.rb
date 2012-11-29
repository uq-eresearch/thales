# RSpec

require 'thales/authentication/password'

describe Thales::Authentication::Password do
  let(:encoded) {
    Thales::Authentication::Password.encode(10000, 'salt', 'password')
  }

  describe '::salt_generate' do

    it 'generates correct length salt' do
      s = Thales::Authentication::Password.salt_generate
      s.length.should == Thales::Authentication::Password::SALT_LENGTH
    end

    it 'generates different salt values' do
      salts = {}
      iterations = 32000
      iterations.times do
        s = Thales::Authentication::Password.salt_generate
        salts[s] = 1
      end
      salts.length.should == iterations
    end

  end

  describe '::password_to_key' do

    it 'generates different keys for different passwords' do
      key = Thales::Authentication::Password.password_to_key(1, 's', 'p')
      key_from_different_password =
        Thales::Authentication::Password.password_to_key(1, 's', 'p2')
      key_from_different_password.should_not == key
    end

    it 'generates different keys for different salts' do
      key = Thales::Authentication::Password.password_to_key(1, 's', 'p')
      key_from_different_salt =
        Thales::Authentication::Password.password_to_key(1, 's2', 'p')
      key_from_different_salt.should_not == key
    end

    it 'generates different keys for different iterations' do
      key = Thales::Authentication::Password.password_to_key(1, 's', 'p')
      key_from_different_iteration =
        Thales::Authentication::Password.password_to_key(2, 's', 'p2')
      key_from_different_iteration.should_not == key
    end

  end

  describe '::match?' do

    it 'matches correct password' do
      p = Thales::Authentication::Password.decode(encoded)
      Thales::Authentication::Password.match?(p[0], p[1], p[2], 'password').should be_true
    end

    it 'does not match incorrect password' do
      p = Thales::Authentication::Password.decode(encoded)
      Thales::Authentication::Password.match?(p[0], p[1], p[2], 'password1').should be_false
    end

  end

end

#EOF
