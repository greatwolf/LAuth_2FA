require 'pl.app'.require_here()
require 'rfc6238'

local HOTP_testvalues =
{
  [0] = "755224",
  "287082",
  "359152",
  "969429",
  "338314",
  "254676",
  "287922",
  "162583",
  "399871",
  "520489",
}

local HOTP_secret = "12345678901234567890"
for count = 0, #HOTP_testvalues do
  local HOTP_actual = HOTP(HOTP_secret, count)
  local HOTP_expected = HOTP_testvalues[count]
  assert(HOTP_actual == HOTP_expected)
end

local TOTP_secrets =
{
  "JBSWY3DPEHPK3PXP",
}

print("TOTP Tests:")
for _, each in ipairs(TOTP_secrets) do
  print(TOTP_base32(each))
end
