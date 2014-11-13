local hascrypto, crypto = pcall(require, 'crypto')
if hascrypto then
  print "Using luacrypto"
  return crypto.hmac.digest 
end

local sha1 = require 'extern.sha1'
print "Using sha1.lua"
return function(hash, c, secret)
  assert(hash == "sha1", "unsupported digest type")
  return sha1.hmac_binary(secret, c)
end
