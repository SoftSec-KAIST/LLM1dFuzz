function vulnerable_func(...)
    -- Attempt to trigger negation overflow in getlocal
    local status, err = pcall(function() debug.getlocal(1, 2^31) end)
    if not status then
        print("Error caught: " .. err)
    end

    -- The same might be attempted with setlocal, although it needs precise manipulation of the stack
    -- and knowing what value to expect at a certain stack position, which is more complex and context-specific.
end

-- Calling the function with any argument, the actual trigger is on the debug.getlocal call inside the function.
vulnerable_func(1)
