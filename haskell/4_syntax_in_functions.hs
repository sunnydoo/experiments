--Chapter 4 Syntax in Functions

--1. note it's Integral (typeclass) instead of Int or Integer, type


test_factorial :: (Integral a) => a -> a
test_factorial 0 = 1
test_factorial n = n * test_factorial( n - 1 )

test_length :: (Integral b) => [a] -> b -- or test_length :: [a] -> Int 
test_length [] = 0   -- edge condition
-- : (cons operator) always divide the head and the rest
test_length (_:xs) = 1 + test_length xs --don't care, use _ to match anything

--match the whole string
test_capital :: String -> String
test_capital "" = "Empty String"
test_capital all@(x:xs) = "The first letter of " ++ all ++ " is " ++ [x]

--2. Guards ( a big if else tree, could be inline )

-- defaine a infix function
test_cmp :: (Ord a) => a -> a -> Ordering
a `test_cmp` b | a > b = GT | a == b = EQ | otherwise = LT
    
bmiTell :: (RealFloat a) => a -> a -> String  
bmiTell weight height  
    | bmi <= skinny = "You're underweight, you emo, you!"  
    | bmi <= normal = "You're supposedly normal. Pffft, I bet you're ugly!"  
    | bmi <= fat    = "You're fat! Lose some weight, fatty!"  
    | otherwise     = "You're a whale, congratulations!"  
    where bmi = weight / height ^ 2  
          skinny = 18.5   -- these names must be with same indention
          normal = 25.0   -- 
          fat = 30.0  

-- where could be used in 'list comprehension'

-- 3. let in:  assign values after let, return values after in
test_ifelse = 4 * (if 10 > 5 then 10 else 0) + 2 
test_letin =  4 * ( let a = 9 in a + 1 ) + 2
test_letin2 = (let a = 100; b = 200; c = 300 in a*b*c, let foo="Hey "; bar = "there!" in foo ++ bar)  

-- 4. case
-------------------------------------------------
--case expression of pattern -> result  
--                   pattern -> result  
--                   pattern -> result  
-------------------------------------------------                   

-- Pattern match is a syntax sugar of case
-- compare with above test_length
test_length2 :: (Integral b) => [a] -> b 
test_length2 xs = case xs of [] -> 0  -- again, like in where clause, same indention
                             (_:xs) -> 1 + test_length2 xs 
                             

-- syntax sugar
test_case :: [a] -> String  
test_case xs = "The list is " ++ case xs of [] -> "empty."  
                                            [x] -> "a singleton list."   
                                            otherwise -> "a longer list."

test_pattern_match :: [a] -> String  
test_pattern_match xs = "The list is " ++ what xs  
    where what [] = "empty."  
          what [x] = "a singleton list."  
          what xs = "a longer list."  

          
-- both guards and case have 'otherwise'
-- case (including pattern match) and guards both judge input parameters.
-- pattern match is more flexible for it could handle mutiple input parameters, but case
-- can only handle one.