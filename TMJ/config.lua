TMJ.fake_config = {
    rows = tostring(TMJ.config.rows),
    columns = tostring(TMJ.config.columns),
    size = tostring(TMJ.config.size),
}

TMJ.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = { align = "cm", minh = G.ROOM.T.h * 0.25, padding = 0.0, r = 0.1, colour = G.C.GREY },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cl" },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cl", padding = 0.2 },
                        nodes = {
                            create_text_input({
                                colour = G.C.RED,
                                align = "cl",
                                hooked_colour = darken(copy_table(G.C.RED), 0.3),
                                w = 5,
                                h = 1,
                                max_length = 3,
                                extended_corpus = true,
                                prompt_text = "",
                                id = "TMJROWS",
                                ref_table = TMJ.fake_config,
                                ref_value = "rows"
                            }),
                            { n = G.UIT.T, config = { text = "Number of rows", align = "cr", colour = G.C.WHITE, scale = 0.35 } },
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cl" },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cl", padding = 0.2 },
                        nodes = {
                            create_text_input({
                                colour = G.C.RED,
                                align = "cl",
                                hooked_colour = darken(copy_table(G.C.RED), 0.3),
                                w = 5,
                                h = 1,
                                max_length = 3,
                                extended_corpus = true,
                                prompt_text = "",
                                id = "TMJCOLS",
                                ref_table = TMJ.fake_config,
                                ref_value = "columns"
                            }),
                            { n = G.UIT.T, config = { align = "cr", text = "Number of columns", colour = G.C.WHITE, scale = 0.35 } },

                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cl" },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cl", padding = 0.2 },
                        nodes = {
                            create_text_input({
                                align = "cl",
                                colour = G.C.RED,
                                hooked_colour = darken(copy_table(G.C.RED), 0.3),
                                w = 5,
                                h = 1,
                                max_length = 3,
                                extended_corpus = true,
                                prompt_text = "",
                                id = "TMJSIZE",
                                ref_table = TMJ.fake_config,
                                ref_value = "size"
                            }),
                            { n = G.UIT.T, config = { align = "cr", text = "Card size", colour = G.C.WHITE, scale = 0.35 } },

                        }
                    }
                }
            }
        }
    }
end
