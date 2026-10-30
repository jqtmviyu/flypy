local actions = {
    oss = { label = "必应搜索", url = "https://www.bing.com/search?q=", search = true },
    orm = { label = "打开使用入门", path = "flypy_help.chm" },
    oav = { label = "打开 Rime 配置目录", path = "" },
    ovy = { label = "切换中英标点", option = "ascii_punct" },
    oqb = { label = "切换全半角", option = "full_shape" },
    ojf = { label = "切换简繁", option = "simplification" },
    xhgw = { label = "打开小鹤官网", url = "https://flypy.cc" },
    xhwp = { label = "打开小鹤网盘", url = "https://flypy.ysepan.com" },
    xhrm = { label = "打开小鹤入门", url = "https://flypy.cc/help/#/" },
}

local function base64(text)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = {}
    for index = 1, #text, 3 do
        local a, b, c = text:byte(index, index + 2)
        local value = a * 65536 + (b or 0) * 256 + (c or 0)
        for shift = 3, 0, -1 do
            local digit = math.floor(value / 64 ^ shift) % 64 + 1
            result[#result + 1] = alphabet:sub(digit, digit)
        end
        if not c then result[#result] = "=" end
        if not b then result[#result - 1] = "=" end
    end
    return table.concat(result)
end

local function open_command(target)
    -- 配置路径可能含空格或单引号，按系统 shell 规则引用整个目标。
    if package.config:sub(1, 1) == "\\" then
        -- 用 ASCII 传递 UTF-8 目标，避开 cmd 对百分号和中文路径的解释。
        return 'powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -Command "'
            .. "$target = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('"
            .. base64(target) .. "')); Start-Process -FilePath $target\""
    end
    local quoted = "'" .. target:gsub("'", "'\\''") .. "'"
    if jit and jit.os == "Linux" then
        return "xdg-open " .. quoted .. " >/dev/null 2>&1 &"
    end
    return "if [ -x /usr/bin/open ]; then /usr/bin/open " .. quoted
        .. "; else xdg-open " .. quoted .. "; fi >/dev/null 2>&1 &"
end

local function flypy_date_translator(input, seg)
    if (input == "orq") then
        --- Candidate(type, start, end, text, comment)
        local now = os.time()
        local date = os.date("*t", now)
        yield(Candidate("date", seg.start, seg._end,
            string.format("%d年%d月%d日", date.year, date.month, date.day), ""))
        yield(Candidate("date", seg.start, seg._end, os.date("%Y-%m-%d"), " "))
    end
end


local function flypy_time_translator(input, seg)
    if input ~= "ouj" then return end
    local now = os.time()
    local date = os.date("*t", now)
    local weekdays = { "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六" }
    local minute = os.date("%M", now)
    local texts = {
        string.format("%d:%s %s", date.hour, minute, weekdays[date.wday]),
        string.format("%d点%s分", date.hour, minute),
        tostring(now),
    }
    -- 用同一时刻生成三个候选，按原版格式、时间戳的顺序展示。
    for index, text in ipairs(texts) do
        local candidate = Candidate(index == 3 and "datetime" or "time",
            seg.start, seg._end, text, "")
        candidate.quality = 4 - index
        yield(candidate)
    end
end


local M = {}

local function search_text(ctx)
    for _, record in ctx.commit_history:iter() do
        if record.text ~= "" and not record.type:match("^flypy_direct_") then
            return record.text
        end
    end
end

local function url_encode(text)
    return (text:gsub("([^A-Za-z0-9%-._~])", function(char)
        return string.format("%%%02X", string.byte(char))
    end))
end

local function clipboard_text()
    local command
    if package.config:sub(1, 1) == "\\" then
        command = 'powershell.exe -NoProfile -NonInteractive -Command '
            .. '"[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); '
            .. '[Console]::Write((Get-Clipboard -Raw))"'
    else
        -- GUI 输入法可能使用 C locale，pbpaste 必须显式指定 UTF-8 才能读到汉字。
        command = "if [ -x /usr/bin/pbpaste ]; then LC_ALL=en_US.UTF-8 /usr/bin/pbpaste -Prefer txt; "
            .. "elif command -v wl-paste >/dev/null 2>&1; then wl-paste --no-newline; "
            .. "else xclip -selection clipboard -o; fi 2>/dev/null"
    end
    local opened, pipe = pcall(io.popen, command, "r")
    if not opened or not pipe then return end
    local read, text = pcall(pipe.read, pipe, "*a")
    local closed, ok = pcall(pipe.close, pipe)
    if read and closed and ok and text and text ~= "" then
        if utf8.len(text) then return text end
        log.warning("小鹤反查：剪贴板未返回有效的 UTF-8 文本")
    end
end

local function clipboard_lookup(seg, env)
    local text = clipboard_text()
    if not text then return end
    -- 使用部署后的反查库；重新部署 flypydz 后会同步源词典中的编码。
    env.reverse_db = env.reverse_db or ReverseDb("build/flypydz.reverse.bin")
    local function emit(word)
        local codes = env.reverse_db:lookup(word)
        yield(Candidate("flypy_clipboard_lookup", seg.start, seg._end,
            word, codes ~= "" and codes or "未收录"))
    end
    if env.reverse_db:lookup(text) ~= "" then
        emit(text)
        return
    end
    local seen = {}
    for _, codepoint in utf8.codes(text) do
        local word = utf8.char(codepoint)
        if not seen[word] and not word:match("%s") then
            seen[word] = true
            emit(word)
        end
    end
end

function M.init(env)
    -- 动作在确认候选时执行；刷新候选和取消输入都不会触发。
    env.connection = env.engine.context.commit_notifier:connect(function(ctx)
        local candidate = ctx:get_selected_candidate()
        if not candidate then return end
        candidate = candidate:get_genuine()
        local code = candidate.type:match("^flypy_direct_(.+)$")
        local action = actions[code]
        if not action then return end
        if action.option then
            ctx:set_option(action.option, not ctx:get_option(action.option))
        else
            local target = action.url
            if action.search then
                -- 使用展示候选时保存的文本，避免确认动作覆盖提交历史。
                if not env.search_query then return end
                target = target .. url_encode(env.search_query)
            end
            if action.path then
                target = rime_api.get_user_data_dir()
                if action.path ~= "" then
                    target = target .. "/" .. action.path
                end
            end
            local ok, _, status = os.execute(open_command(target))
            if ok == nil or ok == false or (type(ok) == "number" and ok ~= 0) then
                log.error("小鹤直通无法打开：" .. target .. " (" .. tostring(status) .. ")")
            end
        end
    end)
end

function M.func(input, seg, env)
    if input == "orq" then
        return flypy_date_translator(input, seg)
    elseif input == "ouj" then
        return flypy_time_translator(input, seg)
    elseif input == "ofi" then
        return clipboard_lookup(seg, env)
    end
    local action = actions[input]
    if not action then return end
    local label = action.label
    if action.search then
        env.search_query = search_text(env.engine.context)
        if not env.search_query then return end
        label = label .. "：" .. env.search_query
    end
    -- 动作候选只显示说明，确认时向应用提交空文本。
    local candidate = Candidate("flypy_direct_" .. input, seg.start, seg._end, "", label)
    candidate.quality = 10
    yield(candidate)
end

function M.fini(env)
    env.connection:disconnect()
end

return M
