-- 按选项过滤补充词库的候选。
-- 子词库在部署时已合并进同一张表，候选不携带来源信息，
-- 因此用词条与编码的组合精确定位特定子表的行。

local M = {}

local function read_table(path)
    local file = io.open(path, "r")
    if not file then return nil end
    -- 按编码分组：rows[code][text]，过滤时省去字符串拼接。
    local rows = {}
    local in_body = false
    for line in file:lines() do
        if in_body then
            local text, code = line:match("^([^\t]+)\t([^\t]+)")
            if text and code then
                local bucket = rows[code]
                if not bucket then
                    bucket = {}
                    rows[code] = bucket
                end
                bucket[text] = true
            end
        elseif line:match("^%.%.%.") then
            in_body = true
        end
    end
    file:close()
    return rows
end

local function load_table(relative_path)
    local path = rime_api.get_user_data_dir() .. "/" .. relative_path
    local rows = read_table(path)
    if not rows then
        log.warning("小鹤词库开关：找不到 " .. path)
    end
    return rows
end

-- 选项关闭时丢弃对应子表的候选；词库文件缺失时保持候选不变。
local options = {
    { name = "full_char", file = "flypy/flypy.full.char.dict.yaml" },
    { name = "secondary_short_code", file = "flypy/flypy.secondary.short.code.dict.yaml" },
}

function M.init(env)
    env.tables = {}
    for _, option in ipairs(options) do
        env.tables[option.name] = load_table(option.file)
    end
end

function M.func(translation, env)
    local ctx = env.engine.context
    local input = ctx.input
    -- 每次刷新只读一次选项，避免随候选数重复查询。
    local enabled = {}
    for _, option in ipairs(options) do
        enabled[option.name] = ctx:get_option(option.name)
    end
    for cand in translation:iter() do
        local suppressed = false
        for _, option in ipairs(options) do
            local rows = env.tables[option.name]
            local bucket = rows and rows[input]
            if bucket and not enabled[option.name] and bucket[cand.text] then
                suppressed = true
                break
            end
        end
        if not suppressed then yield(cand) end
    end
end

return M
