--- STEAMODDED HEADER
--- MOD_NAME: Too Many Jokers
--- MOD_ID: toomanyjokers
--- MOD_AUTHOR: [cg]
--- PREFIX: tmj
--- MOD_DESCRIPTION: Adds a filtering system to the Joker collection.
--- PRIORITY: -1000000


local nfs = require("nativefs")



---@param filters table
---@param list table
local function filterCenters(filters, list) --Filter list using filters. filters must be a table of strings. list must be a table of centers (see G.P_CENTERS)
    local matchedCenters = {}
    for i, center in pairs(list) do
        if (center.collectionInfo or {}).centerPoolName == "Stake" or center.set == "Seal" or (center.collectionInfo or {}).centerPoolName == "Tag" then goto continue end
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
            end
            raritystring = string.lower(raritystring)
            raritystring = string.gsub(raritystring, " ", "")
            table.insert(matchAgainst, raritystring)
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
        for _, filter in pairs(filters) do
            if not string.find(mastermatcher, filter, 1, true) then --is filter contained in matcher, starting at the first character, using a raw text search as to ignore characters like ^?
                flag = true
            end
        end
        if not flag then
            table.insert(matchedCenters, center)
        end
        ::continue::
    end
    local seen = {}
    local indicesToRemove = {}
    for i, v in ipairs(matchedCenters) do
        if seen[v.collectionInfo.key] then --this code is redundant; we combine all our matchers so we cant get duplicates anymore. im keeping it here just in case
            --this code isnt redundant anymore
            table.insert(indicesToRemove, i - #indicesToRemove)
        end
        seen[v.collectionInfo.key] = true
    end
    for i, v in ipairs(indicesToRemove) do
        table.remove(matchedCenters, v)
    end



    return matchedCenters
end

local function getPCenterPoolsSorted(...) --Iterates through G.P_CENTER_POOLS, returns a table similar to G.P_CENTERS but with keys replaced with number indices. Any number of arguments can be supplied, these dictate which pools go first.
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





local function filterListFromString(str)
    str = string.gsub(str, " ", "")
    str = string.lower(str)
    str = string.split(str) --remove spaces from filter and separate via commas for compat with above functions
    return str
end

function G.FUNCS.reloadCollection()     --what it says on the tin, except this is for the TMJ collection
    _G.thegreatfilter = filterListFromString(G.ENTERED_FILTER or "")
    G.FUNCS.tmjcollection("fromScript") --so that thegreatfilter is reset
end

function string.split(input) --TERRIBLE practice i just needed a splitting function and i decided to implement it in string
                             --if an actual string.split is ever implemented by another mod with an earlier priority than TMJ this will override it and break that mod
    local result = {}
    for match in (input .. ","):gmatch("(.-),") do --split up the string by its commas
        table.insert(result, match)
    end
    return result
end 

SMODS.Keybind({
    key = "openTMJ",
    key_pressed = "t",
    action = function(controller)
        G.FUNCS.tmjcollection()
    end
})


function G.FUNCS.tmjcollection(e)
    if e ~= "fromScript" then
        thegreatfilter = { "" } --we dont want the filter resetting unless we want it to
    end

    G.SETTINGS.paused = true --generic things for an overlay
    G.FUNCS.overlay_menu {
        definition = Create_UIBox_TMJCollection(),
    }
    G.OVERLAY_MENU:recalculate() --necessary, ui doesnt load until you click the textbox otherwise
end

function Create_UIBox_TMJCollection()
    nfs.write(SMODS.Mods.toomanyjokers.path .. "config.txt",
        (tostring(CGNUMROWS) or "3") .. "," .. (tostring(CGNUMCOLUMNS) or "5") .. "," .. (tostring(CGSIZEDIVISOR) or "1"))
    --save any config changes
    G.ENTERED_FILTER = ""  --change filter textbox back to blank when we load/reload the page
    G.your_collection = {} --contains our cardareas
    local rows = tonumber(CGNUMROWS) or 3
    local columns = tonumber(CGNUMCOLUMNS) or 5
    local sizeDivisor = tonumber(CGSIZEDIVISOR) or 1
    --error avoidance mainly, these should never be anything except strings containing numbers

    local deck_tables = {}
    for j = 1, rows do                                                                        --row loop
        G.your_collection[j] = CardArea(                                                      --insert this cardarea into the table we feed to our ui
            G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,                                    --position
            columns * G.CARD_W / sizeDivisor,                                                 --width of cardarea
            0.95 * G.CARD_H / sizeDivisor,                                                    --height of cardarea
            { card_limit = columns, type = 'title', highlight_limit = 0, collection = true }) --basic config for a cardarea
        table.insert(deck_tables,
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.07 / sizeDivisor, no_fill = true, scale = 1 / sizeDivisor },
                nodes = {
                    { n = G.UIT.O, config = { object = G.your_collection[j] } }
                }
            } --actual ui form for the cardarea
        )
    end
    local centerPool = filterCenters(thegreatfilter or { "" }, getPCenterPoolsSorted("Joker")) --get the filtered out pool

    local center_options = {}
    for i = 1, math.ceil(#centerPool / (columns * #G.your_collection)) do
        table.insert(center_options,
            localize('k_page') ..
            ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#centerPool / (columns * #G.your_collection)))) --ignore weird formatting i just use the luals automation because
                                                                                                            --a lot of this is copypasted from vanilla sources   
                                                                                                            --anyways thats just for the page switching buttons
    end


    for i = 1, columns do --big loop that just inserts the proper cards into the cardarea 
        for j = 1, #G.your_collection do
            local center = centerPool[i + (j - 1) * columns]
            if center then
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y,
                    G.CARD_W / (sizeDivisor or 1),
                    G.CARD_H / (sizeDivisor or 1), nil, center)
                card.sticker = get_joker_win_sticker(center)
                G.your_collection[j]:emplace(card)
            end
        end
    end


    INIT_COLLECTION_CARD_ALERTS()

    local t = create_UIBox_generic_options({
        back_func = 'exit_overlay_menu', --not the default for a collection because this is brought up solo
        contents = {
            { n = G.UIT.R, config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables }, --cardareas
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    create_option_cycle({
                        options = center_options,
                        w = 4.5,
                        cycle_shoulders = true,
                        opt_callback =
                        'TMJCollectionPage',
                        current_option = 1,
                        colour = G.C.RED,
                        no_pips = true,
                        focus_args = { snap_to = true, nav = 'wide' }
                    })
                }
            }, --page switcher
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    create_text_input({
                        colour = G.C.RED,
                        hooked_colour = darken(copy_table(G.C.RED), 0.3),
                        w = 4.5,
                        h = 1,
                        max_length = 100,
                        extended_corpus = true,
                        prompt_text = "Keywords, broken by commas. Search for any card.",
                        ref_table = G,
                        ref_value = "ENTERED_FILTER",
                        keyboard_offset = 1,
                        callback = function()
                            G.FUNCS.reloadCollection()
                        end
                    }),
                },
            }, --textbox
        }
    })

    return t
