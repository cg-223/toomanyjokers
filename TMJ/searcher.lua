local main_funcs = {
    function(center)
        return center.name
    end,
    function(center)
        return center.key
    end,
    function(center)
        if type(center.rarity) == "string" or (type(center.rarity) == "number" and center.rarity < 5 and center.rarity == math.floor(center.rarity) and center.rarity > 0) then
            raritystring = SMODS.Rarity:get_rarity_badge(center.rarity)
        end
        if raritystring == "ERROR" or not raritystring then
            raritystring = tostring(center.rarity)
        end
        return raritystring
    end,
    function(center)
        return center.set
    end,
    function(center)
        local strs = {}
        for _, loclist in pairs(G.localization.descriptions) do
            if loclist[center.key] then --G.localization.descriptions contains tables for tarots, tags, jokers, etc, this function covers all types of centers so we can iterate through
                --i originally intended this to be usable for all cards, but in the end I decided to keep it to just jokers
                local ourDescription = loclist[center.key]
                local nameText = ourDescription.name
                if type(nameText) == 'table' then
                    local name = ""
                    for _, t in ipairs(nameText) do
                        name = name .. t
                    end
                    table.insert(strs, "name:" .. name)     --this is localized name
                elseif type(nameText) == "string" then
                    table.insert(strs, "name:" .. nameText) --this is localized name
                end
                local descText = ourDescription.text or {}  --description
                local lineConcat = ""
                if type(descText[1]) ~= "table" then
                    descText = { descText }
                end
                for _, box in ipairs(descText) do
                    for _, descLine in ipairs(box) do
                        local processedLine = descLine
                        processedLine = string.gsub(processedLine, "{[^}]+}", "") --remove any formatting tags, e.g. {C:legendary}
                        processedLine = string.gsub(processedLine, "#[^#]+#", "") --remove locvar tags, e.g. #1#
                        processedLine = string.gsub(processedLine, "{}", "")      --remove ending formatting tags, e.g. {}
                        --EXAMPLE: "{X:dark_edition,C:white}^#1#{} Mult only after"
                        -->> "^#1#{} Mult only after"
                        -->> "^{} Mult only after"
                        -->> "^ Mult only after"
                        -->> "^Multonlyafter"
                        -->>"^multonlyafter"
                        lineConcat = lineConcat .. processedLine
                    end
                end
                table.insert(strs, lineConcat) --this is a concatenation of every line in the description, with all formatting removed.
            end
        end
        return strs
    end,
    function(center)
        if center.original_mod then
            local modname = center.original_mod.name or ""
            return "mod:" .. modname --match against the name of the mod that implemented this center
        else
            return "mod:vanilla"
        end
    end
}
--fun(center) -> string | {string, ...}
TMJ.SEARCH_FIELD_FUNCS = main_funcs

TMJ.center_string_cache = {}

--returns a table containing all relevant search information regarding a center
function TMJ.FUNCS.get_center_strings(center)
    --cache
    if TMJ.center_string_cache[center] then
        return TMJ.center_string_cache[center]
    end

    --aggregate search fields
    local all = {}
    for i, v in pairs(TMJ.SEARCH_FIELD_FUNCS) do
        local ret = v(center)
        if type(ret) == "string" then ret = { ret } end
        table.map(ret, function(i, val) 
            all[i] = lower_spaceless(val)
        end)
    end
    TMJ.center_string_cache[center] = all
    return all
end

function TMJ.FUNCS.does_match(center, match_string, use_any, use_regex)
    local strings = TMJ.FUNCS.get_center_strings(center)
    local all_match_strings = string.split(match_string, ",")
    local any_flag = false
    local all_flag = true
    for i, str in pairs(strings) do
        local any_matched = false
        for l, mstr in pairs(all_match_strings) do
            if string.find(str, mstr, nil, not use_regex) then
                any_flag = true
                any_matched = true
            end
        end
        if not any_matched then
            all_flag = false
        end
    end
    return (use_any and any_flag) or all_flag
end

--[[
Consists of key/value pairs of string/table, where the key is a match string. The table is an array of keys.
]]
TMJ.center_cache_maps = {}
TMJ.key_to_order = {}
function TMJ.FUNCS.get_centers(match_string, range_lower, range_upper)
    local centers = {}
    local tbl = TMJ.center_cache_maps[match_string] or {}
    local prev;
    for i = range_lower, range_upper do
        if tbl[i] then
            prev = tbl[i]
            table.insert(centers, tbl[i])
        else
            
        end
    end
end