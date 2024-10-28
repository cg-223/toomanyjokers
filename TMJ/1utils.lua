function TMJ.FUNCS.commaSplit(str)
    local result = {}
    for match in (str .. ","):gmatch("(.-),") do
        table.insert(result, match)
    end
    return result
end

