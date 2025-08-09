function TMJ.FUNCS.ui_box()
    return UIBox {
        definition = { n = G.UIT.ROOT, config = { align = 'cm', r = 0.01 }, nodes = {
            UIBox_dyn_container(TMJ.FUNCS.inner_nodes()) } },
        config = { align = 'cli', offset = { x = -1, y = G.ROOM.T.h - 2.333 }, major = G.ROOM_ATTACH, bond = 'Weak' }
    }
end
G.ENTERED_FILTER = ""
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
                        TMJ.thegreatfilter = string.split(lower_spaceless(G.ENTERED_FILTER), ",")
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
    G.TMJCOLLECTION = {}
    local card_limit = TMJ.config.columns
    local num_areas = TMJ.config.rows
    local card_scale = TMJ.config.size
    local areas = {}
    for i = 1, num_areas do
        local area = CardArea(                                                                   --insert this cardarea into the table we feed to our ui
            0, 0,                                                                                --position
            card_limit * G.CARD_W / card_scale,                                                  --width of cardarea
            0.95 * G.CARD_H / card_scale,                                                        --height of cardarea
            { card_limit = card_limit, type = 'title', highlight_limit = 0, collection = true }) --basic config for a cardarea
        G.TMJCOLLECTION[i] = area
        table.insert(areas, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.07 / card_scale, no_fill = true, scale = 1 / card_scale },
            nodes = { n = G.UIT.O, config = { object = area } }
        })
    end
    return areas
end

function TMJ.make_cards(areas)
    local card_limit = TMJ.config.columns
    local num_areas = TMJ.config.rows
    local initial_offset = TMJ.config.columns * TMJ.scrolled_amount
    initial_offset = math.clamp(initial_offset, 0)
    local centers = TMJ.FUNCS.get_centers(G.ENTERED_FILTER, initial_offset, initial_offset + (TMJ.config.columns * TMJ.config.rows))
    for row = 1, TMJ.config.rows do
        for col = 1, TMJ.config.columns do
            local indice = (row-1) * TMJ.config.columns + col
            local center = centers[indice]
        end
    end
end