-- chapters 11 Functors, Applicative Functors and Monoids

-- Functor: things that can be mapped over. e.g List, Number, etc

-- 1. Functors

-- 使用typeclass定义Type的时候， T是类型名，T a 是T类型的值变量 a， 故下面的定义可读为：
-- typeclass Functor定义为，满足Functor的Type必须支持fmap函数，fmap函数接受一个函数，并把
-- 一个T类型的值a转换为T类型的值b。
--
-- class Functor T where
--   fmap :: (a->b) -> T a -> T b

-- data 定义新的Type； class 定义新的Typeclass; instance 让某Type成为某typeclass的一员，实现
-- typeclass 要求的函数。

-- Functor typeclass 的特殊之处在于， 它的函数 fmap 要求传入一个 函数 f 作为参数，这也就决定了fmap
-- 将指定使用f的策略，而f本身却是用户自定义的。这样就定义了更高一级的抽象。

-- instance Functor Tree where
    -- fmap f EmptyTree = EmptyTree
    -- fmap f (Node x leftsub rightsub) = Node (f x) (fmap f leftsub) (fmap f rightsub)
    
-- 2. IO
-- Definition
-- instance Functor IO where
    -- fmap f action = do
        -- result <- action
        -- return (f result) -- return is opposite of <-, wrap a string to IO action


-- main = do line <- getLine
          -- let line' = reverse line
          -- putStrLn $ "You Said " ++ line' ++ " backworkds!!"

-- do it in Functor approach

main = do line <- fmap reverse getLine  -- fmap takes an IO action and returns an IO action
          putStrLn $ "You Said " ++ line ++ " backworkds!!"  
          
-- 3. Lambda function should be like (\a b = a+b), if no parameters, because of "partial application",
-- we can just use (+).
-- plus` :: (Num a) => a -> a -> a
-- plus` a b = a + b -- plus` / plus` a / plus` a b  are 3 functions. the first 2 are curried. that's 
-- why we can just use ( + ), it's the first curried function in above 3 styles.

-- 4. function type r -> 可重写为 (->) r。 考虑： r -> a， 它定义一个函数，该函数接受任意值 r 为输入参数，输出a.
-- (->) r 就是接受一个参数的函数，它的输出值类型未指定。

-- instance Functor ((->) r) where
--     fmap f g = (\r -> f (g r))   -- 函数g接受一个参数，并输出某值，该值类型未定。

-- 它其实就是 function composition:  fmap = (.)

-- 5. (a —> b) -> ( f a -> f b )  'lifting' a function ( 函数提升, 还是在 function composition )

-- 6. what can be called a 'Functor'? Funcot Law, 定义任意functor必须满足两个法则。
-- 6.1， 对某a, 当使用 fmap id a 到它时，返回 id a.
-- 6.2, fmap (f . g) a =  fmap f ( fmap g a )  ( 最终返回 a )

-- Functor： 搞得很深入，道理很浅显。 fuctor就是能被map的东西。



-- 7. 



