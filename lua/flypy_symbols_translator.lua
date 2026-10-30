local categories = {
    ["ofb"] = {
        { target = "ofbd", label = "d 标点 、，。" },
    },
    ["ofp"] = {
        { target = "ofpp", label = "p 偏旁 亻彳讠" },
        { target = "ofpy", label = "y 拼音 āōē" },
    },
    ["ofd"] = {
        { target = "ofdw", label = "w 单位 ㎎㎏㎜" },
        { target = "ofdu", label = "u 点号数字 ⒈⒉⒊" },
    },
    ["ofj"] = {
        { target = "ofjt", label = "t 箭头 ←→↑" },
    },
    ["ofy"] = {
        { target = "ofyu", label = "u 圆圈数字 ①②③" },
    },
    ["ofk"] = {
        { target = "ofku", label = "u 括号数字 ⑴⑵⑶" },
    },
    ["ofv"] = {
        { target = "ofvu", label = "u 中文数字 ㈠㈡㈢" },
        { target = "ofvb", label = "b 制表符号 ┌└┐" },
        { target = "ofvy", label = "y 注音符号 ㄅㄆㄇ" },
    },
    ["ofl"] = {
        { target = "ofld", label = "d 罗马大写 ⅠⅡⅢ" },
        { target = "oflx", label = "x 罗马小写 ⅰⅱⅲ" },
    },
    ["ofu"] = {
        { target = "ofub", label = "b 上标 ¹²³" },
        { target = "ofux", label = "x 数学符号 ＋－＜" },
    },
    ["ofx"] = {
        { target = "ofxb", label = "b 下标 ₁₂₃" },
        { target = "ofxd", label = "d 希腊大写 ΑΒΓ" },
        { target = "ofxx", label = "x 希腊小写 αβγ" },
    },
    ["oft"] = {
        { target = "oftu", label = "u 特殊符号 ℃°‰" },
    },
    ["ofh"] = {
        { target = "ofhb", label = "b 货币符号 €＄￠" },
    },
    ["ofe"] = {
        { target = "ofed", label = "d 俄文大写 АБВ" },
        { target = "ofex", label = "x 俄文小写 абв" },
    },
    ["ofr"] = {
        { target = "ofrd", label = "d 日文大写 ァアィ" },
        { target = "ofrx", label = "x 日文小写 ぁあぃ" },
    },
    ["of"] = {
        { target = "ofbd", label = "bd 标点 、，。" },
        { target = "ofpp", label = "pp 偏旁 亻彳讠" },
        { target = "ofdw", label = "dw 单位 ㎎㎏㎜" },
        { target = "ofpy", label = "py 拼音 āōē" },
        { target = "ofjt", label = "jt 箭头 ←→↑" },
        { target = "ofyu", label = "yu 圆圈数字 ①②③" },
        { target = "ofku", label = "ku 括号数字 ⑴⑵⑶" },
        { target = "ofdu", label = "du 点号数字 ⒈⒉⒊" },
        { target = "ofvu", label = "vu 中文数字 ㈠㈡㈢" },
        { target = "ofld", label = "ld 罗马大写 ⅠⅡⅢ" },
        { target = "oflx", label = "lx 罗马小写 ⅰⅱⅲ" },
        { target = "ofub", label = "ub 上标 ¹²³" },
        { target = "ofxb", label = "xb 下标 ₁₂₃" },
        { target = "oftu", label = "tu 特殊符号 ℃°‰" },
        { target = "ofux", label = "ux 数学符号 ＋－＜" },
        { target = "ofhb", label = "hb 货币符号 €＄￠" },
        { target = "ofvb", label = "vb 制表符号 ┌└┐" },
        { target = "ofvy", label = "vy 注音符号 ㄅㄆㄇ" },
        { target = "ofxd", label = "xd 希腊大写 ΑΒΓ" },
        { target = "ofxx", label = "xx 希腊小写 αβγ" },
        { target = "ofed", label = "ed 俄文大写 АБВ" },
        { target = "ofex", label = "ex 俄文小写 абв" },
        { target = "ofrd", label = "rd 日文大写 ァアィ" },
        { target = "ofrx", label = "rx 日文小写 ぁあぃ" },
    },
}

local M = {}

function M.init(env)
    local ctx = env.engine.context
    env.commit_connection = ctx.commit_notifier:connect(function(context)
        local candidate = context:get_selected_candidate()
        if candidate then
            env.target = candidate:get_genuine().type:match("^flypy_symbols_(.+)$")
        end
    end)
    -- 等本次提交清空输入后再进入分类，避免新编码被提交过程清除。
    env.update_connection = ctx.update_notifier:connect(function(context)
        if env.target and context.input == "" then
            local target = env.target
            env.target = nil
            context:push_input(target)
        end
    end)
end

function M.func(input, seg)
    for _, category in ipairs(categories[input] or {}) do
        yield(Candidate("flypy_symbols_" .. category.target,
            seg.start, seg._end, "", category.label))
    end
end

function M.fini(env)
    env.commit_connection:disconnect()
    env.update_connection:disconnect()
end

return M
