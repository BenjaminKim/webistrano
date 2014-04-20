module SessionsHelper
  def self._aes(m,k,t)
    (aes = OpenSSL::Cipher::Cipher.new('aes-256-cbc').send(m)).key = Digest::SHA256.digest(k)
    aes.update(t) << aes.final
  end

  def self._encrypt(key, text)
    _aes(:encrypt, key, text)
  end

  def self._decrypt(key, text)
    _aes(:decrypt, key, text)
  end

  def self.encrypt(text)
    _encrypt("zkzkdhxlemvffhdl", text)
  end
  def self.decrypt(text)
    _decrypt("zkzkdhxlemvffhdl", text)
  end
end
