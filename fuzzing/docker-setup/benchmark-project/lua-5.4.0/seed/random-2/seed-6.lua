-- A theoretical demonstration of how CVE-2020-24370 might be triggered
-- DISCLAIMER: This is for educational purposes only.

function vulnerableFunction()
  local a = 1
  -- Presuming 'n' is the problematic parameter
  -- a real exploitation might attempt to call 'getlocal' with a large negative index,
  -- potentially leading to negation overflow.
  -- This illustrative function call here is commented out to prevent misuse:
  -- debug.getlocal(1, -2147483648) -- Hypothetical call simulating the overflow scenario
end

-- To safely study or mitigate such vulnerabilities, work within controlled environments
-- and always adhere to legal and ethical guidelines.
