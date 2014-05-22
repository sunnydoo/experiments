-- This is test code of http://learnyouahaskell.com/chapters

-- Chapter 2: Starting out

-- :help
-- :set prompt "dudu> "

-- list is homogenerous, elements must be same type
-- ++ to concatenate 2 lists, but Haskell will walk through the whole first list, 
-- for [1,2,3] is syntax sugar of 1:2:3:[]. To add one element, prepend it at the 
-- beginning using : (cons operation).

-- "Steve Buscemi" !! 6   -- Index of list
-- 'B'  

-- 1. function has params and will return one value
add x y z = x+y+z

-- 2. list comprehension
-- the part before pipe is called "Output function"
-- content of [] is called "Input Set"
-- a^2 + b^2 == c^2 is "Predicate" 
triangle = [(a,b,c) | a <- [1..10], b<-[1..10], c<-[1..10], a^2 + b^2 == c^2]
 
 
-- 3. concatenate list
nouns = ["baby", "girl", "star"]
adj = ["cute", "lovely", "weird"]
constr = nouns ++ adj
 
-- 4. methods to handle lists
-- head tail(excludes head) last init(excludes last) length null(return bool) 
-- reverse take drop maximum minimum sum product elem(return bool) cycle repeat

test_null = null adj
test_take_cycle = take 10 (cycle [1, 2, 3])

-- 5. tuples
index_nouns = zip [1..3]nouns
_fst_elem = head index_nouns
test_fst = fst _fst_elem

