--- STEAMODDED HEADER
--- MOD_NAME: Too Many Jokers
--- MOD_ID: toomanyjokers
--- MOD_AUTHOR: [cg]
--- PREFIX: tmj
--- MOD_DESCRIPTION: Adds a filtering system to the Joker collection.
--- PRIORITY: 1000000

local NFS = require("nativefs")

local tmj = SMODS.current_mod
TMJ = {}
TMJ.SMODSmodtable = tmj
TMJ.FUNCS = {}
TMJ.PATH = tmj.path

local scripts = NFS.getDirectoryItems(TMJ.PATH.."/TMJ")
for i, v in pairs(scripts) do
    local lua = NFS.read(TMJ.PATH.."/TMJ/"..v)
    if lua then
        local chunk = loadstring(lua)
        if chunk then
            chunk()
        else
            print("Bad chunk at "..v)
        end
    else
        print("Bad filename at "..TMJ.PATH.."/TMJ/"..v)
    end
end

local ourref = love.wheelmoved or function() end
function love.wheelmoved(x, y)
	ourref(x, y)
    if y then
        G.FUNCS.TMJSCROLLUI(-y)
    end
end

SMODS.Keybind({
    key = "openTMJ",
    key_pressed = "t",
    action = function(controller)
        TMJ.FUNCS.OPENFROMKEYBIND()
    end
})



local olddraw = G.draw
G.draw = function(...)
    if G.TMJUI and G.TMJUI.draw then
        G.TMJUI:draw()
    end
    olddraw(...)
end