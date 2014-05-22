--10 Functionally Solving Problem

import Data.List

-- 1. RPN problem, input::String, like "10 4 3 + 2 * -"
-- output number
-- 思路：将字符串拆分成单个字符，放入一list。不能直接操作原字符串，因为有空格需要考虑，考虑使用words
-- 从左到右处理list，如果是数字放入新的list (a stack), 如果是操作符，则把stack中的数据取出，计算，然
-- 后再压入这个stack。

-- 神奇的foldl，它接受一个函数，该函数第一个参数是个临时值，保存中间变量，第二个参数是操作的list的一
-- 个element。
-- foldl is amazing, it consume a list and creates anything.

solveRPN :: (Num a, Read a) => String -> a
solveRPN = head . foldl foldingFunction [] . words
    where
    foldingFunction (x:y:ys) "*" = (x * y):ys
    foldingFunction (x:y:ys) "-" = (y - x):ys
    foldingFunction (x:y:ys) "+" = (x + y):ys
    foldingFunction xs numStr = read numStr : xs


-- 2. shortest path
-- 从甲到乙有两条路A,B。A和B有多条岔路相连，求从甲到乙的最短路径，可以选择走A,B及它们之间的岔路。
-- 思路：定A,B之间的第一条岔路是A1，B2，第二条岔路是A2，B2，以此类推.. 
-- 先求出从甲到A1,B1的最短路径，在已知A1,B1的最短路径的情况下，求出从甲到A2，B2的最短路径，然后根据
-- A2，B2求出从甲到A3，B3的最短路径，依次类推，求出从甲到终点的最短路径。

data Section = Section { a :: Int, b :: Int, c :: Int} deriving (Show)
type RoadSystem = [Section]

-- Value constructor:  start with lower case.
-- Data constructor: start with upper case.  enforced by compiler.

airPort2London :: RoadSystem
airPort2London = [Section 50 10 30, Section 5 90 20, Section 40 2 25, Section 10 8 0]

data Label = A | B | C deriving (Show)
type Path = [(Label, Int)]

-- Take case of Tabs and Spaces, when indention is taken account into syntax.
roadStep :: (Path, Path) -> Section -> (Path, Path)
roadStep (pathA, pathB) (Section a b c) =
    let priceA = sum $ map snd pathA
        priceB = sum $ map snd pathB
        a2a = priceA + a
        a2b = priceA + a + c
        b2b = priceB + b
        b2a = priceB + b + c
        newPathA = if a2a <= b2a then (A,a):pathA else (C,c):(B,b):pathB
        newPathB = if b2b <= a2b then (B,b):pathB else (C,c):(A,a):pathA
    in (newPathA, newPathB)	
    

optimalPath :: RoadSystem -> Path
optimalPath roadSystem = 
    let (bestA, bestB) = foldl roadStep ([],[]) roadSystem
    in if sum (map snd bestA) <= sum ( map snd bestB )
       then reverse bestA
       else reverse bestB       

