-- SPDX-FileCopyrightText: 2024 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2024 Torsten Keßler <t.kessler@posteo.de>
-- SPDX-FileCopyrightText: 2025 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2025 Torsten Keßler <t.kessler@posteo.de>
--
-- SPDX-License-Identifier: MIT

--tutorial_lambda_start
local lambda = require("liblambda")

terra example1(y : int)
    var p = lambda.new([terra(x : int, y : int) return 2*x + y end], {y = y})
    return p(3)
end
print("value returned by lambda is: " .. tostring(example1(2)))


terra add(a : double, b : double) : double return a + b end

terra example2(v : int)
    var captured = {value = 5.0}
    var p = lambda.new(add, captured)  -- Lambda capturing 'value' as first arg
    return p(v)
end
print("value returned by lambda is: " .. tostring(example2(3.0)))
--tutorial_lambda_end