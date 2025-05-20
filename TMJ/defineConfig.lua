local nfs = require("nativefs")
TMJ.config = {}
local config = nfs.read("config/toomanyjokers.txt") or "5,4,0.65,1"
local s = TMJ.FUNCS.commaSplit(config)
TMJ.config.rows, TMJ.config.columns, TMJ.config.size, TMJ.config.autoselect = s[1] or "5", s[2] or "4", s[3] or "0.65", s[4] or "1"
TMJ.config.placeholder = ""
TMJ.config.currentMode = "Rows"
TMJ.config.tautoselect = (TMJ.config.autoselect == "1") and true
function TMJ.FUNCS.register_config_after_load()
    TMJ.CONFIG_REGISTERED = true
    local valid_keys = {}
    for i = 4, #s do
        local cur = s[i]
        if G.P_CENTERS[cur] then
            valid_keys[cur] = true
        end
    end
    TMJ.PINNED_KEYS = valid_keys
end

function TMJ.FUNCS.save_config()
    local tmjpath = "config/toomanyjokers.txt"
    local rows = tostring(TMJ.config.rows) or "5"
    local cols = tostring(TMJ.config.columns) or "3"
    local size = tostring(TMJ.config.size) or "0.65"
    local autoselect = TMJ.config.autoselect or "1"
    local pinned_keys = TMJ.PINNED_KEYS
    local pkeystr = ""
    for i, v in pairs(pinned_keys) do
        if v then
            pkeystr = pkeystr .. i
            pkeystr = pkeystr .. ","
        end
    end
    pkeystr = TMJ.FUNCS.stripFinal(pkeystr) --totally needed the extra function for this
    nfs.write(tmjpath, rows .. "," .. cols .. "," .. size .. "," .. autoselect .. "," .. pkeystr)
end

SMODS.current_mod.config_tab = function()
    TMJ.config.currentMode = "Rows"
    return {
        n = G.UIT.ROOT,
        config = { align = "cm", minh = G.ROOM.T.h * 0.25, padding = 0.0, r = 0.1, colour = G.C.GREY },
        nodes = {
            {
                n = G.UIT.R,
                config = { padding = 0.05 },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {align = "cm", minw = G.ROOM.T.w * 0.25, padding = 0.05},
                        nodes = {
                            create_toggle({
                                label = "Autoselect searchbar",
                                ref_table = TMJ.config,
                                ref_value = "tautoselect",
                                callback = function() TMJ.config.autoselect = TMJ.config.tautoselect and "1" or "0" end,
                            })
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { minw = G.ROOM.T.w * 0.25, padding = 0.05, align = "cm" },
                        nodes = {
                            create_text_input({
                                colour = G.C.RED,
                                hooked_colour = darken(copy_table(G.C.RED), 0.3),
                                w = 5,
                                h = 1,
                                max_length = 3,
                                extended_corpus = true,
                                prompt_text = "",
                                ref_table = TMJ.config,
                                ref_value = "placeholder"
                            }),
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", minw = G.ROOM.T.w * 0.25, padding = 0.05 },
                        nodes = {
                            create_option_cycle({
                                options = {"Rows", "Columns", "Card Scale"},
                                w = 4.5,
                                cycle_shoulders = true,
                                opt_callback = "TMJ_SET_CONFIG",
                                current_option = 1,
                                colour = G.C.RED,
                                no_pips = true,
                                focus_args = { snap_to = true, nav = "wide" },
                            }),
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", minw = G.ROOM.T.w * 0.25, padding = 0.05 },
                        nodes = {
                            UIBox_button({
                                colour = G.C.RED,
                                button = "TMJ_SAVE_CONFIG",
                                label = {"Save current"},
                                minw = 4.5,
                                focus_args = { snap_to = true },
                            }),
                        }
                    },

                }
            }
        }
    }
end
local opttbl = {"Rows", "Columns", "Card Scale"}
G.FUNCS.TMJ_SET_CONFIG = function(args)
    local option = opttbl[args.cycle_config.current_option]
    TMJ.config.currentMode = option
end

G.FUNCS.TMJ_SAVE_CONFIG = function(args)
    if TMJ.config.currentMode == "Rows" then
        TMJ.config.rows = TMJ.config.placeholder
    elseif TMJ.config.currentMode == "Columns" then
        TMJ.config.columns = TMJ.config.placeholder
    else
        TMJ.config.size = TMJ.config.placeholder
    end
end