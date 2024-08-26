function vulnerable_function(...)
    local index = -2147483648 -- A large negative number, potential for negation overflow
    local status, value = pcall(debug.getlocal, 2, index)
    if status then
        print("Accessed vararg at index", index, "value:", value)
    else
        print("Error accessing vararg:", value)
    end
end

-- Simulate a function call with varargs
vulnerable_function("This", "might", "trigger", "the", "vulnerability")
