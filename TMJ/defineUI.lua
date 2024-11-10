G.ENTERED_FILTER = ""
local nfs = require("nativefs")
function G.FUNCS.TMJUIBOX(e)
    if G.TMJUI then
        G.TMJUI:remove()
        G.TMJUI = nil
    else
        G.TMJUI = UIBox {
            definition = { n = G.UIT.ROOT, config = { align = 'cm', r = 0.01 }, nodes = {
                UIBox_dyn_container(G.FUNCS.TMJMAINNODES()) } },
            config = { align = 'cl', offset = { x = 4, y = G.ROOM.T.h - 2.333 }, major = G.ROOM_ATTACH, bond = 'Weak' }
        }
        return G.TMJUI
    end
    if e == "reload" then
        G.TMJUI = UIBox {
            definition = { n = G.UIT.ROOT, config = { align = 'cm', r = 0.01 }, nodes = {
                UIBox_dyn_container(G.FUNCS.TMJMAINNODES()) } },
            config = { align = 'cl', offset = { x = 4, y = G.ROOM.T.h - 2.333 }, major = G.ROOM_ATTACH, bond = 'Weak' }
        }
        return G.TMJUI
    end
end

function G.FUNCS.TMJMAINNODES()
    TMJ.config.rows = TMJ.config.rows or "5"
    TMJ.config.columns = TMJ.config.columns or "3"
    TMJ.config.size = TMJ.config.size or "0.75"

    nfs.write("config/toomanyjokers.txt",
        (tostring(TMJ.config.rows) or "5") ..
        "," .. (tostring(TMJ.config.columns) or "3") .. "," .. (tostring(TMJ.config.size) or "0.75"))


    local rowcount = tonumber(TMJ.config.rows) or 5       --use config at this point
    local columncount = tonumber(TMJ.config.columns) or 3 --use config at this point
    local sizediv = (1 / (tonumber(TMJ.config.size) or 0.75)) or 1.5
    TMJ.TMJCurCardIndex = 0
    local cardAreas = {}
    G.TMJCOLLECTION = {}
    for i = 1, rowcount do
        G.TMJCOLLECTION[i] = CardArea(                                                            --insert this cardarea into the table we feed to our ui
            0, 0,                                                                                 --position
            columncount * G.CARD_W / sizediv,                                                     --width of cardarea
            0.95 * G.CARD_H / sizediv,                                                            --height of cardarea
            { card_limit = columncount, type = 'title', highlight_limit = 0, collection = true }) --basic config for a cardarea } }


        cardAreas[i] = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.07 / sizediv, no_fill = true, scale = 1 / sizediv },
            nodes = {
                {
                    n = G.UIT.O,
                    config = {
                        object = G.TMJCOLLECTION[i]
                    }
                }
            }
        }
    end

    local centerPool = TMJ.FUNCS.cacheSearchIntermediary(TMJ.thegreatfilter or { "" }, TMJ.FUNCS.cacheSorterIntermediary("Joker")) --get the filtered out pool

    for i = 1, columncount do                                                                                          --big loop that just inserts the proper cards into the cardarea
        for j = 1, #G.TMJCOLLECTION do
            local center = centerPool[i + (j - 1) * columncount]
            if center then
                local card = Card(G.TMJCOLLECTION[j].T.x + G.TMJCOLLECTION[j].T.w / 2, G.TMJCOLLECTION[j].T.y,
                    G.CARD_W / (sizediv or 1),
                    G.CARD_H / (sizediv or 1), nil, center)
                card.sticker = get_joker_win_sticker(center)
                G.TMJCOLLECTION[j]:emplace(card)
            end
        end
    end


    for j = 1, #G.TMJCOLLECTION do
        for _, v in ipairs(G.TMJCOLLECTION[j].cards) do
            v:update_alert()
        end
    end


    local t = {
        { n = G.UIT.R, config = { align = "cm", r = 0.01, colour = G.C.BLACK, emboss = 0.05 }, nodes = cardAreas }, --cardareas
        {
            n = G.UIT.R,
            config = { align = "cm" },
            nodes = {
                create_text_input({
                    colour = G.C.RED,
                    hooked_colour = darken(copy_table(G.C.RED), 0.3),
                    w = 3,
                    h = 1,
                    max_length = 100,
                    extended_corpus = true,
                    prompt_text = "",
                    ref_table = G,
                    ref_value = "ENTERED_FILTER",
                    keyboard_offset = 1,
                    config = { align = "cm" },
                    callback = function()
                        local tosplit = G.ENTERED_FILTER
                        tosplit = string.lower(tosplit)
                        tosplit = string.gsub(tosplit, " ", "")
                        local split = TMJ.FUNCS.commaSplit(tosplit)

                        TMJ.thegreatfilter = split
                        G.ENTERED_FILTER = ""
                        G.FUNCS.TMJUIBOX("reload")
                    end
                }),
            },
        }, --textbox
        {
            n = G.UIT.R,
            config = { minw = G.ROOM.T.w * 0.25, padding = 0.05, align = "cm" },
            nodes = {
                { n = G.UIT.T, config = { text = "Type keywords, separated by commas", colour = G.C.WHITE, scale = 0.35 } },
            }
        },
    }


    return t
end

function G.FUNCS.TMJSCROLLUI(num)
    if G.TMJUI and next(G.TMJUI) then
        local centerPool = TMJ.FUNCS.cacheSearchIntermediary(TMJ.thegreatfilter or { "" }, TMJ.FUNCS.cacheSorterIntermediary("Joker"))
        TMJ.config.rows = TMJ.config.rows or "5"
        TMJ.config.columns = TMJ.config.columns or "3"
        TMJ.config.size = TMJ.config.size or "0.75"
        local rowcount = tonumber(TMJ.config.rows) or 5       --use config at this point
        local columncount = tonumber(TMJ.config.columns) or 3 --use config at this point
        local sizediv = (1 / (tonumber(TMJ.config.size) or 0.75)) or 1.5
        TMJ.TMJCurCardIndex = TMJ.TMJCurCardIndex + (num * columncount)
        for i = 1, #G.TMJCOLLECTION do
            for j = 1, #G.TMJCOLLECTION[i].cards do
                if G.TMJCOLLECTION[i].cards[1] then
                    G.TMJCOLLECTION[i].cards[1]:remove()
                end
            end
        end
        for i = 1, columncount do --big loop that just inserts the proper cards into the cardarea
            for j = 1, #G.TMJCOLLECTION do
                local center = centerPool[(i + (j - 1) * columncount) + (TMJ.TMJCurCardIndex)]
                if center then
                    local card = Card(G.TMJCOLLECTION[j].T.x + G.TMJCOLLECTION[j].T.w / 2, G.TMJCOLLECTION[j].T.y,
                        G.CARD_W / (sizediv or 1),
                        G.CARD_H / (sizediv or 1), nil, center)
                    card.sticker = get_joker_win_sticker(center)
                    G.TMJCOLLECTION[j]:emplace(card)
                end
            end
        end
    end
end

TMJ.FUNCS.OPENFROMKEYBIND = function()
    G.FUNCS.TMJUIBOX()
end
