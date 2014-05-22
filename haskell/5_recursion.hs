--Chapter 5. Recursion

-- In Haskell, you define what something is instead of how you get it like
-- in Imperative Language, so no while/for loops.

-- 1. edge condition, like in Fibonacci, F(0) = 0 and F(1) = 1
-- which cause recursive function to terminate

-- 2. case (pattern match) + guards
test_maxim :: (Ord a) => [a] -> a
test_maxim [] = error "No maxim of empty list"
test_maxim [x] = x
test_maxim (x:xs)
    | x > maxTail = x
    | otherwise = maxTail
    where maxTail = test_maxim xs

-- 3. guards
test_replica :: (Integral b) => a -> b -> [a]
test_replica x n
    | n <= 0 = []
    | otherwise = x : test_replica x (n-1)

-- case doesn't work here, for it's awkward to handle multiple input
-- parameters, but its syntatic sugar is playing well.
-- 4. Pattern Match + Guard
test_take :: (Ord i, Num i) => i -> [a] -> [a]
test_take n _ 
    | n <= 0 = []
test_take n [] = []
test_take n (x:xs) = x: test_take (n-1) xs

-- 5. ++ and : both concatenate a list, ++ is used at tail

test_reverse :: [a] -> [a]
test_reverse [] = []
test_reverse (x:xs) = test_reverse xs ++ [x] -- another way of :x

-- 6. test_zip
test_zip :: [a] -> [b] -> [(a,b)]
test_zip _ [] = []
test_zip [] _ = []
test_zip (x:xs) (y:ys) = (x,y) : test_zip xs ys

-- 7. test_elem
-- we could call any functions in its infix form
-- a `test_xxx` xs
test_elem :: (Eq a) => a -> [a] -> Bool
test_elem _ [] = False
test_elem a (x:xs)
    | a == x = True
    | otherwise = test_elem a xs
    
-- 8. test_qsort
test_qsort :: (Ord a) => [a] -> [a]
test_qsort [] = []
test_qsort (x:xs) = 
    let smaller = test_qsort [a | a <- xs, a <= x]
        bigger  = test_qsort [a | a <- xs, a > x]
    in smaller ++ [x] ++ bigger