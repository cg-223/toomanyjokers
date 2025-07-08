if not next(SMODS.find_mod("banner")) then
    return
end

local function is_in_tmj(card)
    if G.TMJCOLLECTION then
        for i, v in pairs(G.TMJCOLLECTION) do
            if v == card.area then
                return true
            end
        end
    end
end

local oldCardClick = Card.click
function Card:click(...)
    local card = self
    if is_in_tmj(card) and not TMJ.FUNCS.isCtrlDown() and not TMJ.FUNCS.isShiftDown()  then
        --card is in tmj
        card:juice_up(0.3, 0.3)
        local key = card.config.center.key
        if BANNERMOD.is_disabled(key) then
            play_sound('generic1')
            if BANNERMOD.set_disabled(key, false) then
                card.debuff = false
            end
        else
            play_sound('cancel')
            if BANNERMOD.set_disabled(key, true) then
                card.debuff = true
                card.bannermod_no_debuff_tip = true
            end
        end
        BANNERMOD.save_disabled()
        BANNERMOD.update_disabled()
    end
    return oldCardClick(self, ...)
end

