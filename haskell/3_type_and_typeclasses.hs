--Chapter 3: Type and Typeclasses

--Haskell has a static type, :t command print out type. :: is read as 'has type of'
--Type are in Capital case

-- "Hello" :: [Char]
-- (True, 'a') :: (Bool, Char)
-- 4 == 5 :: Bool
-- addThree :: Int -> Int -> Int -> Int (3 input params and the last is return value)

-- 1. as of Type inference, this is not necessary.
removeLower :: [Char] -> [Char]
removeLower st = [ c | c <- st, c `elem` ['A'..'Z']] -- ` instead of single quote.

-- 2. common types
-- Int (bounded), Integer(unlimited), Float(single precision), Double(double precision)
-- Bool, Char

-- 3. Type variables
-- fst:: (a,b)->a  -- a is 'type variable', fst is 'polymorphic function'.
-- a, b could have same type.

-- 4. ==, +, - , etc are infix functions, :t (==) will print its type.
--    elem is an infix function too, so `` are needed, I guess.


-- 5. => is called 'class constraint'.
-- (==) :: (Eq a) => a -> a -> Bool
-- typeclass is like an interface which a type implemented, it gives constraint to the type.

-- 6. Typeclasses
-- Eq Ord Show(show) Read(read) Enum(succ, pred) 
-- Bounded(minBound, maxBound) minBound::Int is a function containing 0 input and 1 output with explicit type
-- Num ( Integral, Floating )
-- Integral ( Int, Integer)
-- Floating ( Float, Double)

test_fromIntegral = fromIntegral (length [1,2,3,4]) + 3.2


