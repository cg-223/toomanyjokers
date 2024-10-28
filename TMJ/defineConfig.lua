local nfs = require("nativefs")
TMJ.config = {}
local config = nfs.read(SMODS.Mods.toomanyjokers.path .. "config.txt") or "5,3,0.75"
local s = TMJ.FUNCS.commaSplit(config)
TMJ.config.rows, TMJ.config.columns, TMJ.config.size = s[1] or "5", s[2] or "3", s[3] or "0.75"

SMODS.current_mod.config_tab = function()
    G.E_MANAGER:add_event(Event{
        func = function()
            G.FUNCS.TMJUIBOX()
            return true
        end,
        delay = 0.3,
    })
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
