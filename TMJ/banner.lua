if not next(SMODS.find_mod("banner")) or not BANNERMOD then
    return
end
if false then
    BANNERMOD = {} --ls
end


local old_click = Card.click
function Card:click(...)
    local card = self
    if card.area and card.area.config.tmj and not G.CONTROLLER.held_keys.lctrl then
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
    return old_click(self, ...)
end