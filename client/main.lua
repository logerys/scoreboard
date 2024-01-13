local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
ESX = exports["es_extended"]:getSharedObject()
local idVisable = true

Citizen.CreateThread(function()
	AddTextEntry('FE_THDR_GTAO', 'Red Roleplay')
end)

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(0)
	end
	Citizen.Wait(2000)
	ESX.TriggerServerCallback('esx_scoreboard:getConnectedPlayers', function(connectedPlayers, maxplayers)
		UpdatePlayerTable(connectedPlayers, maxplayers)
	end)
end)

RegisterNetEvent('esx_scoreboard:updateConnectedPlayers')
AddEventHandler('esx_scoreboard:updateConnectedPlayers', function(connectedPlayers, maxplayers)
	UpdatePlayerTable(connectedPlayers, maxplayers)
end)

RegisterNetEvent('esx_scoreboard:updatePing')
AddEventHandler('esx_scoreboard:updatePing', function(connectedPlayers)
	SendNUIMessage({
		action  = 'updatePing',
		players = connectedPlayers
	})
end)

function UpdatePlayerTable(connectedPlayers, maxplayers)
    local formattedPlayerList = {}
    local totalPlayers = 0
    for i,v in pairs(connectedPlayers) do
        table.insert(formattedPlayerList, ('{"id": "%s", "name": "%s", "ping": "%s"}'):format(v.id, v.name, v.ping))
        totalPlayers = totalPlayers + 1
    end
    --print("["..table.concat(formattedPlayerList).."]")
    SendNUIMessage({
        action  = 'updatePlayerList',
        players = formattedPlayerList,
        maxplayers = maxplayers
    })

    SetDiscordAppId(0000000000) -- Your Discord ID
    SetDiscordRichPresenceAsset('redrp') -- Your RFC Image
    SetDiscordRichPresenceAssetText('Red Roleplay') -- Your RFC Image text
    SetDiscordRichPresenceAssetSmall('red_discord') -- Your RFC Image Small
    SetRichPresence(totalPlayers.."/128 players") -- Player counter
    SetDiscordRichPresenceAssetSmallText('discord.gg/rdrpcz') -- Your RFC Image Small text
end

local firstSpawn = true
AddEventHandler('playerSpawned', function()
    if firstSpawn then
        for _, v in pairs(Config.Buttons) do
            SetDiscordRichPresenceAction(v.index, v.name, v.url)
        end
        firstSpawn = false
    end
end)



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsDisabledControlJustReleased(0, Keys['RIGHT']) and IsInputDisabled(0) then
			pageLister('nextpage')
			Citizen.Wait(200)
		elseif IsDisabledControlJustReleased(0, Keys['LEFT']) and IsInputDisabled(0) then
			pageLister('prevpage')
			Citizen.Wait(200)
		end

		if IsDisabledControlJustReleased(0, Keys['DELETE']) and IsInputDisabled(0) then
			ToggleScoreBoard()
			Citizen.Wait(200)

		-- D-pad up on controllers works, too!
		elseif IsDisabledControlJustReleased(0, 172) and not IsInputDisabled(0) then
			ToggleScoreBoard()
			Citizen.Wait(200)
		end
	end
end)

-- Close scoreboard when game is paused
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(300)

		if IsPauseMenuActive() and not IsPaused then
			IsPaused = true
			SendNUIMessage({
				action  = 'close'
			})
		elseif not IsPauseMenuActive() and IsPaused then
			IsPaused = false
		end
	end
end)

function ToggleScoreBoard()
	SendNUIMessage({
		action = 'toggle'
	})
end

function pageLister(action)
	SendNUIMessage({
		action = action
	})
end

Citizen.CreateThread(function()
	local playMinute, playHour = 0, 0

	while true do
		Citizen.Wait(1000 * 60) -- every minute
		playMinute = playMinute + 1

		if playMinute == 60 then
			playMinute = 0
			playHour = playHour + 1
		end

		SendNUIMessage({
			action = 'updateServerInfo',
			playTime = string.format("%02dh %02dm", playHour, playMinute)
		})
	end
end)
