--- STEAMODDED HEADER
--- MOD_NAME: Too Many Jokers
--- MOD_ID: toomanyjokers
--- MOD_AUTHOR: [cg]
--- PREFIX: tmj
--- MOD_DESCRIPTION: Adds a filtering system to the Joker collection.
--- PRIORITY: 1000000

local NFS = NFS or require("nativefs")
--test 12!??
local tmj = SMODS.current_mod
TMJ = {}
TMJ.SMODSmodtable = tmj
TMJ.FUNCS = {}
TMJ.PATH = tmj.path
TMJ.SEARCHERCACHE = {}
TMJ.SORTERCACHE = {}
local scripts = NFS.getDirectoryItems(TMJ.PATH.."/TMJ")
for i, v in pairs(scripts) do
    assert(loadfile(NFS.read(TMJ.PATH.."/TMJ/"..v)), "Bad file at "..TMJ.PATH.."/TMJ/"..v)()
end

local ourref = love.wheelmoved or function() end
function love.wheelmoved(x, y)
	ourref(x, y)
    if y and G.TMJUI then
        G.FUNCS.TMJSCROLLUI(-y)
    end
end

local function getCenterKeyFromCard(card)
    local center = card.config.center
    for i, v in pairs(G.P_CENTERS) do
        if v == center then
            return i
        end
    end
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
                TMJ.thegreatfilter = {"{key="..getCenterKeyFromCard(card)..",mod}"}
                reload = true
            elseif not controller.held_keys.lctrl and controller.held_keys.lshift then
                local card = controller.hovering.target
                TMJ.thegreatfilter = {"{key="..getCenterKeyFromCard(card)..",rarity}"}
                reload = true
            elseif controller.held_keys.lctrl and controller.held_keys.lshift then
                local card = controller.hovering.target
                TMJ.thegreatfilter = {"{key="..getCenterKeyFromCard(card)..",mod}", "{key="..getCenterKeyFromCard(card)..",rarity}"}
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