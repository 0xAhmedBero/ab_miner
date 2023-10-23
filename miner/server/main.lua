ESX = nil
ESX = exports["es_extended"]:getSharedObject()

local ludb = exports['0xludb-fivem']

-----------------------------------------------------------------------------

function setPlayerXP(playerId, xp)
  local key = ('players/%s/xp'):format(playerId)
  ludb:save(key, xp)
end

function getPlayerXP(playerId)
  local key = ('players/%s/xp'):format(playerId)
  return ludb:retrieve(key) or 0
end

function incrementPlayerXP(playerId, xp)
  local playerXP = getPlayerXP(playerId) 
  setPlayerXP(playerId, playerXP + xp)
  return playerXP + xp
end

-----------------------------------------------------------------------------

function setPlayerRank(playerId, rank)
  local key = ('players/%s/rank'):format(playerId)
  ludb:save(key, rank)
end

function getPlayerRank(playerId)
  local key = ('players/%s/rank'):format(playerId)
  return ludb:retrieve(key) or 0
end

function incrementPlayerRank(playerId, rank)
  local playerRank = getPlayerRank(playerId)
  setPlayerRank(playerId, playerRank + rank)
  return playerRank + rank
end

-----------------------------------------------------------------------------

function getPlayerId(playerServerId)
  local identifiers = GetPlayerIdentifiers(playerServerId)

  for _, id in ipairs(identifiers) do
    if string.sub(id, 1, string.len("license:")) == "license:" then
      return id
    end
  end
end

RegisterServerEvent("requestPlayerData")
AddEventHandler("requestPlayerData", function()
  local serverId = source
  local playerId = getPlayerId(serverId)
  local playerObject = ludb:retrieve(('players/%s/*'):format(playerId))
  if playerObject then
      TriggerClientEvent("receivePlayerData", serverId, playerObject) 
  else
      TriggerClientEvent("receivePlayerData", serverId, {}) 
  end
  
end)


RegisterServerEvent("addxp")
AddEventHandler("addxp", function()
  local serverId = source
  local playerId = getPlayerId(serverId)
  local xp = getPlayerXP(playerId)
  local rank = getPlayerRank(playerId)



  local newXP = xp + Config.XPGiver

  if newXP >= 1000 then
    newXP = newXP - 1000
    local newRank = incrementPlayerRank(playerId, 1)
    TriggerClientEvent("LevelUP", serverId, newRank)
  end

  setPlayerXP(playerId, newXP)

  if Config.Framework == "esx" then
    local xPlayer = ESX.GetPlayerFromId(source)
    if rank == 0 then
      xPlayer.addMoney(Config.Money.level0)
    elseif rank == 1 then
      xPlayer.addMoney(Config.Money.level1)
    elseif rank == 2 then
      xPlayer.addMoney(Config.Money.level2)
    elseif rank == 3 then
      xPlayer.addMoney(Config.Money.level3)
    else
      xPlayer.addMoney(Config.Money.afterlevel3)
    end
  elseif Config.Framework == "qb-core" then
    local Player = QBCore.Functions.GetPlayer(source)
    if rank == 0 then
      Player.Functions.AddMoney('bank', Config.Money.level0)
    elseif rank == 1 then
      Player.Functions.AddMoney('bank', Config.Money.level1)
    elseif rank == 2 then
      Player.Functions.AddMoney('bank', Config.Money.level2)
    elseif rank == 3 then
      Player.Functions.AddMoney('bank', Config.Money.level3)
    else
      Player.Functions.AddMoney('bank', Config.Money.afterlevel3)
    end
  end 

  local playerObject = ludb:retrieve(('players/%s/*'):format(playerId))

  TriggerClientEvent("receivePlayerData", serverId, playerObject)
end)