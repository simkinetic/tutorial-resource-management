-- SPDX-FileCopyrightText: 2024 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2024 Torsten Keßler <t.kessler@posteo.de>
-- SPDX-FileCopyrightText: 2025 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2025 Torsten Keßler <t.kessler@posteo.de>
--
-- SPDX-License-Identifier: MIT


--`Polynomial` strcut type templated by the element type `T`, equal to `float` or `double`, and the
--polynomial order `N`
local Polynomial = terralib.memoize(function(T, N)

    --check input
    assert(T == float or T == double, "CompileError: expected a 'float' or 'double' type.")
    assert(type(N) == "number" and N>0 and N%1==0, "CompileError: expected a positive integer.")

    --define struct type
    local struct poly{
        coeffs : T[N]
    }

    --polyeval_start
    -- Intrinsic for fused-multiply-add (axpy form: x*y + z)
    local axpy = terralib.intrinsic(T == float and "llvm.fma.f32" or "llvm.fma.f64", {T, T, T} -> T)

    --Polynomial evaluation using Horner's method. Here the loop is unrolled at compile-time
    terra poly:eval(x : T)
        var y = self.coeffs[N-1] -- Start with highest coefficient
        escape
            for i=N-2,0,-1 do
                emit quote
                    y = axpy(x, y, self.coeffs[i]) -- Fused: x * y + coeffs[i]
                end
            end
        end
        return y
    end
    --polyeval_end

    --convenience method enabling function-like evaluation of a 'poly' object
    poly.metamethods.__apply = macro(function(self, x)
        return `self:eval(x)
    end)

    return poly
end)

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


--typedef fused-multiply-add function from math.h library
--local axpy = macro(function(a,x,b) return `a*x+b end)
--local axpy = terralib.intrinsic(T == float and "llvm.fma.f32" or "llvm.fma.f64", {T, T, T} -> T)
