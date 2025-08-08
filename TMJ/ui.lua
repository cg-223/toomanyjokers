function TMJ.FUNCS.ui_box()
    return UIBox {
        definition = { n = G.UIT.ROOT, config = { align = 'cm', r = 0.01 }, nodes = {
            UIBox_dyn_container(TMJ.FUNCS.inner_nodes()) } },
        config = { align = 'cli', offset = { x = -1, y = G.ROOM.T.h - 2.333 }, major = G.ROOM_ATTACH, bond = 'Weak' }
    }
end
