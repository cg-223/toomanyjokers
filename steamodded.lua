local NFS = NFS or require("nativefs")
TMJ = assert(SMODS.current_mod)
TMJ.FUNCS = {}
TMJ.CACHES = {
    match_strings = {},
    serach_results = {},
    sorted_pools = {},
}
SMODS.load_mod_config(TMJ)
if not (TMJ.config and TMJ.config.rows and TMJ.config.columns and TMJ.config.size and TMJ.config.pinned_keys and (TMJ.config.hide_undiscovered ~= nil) and (TMJ.config.close_on_esc ~= nil) and (TMJ.config.scroll_full_page ~= nil)) then
    TMJ.config = TMJ.config or {}
    TMJ.config = {
        rows = TMJ.config.rows or 4,
        columns = TMJ.config.columns or 4,
        size = TMJ.config.size or 0.7,
        pinned_keys = TMJ.config.pinned_keys or {},
        hide_undiscovered = TMJ.config.hide_undiscovered or false,
        close_on_esc = TMJ.config.close_on_esc or false,
        scroll_full_page = TMJ.config.scroll_full_page or false
    }
    SMODS.save_mod_config(TMJ)
end
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
local scripts = { "utils", "config", "searcher", "ui", "banner" }
local tests = {}
for i, v in ipairs(scripts) do
    assert(SMODS.load_file("TMJ/" .. v .. ".lua"))()
    if TMJ.DEBUG and _G[v .. "_unit_tests"] then
        table.insert(tests, _G[v .. "_unit_tests"])
    end
end
G.FUNCS.CloseTMJ = function()
    G.TMJUI:remove()
    G.TMJUI = nil
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

SMODS.Keybind({
    key = "openTMJ",
    key_pressed = "t",
    action = function()
        if G.TMJUI then
            G.FUNCS.CloseTMJ()
        else
            TMJ.FUNCS.OPENFROMKEYBIND()
        end
    end
})

local old = love.keypressed
local wanted_chars = table_into_hashset(collect(string.gmatch("abcdefghijklmnopqrsuvwxyz{}!", ".")))
wanted_chars["return"] = true
local unwanted_chars = collect(string.gmatch("lctrl rctrl lalt ralt", "(.-) "))
function love.keypressed(key)
    if key == "escape" and G.TMJUI and TMJ.config.close_on_esc then
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

SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34
}

SMODS.DrawStep {
    key = 'tmjui_draw',
    order = 100,
    func = function(self)
        if G.TMJUI and G.TMJUI.draw then
            G.TMJUI:draw()
        end
    end
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
    loc_txt = {
        name = "Pinned",
        text = {
            "Ctrl+click to unpin"
        }
    },
}
G.localization.misc.labels.tmj_pinned = "Pinned"
local oldcuib = create_UIBox_generic_options
create_UIBox_generic_options = function(arg1, ...) --inserts the text into most collection pages without needing to hook each individual function
    if arg1.back_func == "your_collection" and arg1.contents[1].n == 4 and not TMJ.config.hide_collection_text then
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
