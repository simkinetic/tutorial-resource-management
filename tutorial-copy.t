-- SPDX-FileCopyrightText: 2024 René Hiemstra <rrhiemstar@gmail.com>
-- SPDX-FileCopyrightText: 2024 Torsten Keßler <t.kessler@posteo.de>
--
-- SPDX-License-Identifier: MIT

-- tutorial_start
local utils = require("utils")
local lib = require("libtutorial")

local copyable = true
local Stack = lib.DynamicStack(int, copyable)
local Vector = lib.DynamicVector(int, copyable)
local VectorPair = lib.VectorPair(int, copyable)

terra main()
    -- create a stack and push some data
    var s = Stack.new(3)
    utils.printf("Adding three elements to 's'.\n")
    s:push(1)
    s:push(2)
    s:push(3)
    utils.printf("Adding two more elements to 's'.\n")
    s:push(4) --reallocating here
    s:push(5)

    -- copy contents of `s` into a Vector
    utils.printf("Copy 's' -> 'v'\n")
    utils.assert(s:size() == 5)
    var v : Vector = s
    utils.assert(s:size() == 5)
    utils.assert(v:size() == 5)

    -- create another stack and push some data
    var t = Stack.new(5)
    t:push(1)
    t:push(2)
    t:push(3)
    t:push(2)
    t:push(1)

    -- copy contents of `t` into a Vector
    utils.printf("Copy 't' -> 'w'\n")
    utils.assert(t:size() == 5)
    var w : Vector = t
    utils.assert(t:size() == 5)
    utils.assert(w:size() == 5)

    -- copy contents of vector v, w into the aggregate data-structure
    utils.printf("Copy '(v, w)' -> 'dual'\n")
    var dual = VectorPair.new(v, w)
    utils.assert(dual:size() == 5)
    utils.assert(v:size() == 5 and w:size() == 5)

    -- print contents of aggregate data type
    utils.printf("Contents of 'dual':\n")
    for i=0,5 do
        var x, y = dual(i)
        utils.printf("  dual(%d) = (%d, %d)\n", i, x, y)
    end 

end

main()
-- tutorial_end