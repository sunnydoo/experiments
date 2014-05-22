-- chapter 9 Input and Output
import Data.Char
import System.IO

-- 1. IO Action method is tainted, and functions depending on tainted data is also tainted.
-- so you should not use str = "abc" ++ getLine().

-- v1
-- main = putStrLn "Hello World"


-- IO actions must be in main funciton.
-- a few of IO actions can be put in a do block, which in turn can 
-- be put in a higher do block, but eventually it will be put in main.

-- v2 -- main always has a signature of IO something
-- main = do
    -- foo <- putStrLn "Hello, what's up" -- just ()
    -- name <- getLine -- perform an IO action and bind its result to name (a variable, FP doesn't change state of varibale)
    -- let upperName = map toUpper name -- In addition to IO Action, we can use let to do bindings.
    -- putStrLn ("Hey " ++ upperName ++ " Welcome") -- in do block, the last action can't bind to anyting, check Monad


-- v3
-- main = do 
    -- line <- getLine
    -- if null line then 
        -- return () -- return is oppsite of <-, wrap a value and send it to IO Action.
    -- else do  -- if then else do, indention doesn't matter.
        -- putStrLn $ reverseWords line -- statements in do block does!!
        -- main
            
-- reverseWords :: [a] -> [a]
-- reverseWords [] = []
-- reverseWords (x:xs) = (reverseWords xs) ++ [x] 
-- --reverseWords x:xs = reverseWords xs ++ [x] wrong, space has highest precedence.

-- 2. Files and Streams.
-- getContents is lazy, and can be used in unix pipe. and it's like a 'forever' used here.
-- with this lazy function, the whole program doesn't quit until we stop it via CTRL+D. 
-- Haskell is built on lazy algorithm. when putStr is executed, it ask cotents to hand it a line
-- where there isn't, as the getContents is lazy, it will halt and wait for a string.

-- v4
-- main = do
    -- contents <- getContents
    -- putStr $ map toUpper contents

-- similarly, below line do the same thing.
-- main = interact $ unlines . filter ((<10) . length) . lines 

-- v5
-- we could set the buffer mode of the handle
-- NoBuffering, LineBuffering or BlockBuffering (Maybe Int).
-- main = do 
    -- handle <- openFile "testFile.txt" ReadMode
    -- contents <- hGetContents handle
    -- putStr contents
    -- hClose handle
    
-- return item of index number: todoTasks !! number
    
-- v6
-- readFile writeFile appendFile, handy tools without mode
-- main = do
    -- contents <- readFile "testFile.txt"
    -- writeFile "testFileCaps.txt" $ map toUpper contents
    
-- 3. Command line arguments
-- import System.Environment
-- getArgs  getProgName

-- check the example in textbook, so long... ignore it this time.


-- 4. Randomness

-- skipped it as the library reference is difficult and I don't care it so much for now.

-- 5. Byte String
-- when handling big files, list is inefficient for its laziness.