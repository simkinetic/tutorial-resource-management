-- SPDX-FileCopyrightText: 2024 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2024 Torsten Keßler <t.kessler@posteo.de>
-- SPDX-FileCopyrightText: 2025 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2025 Torsten Keßler <t.kessler@posteo.de>
--
-- SPDX-License-Identifier: MIT

--tutorial_poly_start
local poly = require("libpoly")

import "terratest"

testenv "Static polynomial" do

    local polynomial = poly.Polynomial(double, 4)
    
    testset "eval" do
        terracode
            var p = polynomial{array(-1.,2.,-6.,2.)}
        end
        test p(3)==5
    end

end
--tutorial_poly_end