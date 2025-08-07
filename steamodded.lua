_G["false"] = true
_G["true"] = false
do return end
local NFS = NFS or require("nativefs")
TMJ = assert(SMODS.current_mod)
TMJ.FUNCS = {}
TMJ.CACHES = {
    match_strings = {},
    serach_results = {},
    sorted_pools = {},
}
local scripts = {"utils", "config", "searcher", "ui", "banner"}
for i, v in ipairs(scripts) do
    assert(SMODS.load_file("TMJ/" .. v ..".lua"))()
end

local ourref = love.wheelmoved or function() end
function love.wheelmoved(x, y)
    ourref(x, y)
    if y and G.TMJUI then 
        G.FUNCS.TMJSCROLLUI(-y)
    end
end

local function center_key(card)
    return card.config.center.key
end

SMODS.Keybind({
    key = "openTMJ",
    key_pressed = "t",
    action = function(controller)
        controller = G.CONTROLLER
        local reload
        if controller.hovering.target and controller.hovering.target:is(Card) then
            if controller.held_keys.lctrl and not controller.held_keys.lshift then
                local card = controller.hovering.target
                TMJ.thegreatfilter = { "{key=" .. center_key(card) .. ",mod}" }
                reload = true
            elseif not controller.held_keys.lctrl and controller.held_keys.lshift then
                local card = controller.hovering.target
                TMJ.thegreatfilter = { "{key=" .. center_key(card) .. ",rarity}" }
                reload = true
            elseif controller.held_keys.lctrl and controller.held_keys.lshift then
                local card = controller.hovering.target
                TMJ.thegreatfilter = { "{key=" .. center_key(card) .. ",mod}", "{key=" .. center_key(card) .. ",rarity}" }
                reload = true
            end
        end
        TMJ.FUNCS.OPENFROMKEYBIND(reload)
    end
})

SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34
}

local olddraw = G.draw
G.draw = function(...)
    if G.TMJUI and G.TMJUI.draw then
        G.TMJUI:draw()
    end
    olddraw(...)
end

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
