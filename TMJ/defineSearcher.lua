function TMJ.FUNCS.filterCenters(prefilters, list) --Filter list using filters. filters must be a table of strings. list must be a table of centers (see G.P_CENTERS)
    local dontuseregex = true
    local filters, args = TMJ.FUNCS.processFilters(copy_table(prefilters))



    local matchedCenters = {}
    for i, center in pairs(list) do
        if (center.collectionInfo or {}).centerPoolName == "Stake" or center.set == "Seal" or center.set == "Back" or center.set == "Sleeve" or (center.collectionInfo or {}).centerPoolName == "Tag" then goto continue end
        local matchAgainst = {} --all strings in this table will be matched against all filters in {filters}


        local ourkey = ""
        for key, v in pairs(G.P_CENTERS) do
            --our lists wont include keys so we need to fetch them ourselves
            if v == center then
                --we've found the right center
                ourkey = key
            end
        end
        center.collectionInfo.key = ourkey
        if center.name then
            local sub = string.gsub(string.lower(center.name), " ", "")
            table.insert(matchAgainst, sub) --match against the centers name
        end

        local sub = string.gsub(string.lower(ourkey), " ", "")
        table.insert(matchAgainst, sub) --match against the key

        if center.mod then
            local modname = center.mod.name or ""
            modname = string.lower(modname)
            modname = string.gsub(modname, " ", "")
            table.insert(matchAgainst, modname) --match against the name of the mod that implemented this center
        else
            table.insert(matchAgainst, "vanilla")
        end

        if center.set then
            local setname = center.set
            setname = string.lower(setname)
            setname = string.gsub(setname, " ", "")
            table.insert(matchAgainst, setname)
        end

        if center.collectionInfo and center.collectionInfo.centerPoolName then --custom
            local poolname = center.collectionInfo.centerPoolName
            poolname = string.lower(poolname)
            poolname = string.gsub(poolname, " ", "")
            table.insert(matchAgainst, poolname .. "s") --often these pools are named things like "joker", so if you search "jokers" it wouldnt pick up on this one
        end

        if center.rarity then
            local raritystring = ""
            if not SMODS.Rarity then --backwards compat
                --this only supports a handful of mods, its fine though!
                if type(center.rarity) == "string" then
                    if center.rarity == "cry_exotic" then
                        raritystring = "Exotic"
                    elseif center.rarity == "cry_epic" then
                        raritystring = "Epic"
                    else
                        raritystring = center.rarity
                    end
                elseif center.rarity == 1 then
                    raritystring = "Common"
                elseif center.rarity == 2 then
                    raritystring = "Uncommon"
                elseif center.rarity == 3 then
                    raritystring = "Rare"
                elseif center.rarity == 4 then
                    raritystring = "Legendary"
                else
                    raritystring = tostring(center.rarity)
                end
                raritystring = string.lower(raritystring)
                raritystring = string.gsub(raritystring, " ", "")
                table.insert(matchAgainst, raritystring)
            else
                if type(center.rarity) == "string" or (type(center.rarity) == "number" and center.rarity < 5) then
                    raritystring = SMODS.Rarity:get_rarity_badge(center.rarity)
                end
                if raritystring == "ERROR" or not raritystring then
                    raritystring = tostring(center.rarity)
                end
                raritystring = string.lower(raritystring)
                raritystring = string.gsub(raritystring, " ", "")
                table.insert(matchAgainst, raritystring)
            end

            
        end

        for _, loclist in pairs(G.localization.descriptions) do
            if loclist[ourkey] then --G.localization.descriptions contains tables for tarots, tags, jokers, etc, this function covers all types of centers so we can iterate through
                --i originally intended this to be usable for all cards, but in the end I decided to keep it to just jokers
                local ourDescription = loclist[ourkey]
                table.insert(matchAgainst, ourDescription.name) --this is localized name
                local descText = ourDescription.text            --description
                local lineConcat = ""
                for _, descLine in ipairs(descText) do
                    local processedLine = descLine
                    processedLine = string.gsub(processedLine, "{[^}]+}", "") --remove any formatting tags, e.g. {C:legendary}
                    processedLine = string.gsub(processedLine, "#[^#]+#", "") --remove locvar tags, e.g. #1#
                    processedLine = string.gsub(processedLine, "{}", "")      --remove ending formatting tags, e.g. {}
                    processedLine = string.gsub(processedLine, " ", "")
                    processedLine = string.lower(processedLine)
                    --EXAMPLE: "{X:dark_edition,C:white}^#1#{} Mult only after"
                    -->> "^#1#{} Mult only after"
                    -->> "^{} Mult only after"
                    -->> "^ Mult only after"
                    -->> "^Multonlyafter"
                    -->>"^multonlyafter"
                    lineConcat = lineConcat .. processedLine
                end
                table.insert(matchAgainst, lineConcat) --this is a concatenation of every line in the description, with all formatting removed.
            end
        end

        for iiii, vvvv in pairs(filters) do
            vvvv = string.gsub(vvvv, " ", "")
            vvvv = string.lower(vvvv)
        end
        for iiii, vvvv in pairs(matchAgainst) do
            vvvv = string.gsub(vvvv, " ", "")
            vvvv = string.lower(vvvv)
        end --lower all our filters, and remove sapces
        --main loop
        local mastermatcher = ""
        for iaasdf, vcascsaz in pairs(matchAgainst) do --cant do this no more
            mastermatcher = mastermatcher .. vcascsaz  --combine all of our matchers (description, name, mod, etc)
        end
        local flag = false
        local flag2 = false
        for _, filter in pairs(filters) do
            if string.sub(filter, 1, 1) ~= "!" then
                if not string.find(mastermatcher, filter, 1, not args.regex) then --is filter contained in matcher, starting at the first character, using a raw text search as to ignore characters like ^?
                    flag = true
                else
                    flag2 = true
                end
            else
                if string.find(mastermatcher, string.sub(filter, 2), 1, not args.regex) then
                    flag = true
                else
                    flag2 = true
                end
            end
        end
        if not flag or (args.any and flag2) then
            table.insert(matchedCenters, center)
        end
        ::continue::
    end
    local seen = {}
    local indicesToRemove = {}
    local center = G.P_CENTERS[args.key or ""]
    for i, v in ipairs(matchedCenters) do
        if seen[v.collectionInfo.key] then --this code is redundant; we combine all our matchers so we cant get duplicates anymore. im keeping it here just in case
            --this code isnt redundant anymore
            table.insert(indicesToRemove, i - #indicesToRemove)
        elseif args.mod and center and (v.mod ~= center.mod) then
            table.insert(indicesToRemove, i-#indicesToRemove)
        elseif args.rarity and center and (v.rarity ~= center.rarity) then
            table.insert(indicesToRemove, i-#indicesToRemove)
        end
        seen[v.collectionInfo.key] = true
    end
    for i, v in ipairs(indicesToRemove) do
        table.remove(matchedCenters, v)
    end



    return matchedCenters
end

function TMJ.FUNCS.getPCenterPoolsSorted(...) --Iterates through G.P_CENTER_POOLS, returns a table similar to G.P_CENTERS but with keys replaced with number indices. Any number of arguments can be supplied, these dictate which pools go first.
    local centerTable = {}
    local seenPools = {}
    for i, poolName in pairs({ ... }) do
        for l, center in pairs(G.P_CENTER_POOLS[poolName] or { print("Invalid argument to getPCenterPoolsSorted. Invalid argument: " .. poolName) }) do --not a serious error so just print
            table.insert(centerTable, center)
        end
        seenPools[poolName] = true
    end

    for poolName, pool in pairs(G.P_CENTER_POOLS) do --second loop so that unspecified pools are added last
        if not seenPools[pool] then
            for l, center in pairs(pool) do
                center.collectionInfo = {
                    centerPoolName = poolName or ""
                }
                table.insert(centerTable, center)
            end
        end
    end

    return centerTable
end

function TMJ.FUNCS.processFilters(filters)
    local args = {}
    while true and filters[1] do
        local curfilter = filters[1]
        local filterlen = string.len(curfilter)
        if string.sub(curfilter, 1, 1) ~= "{" or string.sub(curfilter, filterlen) ~= "}" then
            break
        else
            table.remove(filters, 1)
            args.regex = args.regex or (curfilter == "{regex}")
            args.any = args.any or (curfilter == "{any}")
            if string.sub(curfilter, 1, 5) == "{key=" then
                print(curfilter)
                local key, mode = unpack(TMJ.FUNCS.commaSplit( string.sub(curfilter, 6, #curfilter-1) ))
                print(key)
                print(mode)
                if not (key and mode) then return filters, args end
                args.key = key
                if mode == "name" then
                    args.name = true
                elseif mode == "rarity" then
                    args.rarity = true
                elseif mode == "mod" then
                    args.mod = true
                end
            end
        end
    end
    return filters, args
end



function TMJ.FUNCS.cacheSearchIntermediary(...)
    local argspacked = {...}
    for i, v in pairs(TMJ.SEARCHERCACHE) do
        if TMJ.FUNCS.shallowTableComp(v, argspacked) then
            return v
        end
    end
    TMJ.SEARCHERCACHE[argspacked] = TMJ.FUNCS.filterCenters(...)
    return TMJ.SEARCHERCACHE[argspacked]
end

function TMJ.FUNCS.cacheSorterIntermediary(...)
    local argspacked = {...}
    for i, v in pairs(TMJ.SORTERCACHE) do
        if TMJ.FUNCS.shallowTableComp(v, argspacked) then
            return v
        end
    end
    TMJ.SORTERCACHE[argspacked] = TMJ.FUNCS.getPCenterPoolsSorted(...)
    return TMJ.SORTERCACHE[argspacked]
end