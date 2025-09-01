if Handy and Handy.controller and Handy.controller.is_debugplus_console_opened then
    local old = Handy.controller.is_debugplus_console_opened
    function Handy.controller.is_debugplus_console_opened(...)
        if G.TMJUI then
            old(...)
            return true
        else
            return old(...)
        end
    end
end