end

function G.FUNCS.remove_collection(e)
    G.OVERLAY_MENU:remove()
    G.SETTINGS.paused = false
end

function G.FUNCS.TMJCollectionPage(args)
    if not args or not args.cycle_config then return end --this is leftover from source i dont think it serves a purpose
    local rows = tonumber(CGNUMROWS) or 3 --unused but keep it
    local columns = tonumber(CGNUMCOLUMNS) or 5
    local sizeDivisor = tonumber(CGSIZEDIVISOR) or 1

    local centerPool = filterCenters(thegreatfilter or { "" }, getPCenterPoolsSorted("Joker")) --get our filtered joker list

    for j = 1, #G.your_collection do
        for i = #G.your_collection[j].cards, 1, -1 do
            local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
            c:remove()
            c = nil
        end
    end --remove old cards
    for i = 1, columns do
        for j = 1, #G.your_collection do
            local center = centerPool
                [i + (j - 1) * columns + (columns * #G.your_collection * (args.cycle_config.current_option - 1))]
            if not center then break end
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G
                .CARD_W / sizeDivisor,
                G.CARD_H / sizeDivisor, G.P_CARDS.empty, center)
            card.sticker = get_joker_win_sticker(center)
            G.your_collection[j]:emplace(card)
        end
    end --add new cards
    INIT_COLLECTION_CARD_ALERTS() --alerts for unhovered new discoveries
end

local curmod = SMODS.current_mod
CGNUMROWS = ""
CGNUMCOLUMNS = ""
CGSIZEDIVISOR = ""

CGNUMROWS1 = ""
CGNUMCOLUMNS1 = ""
CGSIZEDIVISOR1 = ""

--first ones are backed by the second ones, which back the actual ui

curmod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = {
            emboss = 0.05,
            r = 0.1,
            minh = 4,
            minw = 3,
            align = 'cm',
            padding = 0.2,
            colour = G.C.BLACK,
        },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    create_text_input({
                        colour = G.C.RED,
                        hooked_colour = darken(copy_table(G.C.RED), 0.3),
                        w = 5,
                        h = 1,
                        max_length = 3,
                        extended_corpus = true,
                        prompt_text = "Number of collection rows",
                        ref_table = _G,
                        ref_value = "CGNUMROWS1"

                    }),
                    { n = G.UIT.T, config = { text = " / ", colour = G.C.WHITE, scale = 0.35 } },
                    create_text_input({
                        colour = G.C.RED,
                        hooked_colour = darken(copy_table(G.C.RED), 0.3),
                        w = 5,
                        h = 1,
                        max_length = 3,
                        extended_corpus = true,
                        prompt_text = "Number of collection columns",
                        ref_table = _G,
                        ref_value = "CGNUMCOLUMNS1"
                    }),
                }
            },



            {
                n = G.UIT.R,
                config = { align = "cm", minh = 1 },
                nodes = {
                    { n = G.UIT.T, config = { text = "Rows / Columns", colour = G.C.WHITE, scale = 0.35 } },
                }
            },
            {
                n = G.UIT.R,
                config = { minh = 1, minw = 5, align = "cm" },
                nodes = {
                    create_text_input({
                        colour = G.C.RED,
                        hooked_colour = darken(copy_table(G.C.RED), 0.3),
                        w = 5,
                        h = 1,
                        max_length = 5,
                        extended_corpus = true,
                        prompt_text = "Size divisor (higher=smaller)",
                        ref_table = _G,
                        ref_value = "CGSIZEDIVISOR1"
                    }),
                }
            }
        }
    }
