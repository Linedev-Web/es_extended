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
-- Locals
local Menu  = M('ui.menu')

-- Variables
local hasAlreadyEnteredMarker, lastZone
local currentAction, currentActionMsg, currentActionData = nil, nil, {}

-- Properties
module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Init = function()

  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('shops', Config.Locale, translations)

  -- Create Blips
  for k,v in pairs(module.Config.Zones) do
    for i = 1, #v.Pos, 1 do
      local blip = AddBlipForCoord(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z)

      SetBlipSprite (blip, 52)
      SetBlipScale  (blip, 1.0)
      SetBlipColour (blip, 2)
      SetBlipAsShortRange(blip, true)

      BeginTextCommandSetBlipName('STRING')
      AddTextComponentString(_U('shops'))
      EndTextCommandSetBlipName(blip)
    end
  end

  -- Enter / Exit marker events
  local playerCoords = GetEntityCoords(PlayerPedId())
  local isInMarker, letSleep, currentZone = false, false

  for k,v in pairs(module.Config.Zones) do
    for i = 1, #v.Pos, 1 do
      local distance = GetDistanceBetweenCoords(playerCoords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true)

      if distance < module.Config.DrawDistance then
        DrawMarker( module.Config.Type, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, module.Config.Size.x, module.Config.Size.y, module.Config.Size.z, module.Config.Color.r, module.Config.Color.g, module.Config.Color.b, 100, false, true, 2, false, nil, nil, false)
        letSleep = false

        if distance < module.Config.Size.x then
          isInMarker  = true
          currentZone = k
          lastZone    = k
        end
      end
    end
  end

  if isInMarker and not hasAlreadyEnteredMarker then
    hasAlreadyEnteredMarker = true
    TriggerEvent('esx_shops:hasEnteredMarker', currentZone)
  end

  if not isInMarker and hasAlreadyEnteredMarker then
    hasAlreadyEnteredMarker = false
    TriggerEvent('esx_shops:hasExitedMarker', lastZone)
  end

  if letSleep then
    Citizen.Wait(500)
  end

  -- Key Controls
  if currentAction then
    ESX.ShowHelpNotification(currentActionMsg)
    if IsControlJustReleased(0, 38) then
      if currentAction == 'shop_menu' then
        OpenShopMenu(currentActionData.zone)
      end
      currentAction = nil
    end
  else
    Citizen.Wait(500)
  end
end

module.RequestDBItems = function(ShopItems)
  ESX.TriggerServerCallback('esx_shops:requestDBItems', function(ShopItems)
    for k,v in pairs(ShopItems) do
      module.Config.Zones[k].Items = v
    end
  end)
end


function OpenShopMenu(zone)
  local elements = {}
  for i=1, #module.Config.Zones[zone].Items, 1 do
    local item = module.Config.Zones[zone].Items[i]

    table.insert(elements, {
      label      = ('%s - <span style="color:green;">%s</span>'):format(item.label, _U('shop_item', ESX.Math.GroupDigits(item.price))),
      itemLabel = item.label,
      item       = item.item,
      price      = item.price,

      -- menu properties
      value      = 1,
      type       = 'slider',
      min        = 1,
      max        = 100
    })
  end

  Menu.CloseAll()
  Menu.Open('default', GetCurrentResourceName(), 'shop', {
    title    = _U('shop'),
    align    = 'bottom-right',
    elements = elements
  }, function(data, menu)
    Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
      title    = _U('shop_confirm', data.current.value, data.current.itemLabel, ESX.Math.GroupDigits(data.current.price * data.current.value)),
      align    = 'bottom-right',
      elements = {
        {label = _U('no'),  value = 'no'},
        {label = _U('yes'), value = 'yes'}
      }}, function(data2, menu2)
      if data2.current.value == 'yes' then
        TriggerServerEvent('esx_shops:buyItem', data.current.item, data.current.value, zone)
      end

      menu2.close()
    end, function(data2, menu2)
      menu2.close()
    end)
  end, function(data, menu)
    menu.close()

    module.CurrentAction     = 'shop_menu'
    module.CurrentActionMsg  = _U('press_menu')
    module.CurrentActionData = {zone = zone}
  end)
end

