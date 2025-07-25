-- SPDX-FileCopyrightText: 2024 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2024 Torsten Keßler <t.kessler@posteo.de>
-- SPDX-FileCopyrightText: 2025 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2025 Torsten Keßler <t.kessler@posteo.de>
--
-- SPDX-License-Identifier: MIT

--poly_start
--`Polynomial` type templated by the element type `T`, equal to `float` or `double`, and the and the polynomial order `N`
--`terralib.memoize` caches the function output for each `(T, N)`, avoiding recompilation.
local Polynomial = terralib.memoize(function(T, N)

    --Check input
    assert(T == float or T == double, "CompileError: expected a 'float' or 'double' type.")
    assert(type(N) == "number" and N>0 and N%1==0, "CompileError: expected a positive integer.")

    --Define struct type. The coefficients are stored in an array of length N
    local struct poly{
        coeffs : T[N]
    }

    --Polynomial evaluation using Horner's method. Here the loop is unrolled at compile-time
    terra poly:eval(x : T)
        var y = self.coeffs[N-1] -- Start with the highest-degree coefficient
        escape -- Enter Lua metaprogramming mode to generate code at compile-time
            for i=N-2,0,-1 do -- Iterate over remaining coefficients in reverse order
                emit quote -- Emit explicit Terra statements for unrolling
                    y = x * y + self.coeffs[i] -- Nested multiply-add
                end
            end
        end
        return y
    end

    -- Convenience method enabling function-like evaluation of a 'poly' object (e.g., p(x))
    poly.metamethods.__apply = macro(function(self, x)
        return `self:eval(x) -- Macro expands to eval call at compile time
    end)

    return poly -- Return the templated struct type
end)
--poly_end

--tutorial_start
import "terratest"

testenv "Cubic polynomial with float element type" do

    local poly = Polynomial(float, 4)
    terracode
        var p = poly{arrayof(float,-1.,2.,-6.,2.)}
    end
    test p(3)==5

end
--tutorial_end