local main_funcs = {
    function(center)
        return center.name
    end,
    function(center)
        local badge = SMODS.Rarity:get_rarity_badge(center.set)
        if badge == "ERROR" then
            badge = nil
        end
        return "key:" .. (badge or center.set or "")
    end,
    function(center)
        local raritystring
        if type(center.rarity) == "string" or (type(center.rarity) == "number" and center.rarity < 5 and center.rarity == math.floor(center.rarity) and center.rarity > 0) then
            raritystring = SMODS.Rarity:get_rarity_badge(center.rarity)
        end
        if raritystring == "ERROR" or not raritystring then
            raritystring = tostring(center.rarity)
        end
        return "rarity:" .. raritystring
    end,
    function(center)
        return "set:" .. (center.set or "")
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
TMJ.INVALIDATE_CENTER_FUNCS = {
    function(center)
        return not center.set
    end,
    function(center)
        return not center.key
    end,
    function(center)
        return center.no_collection
    end,
    function(center)
        return TMJ.config.hide_undiscovered and not (center.discovered and center.unlocked)
    end
}

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
        local ret = v(center) or ""
        if type(ret) == "string" then ret = { ret } end
        for _, v in pairs(ret) do
            all[#all + 1] = lower_spaceless(v)
        end
    end
    TMJ.center_string_cache[center] = all
    return all
end

function TMJ.FUNCS.does_match(center, match_string)
    for i, v in pairs(TMJ.INVALIDATE_CENTER_FUNCS) do
        if v(center) then
            return false
        end
    end
    local strings = TMJ.FUNCS.get_center_strings(center)
    local all_match_strings = string.split(lower_spaceless(match_string), ",")
    local use_any, use_regex
    local remove = {}
    --extract magic terms
    for i, v in ipairs(all_match_strings) do
        if v == "{any}" then
            table.insert(remove, i)
            use_any = true
        elseif v == "{regex}" then
            table.insert(remove, i)
            use_regex = true
        end
    end
    --slow but whatever
    for _, v in pairs(remove) do
        table.remove(all_match_strings, v)
    end
    local any_flag = false
    local all_flag = true
    --do matching (any hingers)
    for _, mstr in pairs(all_match_strings) do
        local negate = false
        if string.sub(mstr, 1, 1) == "!" then
            mstr = mstr:sub(2)
            negate = true
        end
        local saw_any = negate
        for _, nstr in pairs(strings) do
            if string.find(nstr, mstr, nil, not use_regex) then
                if not negate then
                    any_flag = true
                    saw_any = true
                else
                    saw_any = false
                end
            end
        end
        if not saw_any then
            all_flag = false
        end
    end
    return (use_any and any_flag) or all_flag
end

--[[
Consists of key/value pairs of string/table, where the key is a match string. The table is an array of keys.
]]
TMJ.get_centers_caches = {
    centers_that_match = {},
    seen_to_order = {},
    inc_seen = {}
}
function TMJ.FUNCS.get_centers(match_string, num_ignored, num_wanted)
    if not TMJ.all_centers then
        TMJ.FUNCS.process_centers()
    end
    local results = {}
    local centers = TMJ.all_centers
    local num_seen = 0
    local centers_that_match = TMJ.get_centers_caches.centers_that_match[match_string] or {}
    TMJ.get_centers_caches.centers_that_match[match_string] = centers_that_match
    local seen_to_order = TMJ.get_centers_caches.seen_to_order[match_string] or {}
    TMJ.get_centers_caches.seen_to_order[match_string] = seen_to_order
    local attempt_start = seen_to_order[num_ignored] or 1
    if attempt_start ~= 1 then
        num_seen = num_ignored - 1
    end
    for i = attempt_start, #centers do
        if #results == num_wanted then
            break
        end
        local center = centers[i]
        if center then
            local matches = centers_that_match[center]
            if matches ~= nil then
                if matches then
                    num_seen = num_seen + 1
                    if num_seen > num_ignored then
                        table.insert(results, center.key)
                    end
                end
            else
                if TMJ.FUNCS.does_match(centers[i], match_string) then
                    num_seen = num_seen + 1
                    centers_that_match[center] = true
                    if i >= num_seen then
                        table.insert(results, center.key)
                    end
                else
                    centers_that_match[center] = false
                end
            end
        end
    end
    return results
end

---Mod makers: If your center cannot show up as a Card in TMJ, insert its pool name here. Joker is in here because it is added manually
function TMJ.FUNCS.add_blacklisted_pool(pool)
    TMJ.blacklisted_pools[pool] = true
end

TMJ.blacklisted_pools = table_into_hashset { "Joker", "Tag" }
---Mod makers: If your center cannot show up as a Card in TMJ, insert its set name here
function TMJ.FUNCS.add_blacklisted_pool(pool)
    TMJ.blacklisted_sets[pool] = true
end

TMJ.blacklisted_sets = table_into_hashset { "Stake", "Seal", "Back", "Sleeve" }
function TMJ.FUNCS.process_centers()
    TMJ.all_centers = {}
    local seen = {}
    --insert pinned things first
    for key, v in pairs(TMJ.config.pinned_keys) do
        if v then
            seen[key] = true
            table.insert(TMJ.all_centers, G.P_CENTERS[key])
        end
    end
    --insert jokers first to be at the top of the list
    for _, center in pairs(G.P_CENTER_POOLS.Joker) do
        if not TMJ.config.pinned_keys[center.key] and not seen[center.key] then
            seen[center.key] = true
            table.insert(TMJ.all_centers, center)
        end
    end
    for poolName, pool in pairs(G.P_CENTER_POOLS) do
        if not TMJ.blacklisted_pools[poolName] then
            for l, center in pairs(pool) do
                if not center.set or not TMJ.blacklisted_sets[center.set] then
                    if not TMJ.config.pinned_keys[center.key] and not seen[center.key] then
                        seen[center.key] = true
                        table.insert(TMJ.all_centers, center)
                    end
                end
            end
        end
    end
end
