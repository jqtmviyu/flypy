local function flypy_fast_translator(input, seg)
    if (input == ";b") then
        --- Candidate(type, start, end, text, comment)
        yield(Candidate("table", seg.start, seg._end, "\t", ""))
    end
end

return flypy_fast_translator