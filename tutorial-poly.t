-- SPDX-FileCopyrightText: 2024 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2024 Torsten Keßler <t.kessler@posteo.de>
-- SPDX-FileCopyrightText: 2025 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2025 Torsten Keßler <t.kessler@posteo.de>
--
-- SPDX-License-Identifier: MIT

--poly_start
--import 'math.h' library functions needed for fused-multiply-add
--used in polynomial evaluation
local C = terralib.includec("math.h")

--`Polynomial` strcut type templated by the element type `T`, equal to `float` or `double`, and the
--polynomial order `N`
local Polynomial = terralib.memoize(function(T, N)

    --check input
    assert(T == float or T == double, "CompileError: expected a 'float' or 'double' type.")
    assert(type(N) == "number" and N>0 and N%1==0, "CompileError: expected a positive integer.")

    --typedef fused-multiply-add function from math.h library
    local fusedmuladd = T == float and C.fmaf or C.fma

    --define struct
    local struct poly{
        coeffs : T[N]
    }

    --polynomial evaluation using Horner's method. Note the loop-unrolling
    terra poly:eval(x : T)
        var y = self.coeffs[N-1]
        escape
            for i=N-2,0,-1 do
                emit quote
                    y = fusedmuladd(x, y, self.coeffs[i])
                end
            end
        end
        return y
    end

    --convenience method enabling function-like evaluation of a 'poly' object
    poly.metamethods.__apply = macro(function(self, x)
        return `self:eval(x)
    end)

    return poly
end)
--poly_end

--tutorial_start
import "terratest"

testenv "Static polynomial" do

    for _,T in pairs{float,double} do

        local poly = Polynomial(T, 4)

        testset(T) "polynomial evaluation using Horner's method" do
            terracode
                var p = poly{arrayof(T,-1.,2.,-6.,2.)}
            end
            test p(3)==5
        end

    end

end
--tutorial_end