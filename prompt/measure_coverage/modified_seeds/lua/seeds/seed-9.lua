function vulnerableFunction()
    local a = 1
    local b = 2

    -- Trigger a debug call that may exploit the vulnerability
    local status, err = pcall(function()
        -- Assuming the environment hasn't been patched and is vulnerable,
        -- this call attempts to use an extremely large index to cause an integer overflow.
        -- 'debug.getlocal' is used to access a non-existing very high index local variable.
        local name, value = debug.getlocal(1, 2^31)
    end)

    if not status then
        print("An error occurred:", err)
    end
end

-- Call the potentially vulnerable function
vulnerableFunction()
