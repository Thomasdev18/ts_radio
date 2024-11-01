-- Show NUI
local ShowNUI = function(arg)
  SetNuiFocus(arg, arg)
  SendNUIMessage({ action = 'setVisible', data = arg })
end

local onRadio = false
local inChannel = false
local radioVolume = 50
local radioChannel = 0
local micClicks = true
local framework

-- Notify user
local notifyUser = function(description, type)
  lib.notify({ description = description, type = type })
end

-- Play audio
local playAudio = function(audioName, audioRef)
  local source = cache.ped
  local soundId = GetSoundId()

  local sourceType = type(source)
  if sourceType == 'number' then
      PlaySoundFromEntity(soundId, audioName, source, audioRef, false, false)
  else
      PlaySoundFrontend(soundId, audioName, audioRef, true)
  end


  ReleaseSoundId(soundId)
end

-- Connect to a specific radio channel
local connectToRadio = function(channel)
  if inChannel then
    exports['pma-voice']:setRadioChannel(0)
    playAudio('Start_Squelch', 'CB_RADIO_SFX')
  else
    inChannel = true
    exports['pma-voice']:setVoiceProperty('radioEnabled', true)
    playAudio('Start_Squelch', 'CB_RADIO_SFX')
  end
  exports['pma-voice']:setRadioChannel(channel)
  radioChannel = channel

  local channelMessage = channel % 1 > 0 and 'You are now on channel ' .. channel .. ' MHz' or 'You are now on channel ' .. channel .. '0 MHz'
  notifyUser(channelMessage, 'success')
end

-- Leave the current radio channel
local leaveRadio = function()
  if not inChannel then return end

  if radioChannel == 0 then
    notifyUser('You are not connected to any channel', 'error')
    return
  end

  playAudio('End_Squelch', 'CB_RADIO_SFX')
  notifyUser('You have left the radio channel', 'error')

  radioChannel = 0
  inChannel = false
  exports['pma-voice']:setVoiceProperty('radioEnabled', false)
  exports['pma-voice']:setRadioChannel(0)
end

-- Handle the power button functionality
local powerButton = function()
  onRadio = not onRadio

  if not onRadio then
    leaveRadio()
  end

  playAudio(onRadio and "On_High" or "Off_High", 'MP_RADIO_SFX')
end

-- Handle animations
local Anim = function(emote)
  if Config.scullyEmoteMenu then 
    exports.scully_emotemenu:playEmoteByCommand(emote)
  end
end

local roundMath = function(num, decimalPlaces)
    if not decimalPlaces then return math.floor(num + 0.5) end
    local power = 10 ^ decimalPlaces
    return math.floor((num * power) + 0.5) / power
end

-- NUI callback functions

-- Hide UI and cancel emote
local hideUI = function(_, cb)
  ShowNUI(false)
  if Config.scullyEmoteMenu then 
    exports.scully_emotemenu:cancelEmote()
  end
  cb('ok')
end

-- Toggle radio power
local toggleRadioPower = function(data, cb)
  onRadio = data.isOn
  if not onRadio then
    leaveRadio()
  end
  cb('ok')
end


-- Connect to radio callback
local connectToRadioCallback = function(data, cb)
  if not onRadio then return cb('ok') end

  local rchannel = tonumber(data.channel)
  if not rchannel or type(rchannel) ~= "number" or rchannel > Config.maxFrequency or rchannel < 1 then
    notifyUser("This frequency is not available", 'error')
    return cb('ok')
  end

  rchannel = roundMath(rchannel, Config.decimalPlaces)

  if rchannel == radioChannel then
    notifyUser("You're already connected to this channel", 'error')
    return cb('ok')
  end

  local frequency = not Config.whitelistSubChannels and math.floor(rchannel) or rchannel
  if Config.restrictedChannels[frequency] and (not isRestricted(Config.restrictedChannels[frequency])) then
    notifyUser("You cannot connect to this channel", 'error')
    return cb('ok')
  end

  connectToRadio(rchannel)
  cb('ok')
end

-- Leave radio callback
local leaveRadioCallback = function(_, cb)
  leaveRadio()
  cb('ok')
end

-- Power button callback
local powerButtonCallback = function(_, cb)
  powerButton()
  cb(onRadio and 'on' or 'off')
