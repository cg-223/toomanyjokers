local NFS = NFS or require("nativefs")
TMJ = assert(SMODS.current_mod)
TMJ.FUNCS = {}
TMJ.CACHES = {
    match_strings = {},
    serach_results = {},
    sorted_pools = {},
}
SMODS.load_mod_config(TMJ)
TMJ.config = TMJ.config or {}
TMJ.config = {
    rows = TMJ.config.rows or 4,
    columns = TMJ.config.columns or 4,
    size = TMJ.config.size or 0.7,
    pinned_keys = TMJ.config.pinned_keys or {},
    hide_undiscovered = TMJ.config.hide_undiscovered or false,
    close_on_esc = TMJ.config.close_on_esc or false,
    scroll_full_page = TMJ.config.scroll_full_page or false,
    disable_ctrl_enter = TMJ.config.disable_ctrl_enter or false,
    arrow_key_scroll = TMJ.config.arrow_key_scroll or false
}
SMODS.save_mod_config(TMJ)
if _RELEASE_MODE then TMJ.config.disable_ctrl_enter = true end
local old = SMODS.save_mod_config
function SMODS.save_mod_config(mod)
    if mod == TMJ then
        for i, v in pairs(TMJ.fake_config) do
            TMJ.config[i] = tonumber(v or TMJ.config[i]) or TMJ.config[i]
        end
        TMJ.get_centers_caches.centers_that_match = {}
    end
    old(mod)
end

TMJ.DEBUG = true
local scripts = { "utils", "config", "searcher", "ui", "banner", "compat" }
local tests = {}
for i, v in ipairs(scripts) do
    assert(SMODS.load_file("TMJ/" .. v .. ".lua"))()
    if TMJ.DEBUG and _G[v .. "_unit_tests"] then
        table.insert(tests, _G[v .. "_unit_tests"])
    end
end
G.FUNCS.CloseTMJ = function()
    G.TMJUI:remove()
    G.TMJTAGS:remove()
    G.TMJUI = nil
    TMJ.thegreatfilter = ""
    G.ENTERED_FILTER = ""
    for i, v in pairs(G.TMJCOLLECTION) do
        v:remove()
    end
    TMJ.scrolled_amount = 0
end
local ourref = love.wheelmoved or function() end
function love.wheelmoved(x, y)
    ourref(x, y)
    if y and G.TMJUI then
        if TMJ.config.scroll_full_page then
            TMJ.FUNCS.scroll(-(y * TMJ.config.rows))
        else
            TMJ.FUNCS.scroll(-y)
        end
    end
end

local toggle_ref = G.FUNCS.toggle
function G.FUNCS.toggle(e, ...)
    if e.children and e.children[1] then
        return toggle_ref(e, ...)
    end
end

local upd_ref = love.update
function love.update(dt)
    upd_ref(dt)
    if G.TMJUI and TMJ.held_arrow and TMJ.held_arrow_time and not TMJ.config.scroll_full_page then
        if love.timer.getTime() - 0.35 > TMJ.held_arrow_time then
            if love.timer.getTime() - 0.15 > TMJ.last_arrow_time then
                TMJ.last_arrow_time = love.timer.getTime()
                TMJ.FUNCS.scroll(TMJ.held_arrow == "up" and -1 or 1)
            end
        end
    end
end

SMODS.Keybind({
    key = "openTMJ",
    key_pressed = "t",
    action = function()
        if G.TMJUI then
            if not TMJ.config.close_on_esc then
                G.FUNCS.CloseTMJ()
            end
        else
            TMJ.FUNCS.reload()
        end
    end
})

