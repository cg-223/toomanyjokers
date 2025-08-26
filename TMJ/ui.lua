function TMJ.FUNCS.ui_box()
    local def = TMJ.FUNCS.inner_nodes()
    return UIBox {
        definition = { n = G.UIT.ROOT, config = { align = 'cm', r = 0.01 }, nodes = {
            UIBox_dyn_container(def) } },
        config = { align = 'cli', offset = { x = -1, y = G.ROOM.T.h - 2.333 }, major = G.ROOM_ATTACH, bond = 'Weak' }
    }
end

G.ENTERED_FILTER = ""
TMJ.thegreatfilter = ""
function TMJ.FUNCS.inner_nodes()
    local text = create_text_input({
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
            TMJ.thegreatfilter = G.ENTERED_FILTER
            G.ENTERED_FILTER = ""
            TMJ.scrolled_amount = 0
            TMJ.FUNCS.reload()
        end
    })
    text.config.id = "TMJTEXTINP"
    return {
        {
            n = G.UIT.R,
            config = { minw = G.ROOM.T.w * 0.25, padding = 0.05, align = "cm" },
            nodes = {
                { n = G.UIT.T, config = { text = "Start typing to focus searchbar...", colour = G.C.WHITE, scale = 0.35 } },
            }
        },
        { n = G.UIT.R, config = { align = "cm", r = 0.01, colour = G.C.BLACK, emboss = 0.05 }, nodes = { { n = G.UIT.C, nodes = TMJ.FUNCS.make_card_areas() } } }, --cardareas
        {
            n = G.UIT.R,
            config = { align = "cm" },
            nodes = {
                text
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
    local card_scale = 1 / TMJ.config.size
    local areas = {}
    for i = 1, num_areas do
        local area = CardArea(                                                                   --insert this cardarea into the table we feed to our ui
            0, 0,                                                                                --position
            card_limit * G.CARD_W / card_scale,                                                  --width of cardarea
            0.95 * G.CARD_H / card_scale,                                                        --height of cardarea
            { card_limit = card_limit, type = 'title', highlight_limit = 0, collection = true }) --basic config for a cardarea
        area.config.tmj = true
        G.TMJCOLLECTION[i] = area
        table.insert(areas, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.07 / card_scale, no_fill = true, scale = 1 / card_scale },
            nodes = { { n = G.UIT.O, config = { object = area } } }
        })
    end
    return areas
end

TMJ.scrolled_amount = 0
function TMJ.FUNCS.make_cards()
    local size_div = 1 / TMJ.config.size
    local initial_offset = TMJ.config.columns * TMJ.scrolled_amount
    local centers = TMJ.FUNCS.get_centers(TMJ.thegreatfilter, initial_offset, TMJ.config.columns * TMJ.config.rows)
    for row = 1, TMJ.config.rows do
        for col = 1, TMJ.config.columns do
            local indice = (row - 1) * TMJ.config.columns + col
            local key = centers[indice]
            local center = G.P_CENTERS[key]
            if center and center.key then
                local old = copy_table(G.GAME.used_jokers)
                local card = Card(G.TMJCOLLECTION[row].T.x + G.TMJCOLLECTION[row].T.w / 2, G.TMJCOLLECTION[row].T.y,
                    G.CARD_W / (size_div or 1),
                    G.CARD_H / (size_div or 1), nil, key)
                if TMJ.config.pinned_keys[key] then
                    SMODS.Stickers.tmj_pinned:apply(card, true)
                end
                if BANNERMOD and BANNERMOD.is_disabled(key) then
                    card.debuff = true
                end
                card.sticker = get_joker_win_sticker(key)
                G.TMJCOLLECTION[row]:emplace(card)
                if string.sub(key, 1, 1) == "e" then
                    if not card.edition then card.edition = {} end
                    card.edition[string.sub(key, 3)] = true
                end
                G.GAME.used_jokers = old
            end
        end
    end
end

function TMJ.FUNCS.scroll(y)
    local prev_amt = TMJ.scrolled_amount
    if TMJ.scrolled_amount + y >= 0 then
        TMJ.scrolled_amount = TMJ.scrolled_amount + y
        TMJ.FUNCS.reload()
    else
        TMJ.scrolled_amount = 0
        if prev_amt > 0 then
            TMJ.FUNCS.reload()
        end
    end
end

function TMJ.FUNCS.reload()
    if G.TMJUI then
        G.TMJUI:remove()
        G.TMJTAGS:remove()
    end
    G.TMJUI = TMJ.FUNCS.ui_box()
    TMJ.FUNCS.make_cards()
    G.TMJUI:recalculate()
    TMJ.FUNCS.make_tag_stuff()
end

local old = Card.click
function Card:click(...)
    if self.area and self.area.config.tmj and G.CONTROLLER.held_keys['lctrl'] then
        TMJ.config.pinned_keys[self.config.center.key] = not TMJ.config.pinned_keys[self.config.center.key]
        TMJ.FUNCS.process_centers()
        TMJ.FUNCS.reload()
        SMODS.save_mod_config(TMJ)
    end
    old(self, ...)
end

function TMJ.FUNCS.make_tag_stuff()
    local major = assert(G.TMJUI)
    local uib = UIBox {
        definition = { n = G.UIT.ROOT, config = { align = 'cm', r = 0.01 }, nodes = {
            UIBox_dyn_container(TMJ.FUNCS.inner_tags()) } },
        config = { align = 'cr', offset = { x = 0, y = 0 }, major = major, bond = 'Weak' }
    }
    G.TMJTAGS = uib
end

function TMJ.FUNCS.inner_tags()
    local tags = {}
    local mods = TMJ.FUNCS.get_valid_mods()
    local max_rows = 12
    local num_cols = math.ceil(#mods/max_rows)
    for i = 0, math.ceil(#mods/num_cols) do
        local cur_mods = {}
        for j = 1, num_cols do
            cur_mods[#cur_mods+1] = mods[i*num_cols+j] --lea ?!?!??!
        end
        local tags_nodes = {}
        for _, v in ipairs(cur_mods) do
            tags_nodes[#tags_nodes+1] = TMJ.FUNCS.buildModtag(v)
        end
        tags[#tags+1] = {n = G.UIT.R, nodes = tags_nodes}
    end


    return {{
        n = G.UIT.C,
        nodes = tags
    }}
end

function TMJ.FUNCS.get_valid_mods()
    if TMJ.MODCACHE then return TMJ.MODCACHE end
    local ret = {}
    local has_centers = {}
    for _, v in pairs(G.P_CENTERS) do
        if v.original_mod and v.original_mod.id then
            has_centers[v.original_mod.id] = true
        end
    end
    for i, v in pairs(SMODS.Mods) do
        if v.can_load and has_centers[v.id] then
            table.insert(ret, v)
        end
    end


    TMJ.MODCACHE = ret
    return ret
end



function TMJ.FUNCS.getModtagInfo(mod)
    local tag_pos, tag_message, tag_atlas = { x = 0, y = 0 }, "tmj_this_mods_cards", mod.prefix and mod.prefix .. '_modicon' or 'modicon'
    local specific_vars = {mod.name}

    return tag_atlas, tag_pos, tag_message, specific_vars
end

function TMJ.FUNCS.buildModtag(mod)
    local tag_atlas, tag_pos, tag_message, specific_vars = TMJ.FUNCS.getModtagInfo(mod)

    local tag_sprite_tab = nil
    local units = SMODS.pixels_to_unit(34) * 2
    local animated = G.ANIMATION_ATLAS[tag_atlas] or nil
    local tag_sprite
    if animated then
      tag_sprite = AnimatedSprite(0, 0, 0.8*1, 0.8*1, animated or G.ASSET_ATLAS[tag_atlas] or G.ASSET_ATLAS['tags'], tag_pos)
    else
      tag_sprite = Sprite(0, 0, 0.8*1, 0.8*1, G.ASSET_ATLAS[tag_atlas] or G.ASSET_ATLAS['tags'], tag_pos)
    end
    tag_sprite.T.scale = 1
    tag_sprite_tab = {n= G.UIT.C, config={align = "cm", padding = 0}, nodes={
        {n=G.UIT.O, config={w=units, h=units, colour = G.C.BLUE, object = tag_sprite, focus_with_object = true}},
    }}
    tag_sprite:define_draw_steps({
        {shader = 'dissolve', shadow_height = 0.05},
        {shader = 'dissolve'},
    })
    tag_sprite.float = true
    tag_sprite.states.hover.can = true
    tag_sprite.states.click.can = true
    tag_sprite.states.drag.can = false
    tag_sprite.states.collide.can = true

    tag_sprite.hover = function(_self)
        if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then 
            if not _self.hovering and _self.states.visible then
                _self.hovering = true
                if _self == tag_sprite then
                    _self.hover_tilt = 3
                    _self:juice_up(0.05, 0.02)
                    play_sound('paper1', math.random()*0.1 + 0.55, 0.42)
                    play_sound('tarot2', math.random()*0.1 + 0.55, 0.09)
                end
                tag_sprite.ability_UIBox_table = generate_card_ui({set = "Other", discovered = false, key = tag_message}, nil, specific_vars, 'Other', nil, false)
                _self.config.h_popup =  G.UIDEF.card_h_popup(_self)
                _self.config.h_popup_config ={align = 'bm', offset = {x= 0,y=0.3},parent = _self}
                Node.hover(_self)
                if _self.children.alert then 
                    _self.children.alert:remove()
                    _self.children.alert = nil
                    G:save_progress()
                end
            end
        end
    end
    tag_sprite.click = function(self)
        play_sound('button', 1, 0.3)
        G.ROOM.jiggle = G.ROOM.jiggle + 0.5
        TMJ.thegreatfilter = "mod:"..mod.name
        G.ENTERED_FILTER = ""
        TMJ.scrolled_amount = 0
        TMJ.FUNCS.reload()
    end
    tag_sprite.stop_hover = function(_self) _self.hovering = false; Node.stop_hover(_self); _self.hover_tilt = 0 end


    return tag_sprite_tab
end
