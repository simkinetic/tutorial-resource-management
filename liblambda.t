-- SPDX-FileCopyrightText: 2024 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2024 Torsten Keßler <t.kessler@posteo.de>
-- SPDX-FileCopyrightText: 2025 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2025 Torsten Keßler <t.kessler@posteo.de>
--
-- SPDX-License-Identifier: MIT

--lua function that generates a terra type that are function objects. these wrap
--a function in the 'apply' metamethod and store any captured variables in the struct
--as entries

--lambda_new_start
-- Helper function to validate the capture expression
-- Ensures the capture is a struct with named entries (e.g., {x = xvalue, y = yvalue})
local ckecklambdaexpr = function(expr)
    if not (expr.tree and expr.tree.type and expr.tree.type:isstruct()) then
        error("Not a valid capture. " ..
              "The capture syntax uses named arguments as follows: " ..
              "{x = xvalue, ...}.", 2)
    end
end

-- Factory function to create a lambda type from a function and capture object
-- Wraps the function in a struct, overloads __apply for invocation, and handles type info
local makelambda = function(fun, lambdaobj)
    -- Validate the capture object
    ckecklambdaexpr(lambdaobj)
    local lambdatype = lambdaobj:gettype()

    -- Overload the call operator (__apply) to make the struct callable
    -- Uses memoize to cache the returned expression; unpacks captured variables and applies the function
    lambdatype.metamethods.__apply = macro(terralib.memoize(function(self, ...)
        local args = terralib.newlist{...}
        return `fun([args], unpackstruct(self)) -- Apply fun with args and unpacked captures
    end))
    
    -- Infer and add return type/parameter info from the wrapped function if possible
    local funtype = fun:gettype()
    if funtype:ispointertofunction() then
        lambdatype.returntype = funtype.type.returntype
        local nargs = #funtype.type.parameters - #lambdatype.entries
        lambdatype.parameters = funtype.type.parameters:filteri(function(i,v) return i <= nargs end)
    end

    return lambdaobj
end 

-- Macro to create a new lambda: wraps fun with optional captures (defaults to empty struct)
local new = macro(function(fun, capture)
    local lambda = makelambda(fun, capture or quote var c : terralib.types.newstruct() in c end)
    return `lambda
end)

return {
    new = new
}
--lambda_new_end
