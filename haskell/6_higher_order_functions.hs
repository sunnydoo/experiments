-- Chapter 6: Higher Order Functions

-- == Curried Functions: ==
-- In Haskell, every function takes one parameter. a function with more than 1 parameter is curried function.

-- == Function Application: ==
-- Putting a space between two things is called Function Application,
-- which means apply the function to

-- == Partially Applied: ==
-- Function is applied/used when some parameters are left out.
-- but the function body is not executed until it's full applied (all parameters are supplied)

-- infix function PA: put it into parentheses and supply a parameter on one side. 
-- (/10) (`elem` [1,2,3])

-- By calling function with too few parameters, we are creating functions on the fly.

-- Note:  -> is right associative.

-- 1. simple example
test_applyTwice :: ( a -> a ) -> a -> a
test_applyTwice f x = f (f x)

-- applyTwice (+3) 10 
-- applyTwice ("HAHA " ++) "HEY"  

-- 2. 3 parameters: the fst parameter is a function, with 2 input parameters and 1 output parameter.
-- the snd and trd are 2 lists

test_zipWith :: ( a -> b -> c ) -> [a] -> [b] -> [c]
test_zipWith _ [] _ = []
test_zipWith _ _ [] = []
test_zipWith f (x:xs) (y:ys) = f x y : test_zipWith f xs ys

-- test_zipWith max [6,3,2,1] [7,3,1,5]  

-- 3. Man!! I love Haskell, so neat, elegant and powerful!!
test_map :: ( a -> b ) -> [a] -> [b]
test_map _ [] = []
test_map f (x:xs) = f x : test_map f xs

test_filter :: ( a -> Bool ) -> [a] -> [a]
test_filter _ [] = []
test_filter f (x:xs)
	| f x = x : test_filter f xs  -- f x == True to f x
	| otherwise = test_filter f xs

-- implement Map and Filter in list comprehension
test_map2 :: ( a -> b ) -> [a] -> [b]
test_map2 f x = [ f k | k <- x ]

-- I love Haskell too much !!
test_filter2 :: (a -> Bool) -> [a] -> [a]
test_filter2 f x = [ k | k <-x , f k == True ]

-- 4. find the largest number divisible by 3267

-- Note how to define a function in 'where', it takes input params and return output
-- conforming to test_filter

test_divi :: (Integral a) => a
test_divi = head (test_filter p [10000, 9999..])
	where p x = x `mod` 3267 == 0

-- 5. Produce Collatz-sequence
chain :: ( Integral a) => a -> [a]
chain 1 = [1]
chain n 
	| odd n = n : chain( n * 3 + 1 )
	| otherwise = n : chain ( n `div` 2 ) -- n/2 is wrong, why?? 

-- length of chain is longer than 15
test_Collatz :: Int -- (Integral a) => a is wrong, for it's a value, instead of a function
test_Collatz = length [ x | x <- [1..100], length  (chain x) > 15 ]

-- another implement using 'filter' and 'map'. It is much friendly and comform to FP concepts.
test_Collatz2 :: Int
test_Collatz2 = length( filter isLong ( map chain [1..100] ))
		where isLong xs = length xs > 15


-- 6. lambda, lambda, lambda!!
--( \xa xb -> <body> ); () is not necessary, but without it, the body gets the whole line.
test_Collatz3 :: Int
test_Collatz3 = length( filter (\xs -> length xs > 15) ( map chain [1..100] ))


-- 7. fold and horse.. ( what does it mean? )
-- fold is a shortcut of a class of functions, which accumulate effects through a list
test_sum :: (Num a) => [a] -> a  

--test_sum xs = foldl (\acc x -> acc + x) 20 xs  
test_sum = foldl (+) 20  -- Partial Application (+) is same as the Lambda function

-- foldr, similar to foldl, (\x acc -> ... ), accumulater is the second parameter
test_reverse :: ( a -> b ) -> [a] -> [b]
test_reverse f xs = foldr (\x acc -> f x : acc ) [] xs -- foldr is a convenient way of foldl
--test_reverse f xs = foldl (\acc x -> acc ++ [f x] ) [] xs

--foldl1 and foldr1 use the first element as the start value
test_product = foldl1 (*)

-- scanl and scanr will print the intermediate values
--
----------------------------------------------------------
--
-- map filter fold 
-- are convenient tools for FP
--
----------------------------------------------------------

-- 8. $ namely 'function application', repace (), readable. also it make something a function
-- space has the highest precedence, left  associative
-- $     has the lowest  precedence, right associative
-- sum (map sqrt [1..130])  ==> sum $ map sqrt [1..130]

-- 9. Function Compostion
test_fcomp = map (negate . abs) [5,-3,-6,7,-3,2,-19,24]  

-- point free (pointless) style via curring
fn = ceiling . negate . tan . cos . max 50  

-- because function Compostion can only bear one parameter, for multiple 
-- parameters, use $ to separate the second and other ones, to make the formor
-- part into FC.

test_oddSquareSum :: Integer  
test_oddSquareSum = sum . takeWhile (<10000) . filter odd . map (^2) $ [1..] 


