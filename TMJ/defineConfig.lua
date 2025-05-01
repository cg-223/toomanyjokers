local nfs = require("nativefs")
TMJ.config = {}
local config = nfs.read("config/toomanyjokers.txt") or "5,4,0.65"
local s = TMJ.FUNCS.commaSplit(config)
TMJ.config.rows, TMJ.config.columns, TMJ.config.size = s[1] or "5", s[2] or "4", s[3] or "0.65"

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
    local pinned_keys = TMJ.PINNED_KEYS
    local pkeystr = ""
    for i, v in pairs(pinned_keys) do
        if v then
            pkeystr = pkeystr .. i
            pkeystr = pkeystr .. ","
        end
    end
    pkeystr = TMJ.FUNCS.stripFinal(pkeystr) --totally needed the extra function for this
    nfs.write(tmjpath, rows .. "," .. cols .. "," .. size .. "," .. pkeystr)
end

SMODS.current_mod.config_tab = function()
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
                        config = { minw = G.ROOM.T.w * 0.25, padding = 0.05, align = "cm" },
                        nodes = {
                            create_text_input({
                                colour = G.C.RED,
                                hooked_colour = darken(copy_table(G.C.RED), 0.3),
                                w = 5,
                                h = 1,
                                max_length = 3,
                                extended_corpus = true,
                                prompt_text = "Number of collection rows",
                                ref_table = TMJ.config,
                                ref_value = "rows"
                                
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
                                ref_table = TMJ.config,
                                ref_value = "columns"
                            }),
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { minw = G.ROOM.T.w * 0.25, padding = 0.05, align = "cm" },
                        nodes = {
                            { n = G.UIT.T, config = { text = "Rows / Columns", colour = G.C.WHITE, scale = 0.35 } },
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", minw = G.ROOM.T.w * 0.25, padding = 0.05 },
                        nodes = {
                            create_text_input({
                                colour = G.C.RED,
                                hooked_colour = darken(copy_table(G.C.RED), 0.3),
                                w = 5,
                                h = 1,
                                max_length = 5,
                                extended_corpus = true,
                                prompt_text = "Card scale",
                                ref_table = TMJ.config,
                                ref_value = "size",
                                align = "cm"
                            }),
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { minw = G.ROOM.T.w * 0.25, padding = 0.05, align = "cm" },
                        nodes = {
                            { n = G.UIT.T, config = { text = "Card Scale", colour = G.C.WHITE, scale = 0.35 } },
                        }
                    },
                }
            }
        }
    }
end
