function vulnerableFunction()
    local a = 1
    debug.sethook(function()
        local name, val = debug.getlocal(2, -2147483648) -- Using a large negative value aiming for negation overflow
    end, "c")
    -- Trigger the custom debug hook function
end

vulnerableFunction()
