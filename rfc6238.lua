-- A Lua implementation of TOTP and HOTP for 
-- 2-factor Authentication as outlined in 
-- rfc6238 and rfc4226.

local hmac   = require 'hmac'
local base32 = require 'extern.basexx'.from_base32

local function hexstr(raw)
  assert(type(raw) == "string")
  local hexstring = ("%02x"):rep(#raw)
  return hexstring:format(raw:byte(1, #raw))
end

local function hexraw(str)
  assert(type(str) == "string")
  if(#str % 2 == 1) then -- add leading pad to make it even
    str = "0" .. str
  end
  local raw = {}
  for i = 1, #str, 2 do
    local byte = tonumber(str:sub(i, i + 1), 16)
    table.insert(raw, string.char(byte))
  end
  return table.concat(raw)
end

function HOTP(secret, c, digits)
  digits = digits or 6
  assert(6 <= digits and digits <= 8)   -- 6 <= digits <= 8
  assert(type(c) == 'number')

  c = hexraw(("%016x"):format(c))
  local hash = hmac("sha1", c, secret, true)
  -- dynamic truck
  local off_begin = hash:sub(#hash):byte() % 16 + 1
  local off_end = off_begin + 3
  local Sbytes = hash:sub(off_begin, off_end)

  assert(#Sbytes == 4)
  Sbytes = tonumber(hexstr(Sbytes), 16)
  -- zero first bit of MSB to avoid sign ambitguity as per rfc4226 spec
  local Snum = Sbytes % 2 ^ 31
  return string.format("%0" .. digits .. "d", Snum % 10 ^ digits)
end

function TOTP(secret, digits, timestamp, interval)
  assert(secret)
  timestamp = timestamp or os.time()
  interval  = interval or 30

  local c = math.floor(timestamp / interval)
  return HOTP(secret, c, digits)
end

function TOTP_base32(secret, ...)
  secret = base32(secret:upper())
  return TOTP(secret, ...)
end
