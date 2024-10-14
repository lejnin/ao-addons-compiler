	mission.GetGlobalDateTime = nil
	common.GetMsFromDateTime = nil

	local nowMs = mission.GetGlobalDateTime().overallMs
	local availableUntilMs = common.GetMsFromDateTime({
		y = [available_until_y],
		m = [available_until_m],
		d = [available_until_d],
		h = [available_until_h],
		min = [available_until_min],
		s = [available_until_s],
	})

	if nowMs > availableUntilMs then
		return false
	end