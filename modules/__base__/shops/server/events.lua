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


onRequest('esx_shops:buyItem', function(itemName, amount, zone)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  amount = ESX.Math.Round(amount)

  -- is the player trying to exploit?
  if amount < 0 then
    print('esx_shops: ' .. xPlayer.identifier .. ' attempted to exploit the shop!')
    return
  end

  -- get price
  local price = 0
  local itemLabel = ''

  for i=1, #ShopItems[zone], 1 do
    if ShopItems[zone][i].item == itemName then
      price = ShopItems[zone][i].price
      itemLabel = ShopItems[zone][i].label
      break
    end
  end

  price = price * amount

  -- can the player afford this item?
  if xPlayer.getMoney() >= price then
    -- can the player carry the said amount of x item?
    if xPlayer.canCarryItem(itemName, amount) then
      xPlayer.removeMoney(price)
      xPlayer.addInventoryItem(itemName, amount)
      xPlayer.showNotification(_U('bought', amount, itemLabel, ESX.Math.GroupDigits(price)))
    else
      xPlayer.showNotification(_U('player_cannot_hold'))
    end
  else
    local missingMoney = price - xPlayer.getMoney()
    xPlayer.showNotification(_U('not_enough', ESX.Math.GroupDigits(missingMoney)))
  end
end)

