local restrictedChannels = Config.restrictedChannels

lib.addCommand('radio', {
    help = 'Opens the radio',
}, function(source)
    TriggerClientEvent('openRadio', source, true)
end)

exports.qbx_core:CreateUseableItem('radio', function(source)
    TriggerClientEvent('openRadio', source, true)
end)

if not Config.whitelistSubChannels then
    for channel, jobs in pairs(restrictedChannels) do
        for i = 1, 99 do
            restrictedChannels[channel + (i / 100)] = jobs
        end
    end
end

for channel, jobs in pairs(restrictedChannels) do
    exports['pma-voice']:addChannelCheck(channel, function(source)
        local player = exports.qbx_core:GetPlayer(source)
        return jobs[player.PlayerData.job.name] and player.PlayerData.job.onduty
    end)
end