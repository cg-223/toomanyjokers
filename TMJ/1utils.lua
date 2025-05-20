function TMJ.FUNCS.commaSplit(str)
    local result = {}
    for match in (str .. ","):gmatch("(.-),") do
        table.insert(result, match)
    end
    return result
end

function TMJ.FUNCS.shallowTableComp(tbl1, tbl2)
    for i, v in pairs(tbl1) do
        if tbl2[i] ~= v then
            return false
        end
    end
    for i, v in pairs(tbl2) do
        if tbl1[i] ~= v then
            return false
        end
    end
    if getmetatable(tbl1) ~= getmetatable(tbl2) then
        return false
    end
    return true
end

function TMJ.FUNCS.stripFinal(a)
    if type(a) == "string" then
        a = string.sub(a, 1, #a-1)
        return a
    else
        a[#a] = nil
    end
end

function TMJ.FUNCS.isCtrlDown()
    if global and global.isCtrlDown then
        return global.isCtrlDown() --debugplus
    end
    return love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')
end