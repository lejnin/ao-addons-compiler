local function parse_datetime(datetime_str)
    local result = {
        y = 0, m = 0, d = 0,
        h = 0, min = 0, s = 0
    }
    
    local date_pattern = "(%d+)%-(%d+)%-(%d+)"
    local time_pattern = "(%d+)%:(%d+)%:?(%d*)"

    local y, m, d = datetime_str:match(date_pattern)
    if not (y and m and d) then
        return nil
    end
    
    result.y = tonumber(y)
    result.m = tonumber(m)
    result.d = tonumber(d)

    if result.m < 1 or result.m > 12 or result.d < 1 or result.d > 31 then
        return nil
    end

    -- Парсим время, если оно есть
    local time_str = datetime_str:match("%d+%:%d+%:?.*")
    if time_str then
        local h, min, s = time_str:match(time_pattern)
        result.h = tonumber(h)
        result.min = tonumber(min)
        result.s = tonumber(s) or 0  -- Если секунд нет, записываем 0

        if result.h < 0 or result.h > 23 or result.min < 0 or result.min > 59 or result.s < 0 or result.s > 59 then
            return nil
        end
    end

    return result
end

local function to(s)
    return string.gsub(s, ".", function(c)
        return string.format("%02x", string.byte(c))
    end)
end

local function parse_args(args)
    local options = {}
    for i = 2, #args do
        local arg = args[i]
        if arg:sub(1, 2) == "--" then
            local option, value = arg:match("^%-%-(%w+)=?(.*)")
            if option then
                options[option] = value ~= "" and value or true
            end
        end
    end
	
    return options
end

local function is_arg_with_value(arg)
    return arg ~= nil and arg ~= true
end

local function get_file_content(filepath)
	local file = io.open(filepath, "rb")
	local content = file:read("*a")
	file:close()

	return content
end

local function put_file_content(filepath, content)
	local file = io.open(filepath, "wb")
	file:write(content)
	file:close()

	return content
end

local function getPath(str)
    return str:match("(.*\\)")
end

local currentPath = getPath(arg[0])
local fileToProtect = arg[1]
local options = parse_args(arg)

local protectedCodeTemplate = get_file_content(currentPath .. 'template-protected-code.lua')
protectedCodeTemplate = protectedCodeTemplate:gsub('%[original_script_code%]', get_file_content(fileToProtect))

local checkings = ''

if is_arg_with_value(options['guild']) and is_arg_with_value(options['server']) then
    print("Привязываем к гильдии " .. options['guild'] .. ", сервер " .. options['server'])
	local guildCheckingTemplate = get_file_content(currentPath .. 'template-guild-protected-code.lua')
	guildCheckingTemplate = guildCheckingTemplate:gsub('%[server_name_hash%]', to(options['server']))
	guildCheckingTemplate = guildCheckingTemplate:gsub('%[guild_name_hash%]', to(options['guild']))
	
	checkings = checkings .. guildCheckingTemplate .. "\n"
end

if is_arg_with_value(options['until']) then
	local parsedInputDatetime = parse_datetime(options['until'])
	if not parsedInputDatetime then
		print("НЕВАЛИДНОЕ ЗНАЧЕНИЕ ДАТЫ/ВРЕМЕНИ! ОГРАНИЧЕНИЕ ВРЕМЕНИ ДЕЙСТВИЯ ПО ВРЕМЕНИ НЕ УСТАНОВЛЕНО!")
	else
		print("Время окончания работы аддона " .. options['until'])
		local timeCheckingTemplate = get_file_content(currentPath .. 'template-time-protected-code.lua')
		timeCheckingTemplate = timeCheckingTemplate:gsub('%[available_until_y%]', parsedInputDatetime.y)
		timeCheckingTemplate = timeCheckingTemplate:gsub('%[available_until_m%]', parsedInputDatetime.m)
		timeCheckingTemplate = timeCheckingTemplate:gsub('%[available_until_d%]', parsedInputDatetime.d)
		timeCheckingTemplate = timeCheckingTemplate:gsub('%[available_until_h%]', parsedInputDatetime.h)
		timeCheckingTemplate = timeCheckingTemplate:gsub('%[available_until_min%]', parsedInputDatetime.min)
		timeCheckingTemplate = timeCheckingTemplate:gsub('%[available_until_s%]', parsedInputDatetime.s)
		
		checkings = checkings .. timeCheckingTemplate .. "\n"
	end
end

protectedCodeTemplate = protectedCodeTemplate:gsub('%[checking_code%]', checkings)
put_file_content(fileToProtect, protectedCodeTemplate)
