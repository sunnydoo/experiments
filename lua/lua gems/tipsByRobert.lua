-- Maxims:
-- Don't do it
-- Don't do it yet

-- 1. virtual machine.
--
-- Lua precompile lua code to internal format, similar to real 'machine code' for virtual machine
-- which is then interpreted by C code. a while loop and a big switch, one case for an instruction.


-- 2. use locals.
-- 
-- Lua从5.0开始，使用基于register的virtual machine; 这个寄存器是在virtual machine级别的，与CPU的
-- register不同，这是因为cpu registers太少，同时使用cpu的register不利于移植。每个函数最多可使用250个
-- registers, 所有的local变量都保存在register中，所以，performance第一准侧，使用local变量

-- for i = 1, 1000000 do
    -- local x = math.sin(i)
-- end

-- 30% slower than

-- local sin = math.sin
-- for i = 1, 1000000 do
    -- local x = sin(i)
-- end


-- 3. compilation is a heavy task (loadstring)

-- Robert的例子，使用loadstring的例子1.4s; 不适用loadstring, 使用runtime构造的函数，0.14s, 差10倍。


-- 4. Tables use two parts: array part and hash part (很多trick)

-- 4.1 array 部分使用1 ~ n 作为index，超过n的使用hash解决。

-- 4.2 table刚被分配时，系统不会分配内存， 当向表中插入新的数据时，表的大小不能容纳新元素插入，
-- 触发rehash,才开始分配内存。若key为integrer时，则array part 
-- 扩大为2的倍数个slots,即1个，2^0,以后若需要,表继续增长为2,4,8,16...个slots等。hash部分同理，但它们
-- 是独立增长的。如果有很多小表，则rehash的overhead还是挺大的。解决办法就是，在c语言中，lua_createtable
-- 指定array part 和 hash part的大小； lua 端可在构造表时初始化表。

-- -- 未初始化，2s
-- for i = 1, 1000000 do
    -- local a = {}
    -- a[1] = 1; a[2] = 2; a[3] = 3
-- end

-- -- 初始化 0.7s
-- for i = 1, 1000000 do
    -- local a= {true, true, true}
    -- a[1] = 1; a[2] = 2; a[3] = 3
    -- -- a = {[1]=1, [2]=2, [3]=3} 不好，会作为hash处理，浪费CPU和内存，分配4个slots.
-- end

-- 4.3 rehash只有在insert时才会触发，也就是说，如果把一个大表中的很多元素删除(设为nil)，此时，表不会
-- rehash, 所以表的尺寸不会shrink, 只有等下一次 insert 时，才会rehash，从而使表shrink.


-- 5. string

-- 5.1 stings在lua中都做了internalized，即内部有一份拷贝，当要创建一个新string时，lua先检查这个string是
-- 否已经存在，不存在才创建它；存在则直接使用它。这使得string创建很慢，比较和查找很快。

-- 5.2 所有变量只保存string的reference，这与perl不同，在perl中，$x = $y时，会将y buffer拷贝到x buffer中。
-- 而在lua中，只拷贝一个指针。

-- 5.3 麻烦的是string concatenation. 以perl为例，perl中$x = $x . "abc" 与 $x .= "abc"是不同的。前者会将$x
-- buffer 拷贝， 添加’abc‘， 然后赋值给$x; 而后者直接在$x buffer 后面添加 'abc'。 区别是，读取一个5M的
-- buffer, 前者要5分钟，后者 0.1s， lua没有buffer的概念，故在循环中少用 x .. y， 而是 

-- local t = {}
-- for line in io.lines() do
-- t[#t + 1] = line
-- end
-- s = table.concat(t, "\n")

-- 读5M只需要0.28s，赶不上perl，不过也相当不错了。

-- 6 3R Reduce, Reuse, Recycle

-- 6.1 Reduce 可能的话，少使用table
-- one million points:  95KB
polyline = { { x = 10.3, y = 98.5 },
{ x = 10.3, y = 18.3 },
{ x = 15.0, y = 98.5 },
...
}

-- one million points： 65KB
polyline = { { 10.3, 98.5 },
             { 10.3, 18.3 },
             { 15.0, 98.5 },
...
}

-- one million points： 24KB
polyline = { x = { 10.3, 10.3, 15.0, ...},
             y = { 98.5, 18.3, 98.5, ...}
}

-- 6.2 Reduce 检查循环。把table，函数(closure)移到循环外, 普通的技术，但很有效。

-- 6.3 Reuse 重用表，改变表中的值，避免创建新表。

-- local t = {}
-- for i = 1970, 2000 do
--      t[i] = os.time({year = i, month = 6, day = 14})
-- end

-- 把临时表的创建提出来，重用，如果thread pool中的thread 重用，省去了table的构造等的开销。
-- local t = {}
-- local aux = {year = nil, month = 6, day = 14}
-- for i = 1970, 2000 do
--      aux.year = i   -- 只该表表的内容
--      t[i] = os.time(aux)
-- end

-- 6.4 Reuse 使用高阶函数做memorizing, 即给定输入值，记住输出值，各种cache的原理。

-- function memoize (f)
    -- local mem = {} -- memoizing table
    -- setmetatable(mem, {__mode = "kv"}) -- make it weak
    -- return function (x) -- new version of ’f’, with memoizing
        -- local r = mem[x]
        -- if r == nil then -- no previous result?
            -- r = f(x) -- calls original function
            -- mem[x] = r -- store result for reuse
        -- end
        -- return r
    -- end
-- end
 
-- loadstring = memorize(loadstring)  -- 真的是很有意思！！！

-- 6.5 Recycle 控制 gc ， gc 的两个参数带来的后果未知，根据实际情况而定。第一个参数pause说，一次gc后，等多久
-- 做第二次；第二个参数stepmul说，在一次gc中的速度(step multiplier)