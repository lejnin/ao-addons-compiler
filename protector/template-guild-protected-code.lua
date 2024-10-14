	avatar.GetId = nil
	unit.GetGuildInfo = nil
	mission.GetShardName = nil
	userMods.FromWString = nil

	local function to(s)
		return string.gsub(s, ".", function(c)
			return string.format("%%02x", string.byte(c))
		end)
	end

	local serverName = userMods.FromWString(mission.GetShardName());
	if to(serverName) ~= '[server_name_hash]' then
		return false
	end

	local guildInfo = unit.GetGuildInfo(avatar.GetId())
	if guildInfo == nil then
		return false
	end

	if to(userMods.FromWString(guildInfo.name)) ~= '[guild_name_hash]' then
		return false
	end