end

local f = { "CGSIZEDIVISOR", "CGNUMROWS", "CGNUMCOLUMNS" }

local oldupd = love.update
function love.update(...)
    oldupd(...)
    for _, i in pairs(f) do
        i = i
        if _G[i .. "1"] ~= '' then
            _G[i] = _G[i .. "1"]
        end
    end
end

local config = nfs.read(SMODS.Mods.toomanyjokers.path .. "config.txt") or "3,5,1"
--fetch config

local s = string.split(config)
CGNUMROWS, CGNUMCOLUMNS, CGSIZEDIVISOR = s[1] or "3", s[2] or "5", s[3] or "1"
--this is peak..

local oldcuib = create_UIBox_generic_options
create_UIBox_generic_options = function(arg1, ...) --inserts the text into most collection pages without needing to hook each individual function
    if arg1.back_func == "your_collection" and arg1.contents[1].n == 4 then
        table.insert(arg1.contents, {
            n = 4,
            config = { align = "cm", minh = 1 },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.C, config = { align = "cl", minw = 5 }, nodes = { { n = G.UIT.T, config = { text = "Press T to access Too Many Jokers", colour = G.C.WHITE, shadow = true, scale = 0.5 } } } }
                    }
                }
            }
        })
    end
    return oldcuib(arg1, ...)
end