end

-- Trigger notification callback
local triggerNotification = function(_, cb)
  if onRadio then
    -- Logic to trigger a notification (using your server-side logic)
    cb('ok')
  else
    cb('not_on_radio')
  end
end

-- Increase volume
local volumeUp = function(_, cb)
  if not onRadio then return cb('ok') end
  if radioVolume > 95 then
    notifyUser('Maximum volume reached', 'error')
    return
  end

  radioVolume = radioVolume + 5
  notifyUser('New volume level: ' .. radioVolume, 'success')
  exports['pma-voice']:setRadioVolume(radioVolume)
  cb('ok')
end

-- Decrease volume
local volumeDown = function(_, cb)
  if not onRadio then return cb('ok') end
  if radioVolume < 10 then
    notifyUser('Minimum volume reached', 'error')
    return
  end

  radioVolume = radioVolume - 5
  notifyUser('New volume level: ' .. radioVolume, 'success')
  exports['pma-voice']:setRadioVolume(radioVolume)
  cb('ok')
end

-- Toggle mic clicks
local toggleClicks = function(data, cb)
  if not onRadio then return cb('ok') end

  micClicks = data.micClicks or false
  exports['pma-voice']:setVoiceProperty("micClicks", micClicks)
  playAudio(micClicks and "On_High" or "Off_High", 'MP_RADIO_SFX')
  notifyUser('Mic clicks ' .. (micClicks and 'enabled' or 'disabled'), 'success')
  cb('ok')
end

-- Play sound
local playSound = function(data, cb)
  if Config.radioMenuSound then
    local soundName = data.soundName
    if soundName == 'Next' then
      playAudio("On_High", 'MP_RADIO_SFX')
    end
  end
  cb('ok')
end

-- Register NUI callbacks
RegisterNUICallback('hide-ui', hideUI)
RegisterNUICallback('toggleRadioPower', toggleRadioPower)
RegisterNUICallback('connectToRadio', connectToRadioCallback)
RegisterNUICallback('leaveRadio', leaveRadioCallback)
RegisterNUICallback('powerButton', powerButtonCallback)
RegisterNUICallback('triggerNotification', triggerNotification)
RegisterNUICallback('volumeUp', volumeUp)
RegisterNUICallback('volumeDown', volumeDown)
RegisterNUICallback('toggleClicks', toggleClicks)
RegisterNUICallback('playSound', playSound)

-- Event to open the radio interface
RegisterNetEvent('openRadio')
AddEventHandler('openRadio', function(arg)
  ShowNUI(arg)
  Anim('wt')
end)

-- Set mic clicks to default value on player load
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
  exports['pma-voice']:setVoiceProperty("micClicks", true)
end)

RegisterNetEvent('esx:playerLoaded', function()
  exports['pma-voice']:setVoiceProperty("micClicks", true)
end)

-- Check radio item count
AddEventHandler('ox_inventory:itemCount', function(itemName, totalCount)
  if itemName ~= 'radio' then return end
  if totalCount <= 0 and radioChannel ~= 0 then
    powerButton()
  end
end)

-- Handle player death state
if Config.leaveOnDeath then
  AddStateBagChangeHandler('isDead', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value and onRadio and radioChannel ~= 0 then
      leaveRadio()
    end
  end)

  AddEventHandler('esx:onPlayerDeath', function(data)
    if onRadio and radioChannel ~= 0 then
      leaveRadio()
    end
  end)
end


AddEventHandler('onResourceStart', function(resource)
  if resource ~= cache.resource then return end

  local esx = GetResourceState('es_extended')
  local qbx = GetResourceState('qbx_core')
  framework = esx == 'started' and 'ESX' or qbx == 'started' and 'QBX' or nil

  if not framework then error('Unable to detect framework - Compatible with ESX & QBX') end

  local ESX = exports.es_extended:getSharedObject()

  function isRestricted(restrictedChannels)
    if framework == 'QBX' then 
      return restrictedChannels[QBX.PlayerData.job.name] or not QBX.PlayerData.job.onduty
    else 
      ESX.PlayerData = ESX.GetPlayerData()
      return restrictedChannels[ESX.PlayerData.job.name]
    end
  end
end)
