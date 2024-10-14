local function IsPossibleToUse()
[checking_code]
    return true
end

local function Run()
    if IsPossibleToUse() then
        (function()
[original_script_code]
        end)()
    end
end

(function()
    if avatar and avatar.IsExist() then
        Run()
    else
        common.RegisterEventHandler(Run, "EVENT_AVATAR_CREATED")
    end
end)()
