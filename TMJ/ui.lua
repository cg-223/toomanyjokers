function TMJ.FUNCS.ui_box()
    return UIBox {
        definition = { n = G.UIT.ROOT, config = { align = 'cm', r = 0.01 }, nodes = {
            UIBox_dyn_container(TMJ.FUNCS.inner_nodes()) } },
        config = { align = 'cli', offset = { x = -1, y = G.ROOM.T.h - 2.333 }, major = G.ROOM_ATTACH, bond = 'Weak' }
    }
end

function TMJ.FUNCS.inner_nodes()
    return {
        { n = G.UIT.R, config = { align = "cm", r = 0.01, colour = G.C.BLACK, emboss = 0.05 }, nodes = TMJ.FUNCS.make_card_areas() }, --cardareas
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
                    config = { align = "cm", id = "TMJTEXTINP" },
                    callback = function()
                        local tosplit = G.ENTERED_FILTER
                        tosplit = string.lower(tosplit)
                        tosplit = string.gsub(tosplit, " ", "")
                        local split = string.split(tosplit, ",")

                        TMJ.thegreatfilter = split
                        G.ENTERED_FILTER = ""
                        todo()
                    end
                }),
            },
        }, --textbox
        {
            n = G.UIT.R,
            config = { align = "cm", maxh = 1 },
            nodes = {
                UIBox_button({
                    colour = G.C.RED,
                    button = "CloseTMJ",
                    label = { "Close" },
                    minw = 3,
                    focus_args = { snap_to = true },
                }),
            }
        },
        {
            n = G.UIT.R,
            config = { minw = G.ROOM.T.w * 0.25, padding = 0.05, align = "cm" },
            nodes = {
                { n = G.UIT.T, config = { text = "Type keywords, separated by commas", colour = G.C.WHITE, scale = 0.35 } },
            }
        },
        {
            n = G.UIT.R,
            config = { minw = G.ROOM.T.w * 0.25, padding = 0.05, align = "cm" },
            nodes = {
                { n = G.UIT.T, config = { text = "Ctrl+click to pin a card", colour = G.C.WHITE, scale = 0.35 } },
            }
        },
    }
end

function TMJ.FUNCS.make_card_areas()
    todo()
end