package.path  = arg[0]:gsub("(.-[\\/]?)[%w_.]+(%.luac?)$", "%1?%2;") .. package.path
package.cpath = arg[0]:gsub("(.-[\\/]?)[%w_.]+(%.luac?)$", "%1?.dll;") .. package.cpath


require 'rfc6238'
local pp    = require 'pl.pretty'
local lapp  = require 'pl.lapp'

local args = lapp
[[
LAuth - A simple CLI app for two-factor authentication.
Usage: LAuth <action> arguments...

Actions:
  -a, --add     <name> <secret token>   Add a new 2FA base32-encoded HOTP token
  -r, --remove  <name>                  Remove an existing token
      --show    [search pattern]        Show OTP of all tokens in account

options:
  -f, --file (default account.lua)      Filename of the account storage
]]

local basepath = function(filepath)
  return filepath:match "(.+[\\/])[%w._]+"
end

local check_args = function(args)
  local action_count = 0
  local action

  for k, v in pairs(args) do
    if v == true then
      action_count = action_count + 1
      action = k
    end
  end
  lapp.assert(action_count == 1, "Please specify exactly one action.")
  args.action = action
  local account_path = basepath(args.file)
  if not account_path then
    local LAuthpath = basepath(arg[0]) or ""
    args.file = LAuthpath .. args.file
  end
end

local account = 
{
  load = function(filename)
    local infile = io.open(filename, 'r')
    return not infile
           and {}
           or pp.read(infile:read '*a')
  end,

  save = pp.dump,
}

local handlers =
{
  show = function (accounts, args)
    local strfmt = "  %-32s - %s"
    local searchpat = args[1] or ".*"
    print "OTP:"
    for account, secret in pairs(accounts) do
      if account:match(searchpat) then
        print(strfmt:format(account, TOTP_base32(secret)))
      end
    end
  end,

  add = function (accounts, args)
    local name, secret = args[1], args[2]
    lapp.assert(name and secret, "LAuth add <name> <secret token>")
    accounts[name] = secret
  end,

  remove = function (accounts, args)
    local name = args[1]
    lapp.assert(name, "LAuth remove <name>")
    accounts[name] = nil
  end,
}


check_args(args)
local accounts = account.load(args.file)
assert(accounts, "Could not load " .. args.file)
handlers[args.action](accounts, args)
account.save(accounts, args.file)
