local restrictedChannels = Config.restrictedChannels
local framework

lib.addCommand('radio', {
    help = 'Opens the radio',
}, function(source)
    TriggerClientEvent('openRadio', source, true)
end)


RegisterNetEvent('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    local esx = GetResourceState('es_extended')
    local qbx = GetResourceState('qbx_core')
    framework = esx == 'started' and 'ESX' or qbx == 'started' and 'QBX' or nil

    if not framework then error('Unable to detect framework - Compatible with ESX & QBX') end

    local ESX = exports.es_extended:getSharedObject()
    

    if framework == 'QBX' then 
        exports.qbx_core:CreateUseableItem('radio', function(source)
            TriggerClientEvent('openRadio', source, true)
        end)
    else 
        ESX.RegisterUsableItem('radio', function(source)
            TriggerClientEvent('openRadio', source, true)
        end)
    end

    local function getJobDuty(jobs, source)     
        if framework == 'QBX' then 
            local player = exports.qbx_core:GetPlayer(source)
            return jobs[player.PlayerData.job.name] and player.PlayerData.job.onduty
        else 
            local player = ESX.GetPlayerFromId(source)

            return jobs[player.getJob().name]
        end
    end
    
    if not Config.whitelistSubChannels then
        for channel, jobs in pairs(restrictedChannels) do
            for i = 1, 99 do
                restrictedChannels[channel + (i / 100)] = jobs
            end
        end
    end
    
    for channel, jobs in pairs(restrictedChannels) do
        exports['pma-voice']:addChannelCheck(channel, function(source)
            return getJobDuty(jobs, source)
        end)
    end
end)