local old = love.keypressed
local wanted_chars = table_into_hashset(collect(string.gmatch("abcdefghijklmnopqrstuvwxyz[]!", ".")))
wanted_chars["return"] = true
local unwanted_chars = collect(string.gmatch("lctrl rctrl lalt ralt", "(.-) "))
function love.keypressed(key)
    if key == "escape" and G.TMJUI and TMJ.config.close_on_esc then
        G.FUNCS.CloseTMJ()
        return
    end
    if TMJ.config.arrow_key_scroll and G.TMJUI then
        local mul = ((G.CONTROLLER.held_keys.lctrl or G.CONTROLLER.held_keys.rctrl or TMJ.config.scroll_full_page) and TMJ.config.rows) or 1
        if key == "up" then
            TMJ.held_arrow = key 
            TMJ.held_arrow_time = love.timer.getTime()
            TMJ.last_arrow_time = love.timer.getTime()
            TMJ.FUNCS.scroll(-1 * mul)
        elseif key == "down" then
            TMJ.held_arrow = key 
            TMJ.held_arrow_time = love.timer.getTime()
            TMJ.last_arrow_time = love.timer.getTime()
            TMJ.FUNCS.scroll(1 * mul)
        end
    end
    if not TMJ.config.disable_ctrl_enter and key == "return" and G.CONTROLLER.held_keys.lctrl and G.TMJUI and G.CONTROLLER.text_input_hook and G.TMJUI:get_UIE_by_ID("TMJTEXTINP") and G.TMJUI:get_UIE_by_ID("TMJTEXTINP").children[1].children[1].children[1] == G.CONTROLLER.text_input_hook then
        TMJ.thegreatfilter = G.ENTERED_FILTER
        G.ENTERED_FILTER = ""
        TMJ.scrolled_amount = 0
        TMJ.FUNCS.reload()
        local first_card = G.TMJCOLLECTION[1].cards[1]
        if first_card then
            local _area
            if first_card.ability.set == 'Joker' then
                _area = G.jokers
            elseif first_card.playing_card then
                if G.hand and G.hand.config.card_count ~= 0 then
                    _area = G.hand
                else
                    _area = G.deck
                end
            elseif first_card.ability.consumeable then
                _area = G.consumeables
            end
            if _area then
                local new_card = copy_card(first_card, nil, nil, first_card.playing_card)
                new_card:add_to_deck()
                if first_card.playing_card then
                    table.insert(G.playing_cards, new_card)
                end
                _area:emplace(new_card)
            end
        end
        G.FUNCS.CloseTMJ()
        return
    end
    for _, char in pairs(unwanted_chars) do
        if G.CONTROLLER.held_keys[char] then
            return old(key)
        end
    end
    if G.TMJUI and wanted_chars[key] and G.TMJUI:get_UIE_by_ID("TMJTEXTINP") then
        G.FUNCS.select_text_input(G.TMJUI:get_UIE_by_ID("TMJTEXTINP").children[1])
    end
    old(key)
end

local oldrelease = love.keyreleased
function love.keyreleased(key)
    oldrelease(key)
    if key == "up" or key == "down" then
        TMJ.held_arrow = nil
    end
end

SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34
}


SMODS.Atlas {
    key = "pinned",
    path = "pinned.png",
    px = 71,
    py = 95,
}

SMODS.Sticker {
    key = "pinned",
    atlas = "pinned",
    default_compat = false,
    badge_colour = HEX 'fda200',
    rate = 0,
    needs_enable_flag = true,
    should_apply = false, --i REALLY dont want this affecting normal gameplay
    no_collection = true,
    loc_txt = {
        name = "Pinned",
        text = {
            "Ctrl+click to unpin"
        }
    },
}
G.localization.misc.labels.tmj_pinned = "Pinned"

local oldcc = copy_card
function copy_card(card, ...)
    local ret = oldcc(card, ...)
    if card.area and card.area.config.tmj then
        SMODS.Stickers.tmj_pinned:apply(ret, false)
    end
    return ret
end

local oldcuib = create_UIBox_generic_options
create_UIBox_generic_options = function(arg1, ...) --inserts the text into most collection pages without needing to hook each individual function
    if arg1 and arg1.back_func == "your_collection" and arg1.contents and arg1.contents[1] and arg1.contents[1].n == 4 and not (TMJ.config and TMJ.config.hide_collection_text) then
        table.insert(arg1.contents, {
            n = G.UIT.R,
            config = { align = "cm", minh = 0.5 },
            nodes = {

                { n = G.UIT.C, config = { align = "cm", minw = 5 }, nodes = { { n = G.UIT.T, config = { text = "Press T to access Too Many Jokers", colour = G.C.WHITE, shadow = true, scale = 0.3 } } } }

            }
        })
    end
    return oldcuib(arg1, ...)
end


for i, v in ipairs(tests) do
    v()
end
