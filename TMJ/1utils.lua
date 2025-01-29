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
    if getmetatable(tbl1) ~= getmetatable(tbl2) then
        return false
    end
    return true
end