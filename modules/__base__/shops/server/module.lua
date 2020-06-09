-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code
M('table')
M('persistent')

module.Config = run('data/config.lua', {vector3 = vector3})['Config']
module.Init = function()
  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('shops', Config.Locale, translations)
end

Shops = Persist('shops', 'id', Enrolable)

local ShopItems = {}

Shops.define({
  { name = 'id',    field = { name = 'id',    type = 'INT',     length = nil, default = nil, extra = 'NOT NULL AUTO_INCREMENT' } },
  { name = 'store', field = { name = 'store', type = 'VARCHAR', length = 64,  default = nil, extra = 'NOT NULL' } },
  { name = 'item',  field = { name = 'item',  type = 'VARCHAR', length = 64,  default = nil, extra = 'NOT NULL' } },
  { name = 'price', field = { name = 'price', type = 'INT',     length = nil, default = nil, extra = 'NOT NULL' } },
})


Shops.all = setmetatable({}, {
  __index = function(t, k) return rawget(t, tostring(k)) end,
  __newindex = function(t, k, v) rawset(t, tostring(k), v) end,
})

Shops.fromId = function(id)
  return Shops.all[id]
end

ESX.RegisterServerCallback('esx_shops:requestDBItems', function(source, cb)
  cb(ShopItems)
end)
