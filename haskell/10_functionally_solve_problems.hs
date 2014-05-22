--10 Functionally Solving Problem

import Data.List

-- 1. RPN problem, input::String, like "10 4 3 + 2 * -"
-- output number
-- ˼·�����ַ�����ֳɵ����ַ�������һlist������ֱ�Ӳ���ԭ�ַ�������Ϊ�пո���Ҫ���ǣ�����ʹ��words
-- �����Ҵ���list����������ַ����µ�list (a stack), ����ǲ����������stack�е�����ȡ�������㣬Ȼ
-- ����ѹ�����stack��

-- �����foldl��������һ���������ú�����һ�������Ǹ���ʱֵ�������м�������ڶ��������ǲ�����list��һ
-- ��element��
-- foldl is amazing, it consume a list and creates anything.

solveRPN :: (Num a, Read a) => String -> a
solveRPN = head . foldl foldingFunction [] . words
    where
    foldingFunction (x:y:ys) "*" = (x * y):ys
    foldingFunction (x:y:ys) "-" = (y - x):ys
    foldingFunction (x:y:ys) "+" = (x + y):ys
    foldingFunction xs numStr = read numStr : xs


-- 2. shortest path
-- �Ӽ׵���������·A,B��A��B�ж�����·��������Ӽ׵��ҵ����·��������ѡ����A,B������֮��Ĳ�·��
-- ˼·����A,B֮��ĵ�һ����·��A1��B2���ڶ�����·��A2��B2���Դ�����.. 
-- ������Ӽ׵�A1,B1�����·��������֪A1,B1�����·��������£�����Ӽ׵�A2��B2�����·����Ȼ�����
-- A2��B2����Ӽ׵�A3��B3�����·�����������ƣ�����Ӽ׵��յ�����·����

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

