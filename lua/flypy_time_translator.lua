local function flypy_time_translator(input, seg)
    if (input == "ouj") then
        -- 输出时间格式
        local time_cand = Candidate("time", seg.start, seg._end, os.date("%H:%M"), "")
        time_cand.quality = 2
        yield(time_cand)

        -- 输出完整时间戳格式（手动处理时区格式）
        local now = os.time()
        local date_part = os.date("%Y-%m-%dT%H:%M:%S", now)
        local tz_offset = os.date("%z", now)
        local formatted_tz = tz_offset:gsub("([%+%-]%d%d)(%d%d)$", "%1:%2")
        local datetime_str = date_part .. formatted_tz

        local datetime_cand = Candidate("datetime", seg.start, seg._end, datetime_str, " ")
        datetime_cand.quality = 1
        yield(datetime_cand)
    end
end

return flypy_time_translator