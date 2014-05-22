-- Chapter 8 Making Our Own Types and Typeclasses
import qualified Data.Map as Map


-- 1. data keyword
-- Algebraic data type -- 
-- Circle is a function, called "Value Constructor", values following are "Fields" or "Parameters"
data Point = Point Float Float deriving(Show)
data Shape = Circle Float Float Float | Rectangle Point Point deriving (Show)

-- Circle :: Float -> Float -> Float -> Shape.  take 3 input parameters and 1 output.
-- Circle 7 8 9 > Circle 1 2 3 ==> True

test_surface :: Shape -> Float
test_surface (Circle _ _ r ) = pi * r ^ 2
test_surface (Rectangle ( Point x1 y1) (Point x2 y2) ) = ( abs $ x2 - x1) * ( abs $ y2 - y1)

-- test_surface $ Circle 10 20 10
-- Circle is function, can be partial applied.
test_map = map (Circle 3 4) [2, 5, 8]
test_rectangle = test_surface(Rectangle (Point 1 6) (Point 12 28))

-- export Shape: module Shapes ( Shape(..), test_surface ) where 

-- 2. Record Syntax
-- type name can be used as constructor name, as in C++; but not necessary, not in C++.

data Person = Person String String Float deriving (Show)
guy = Person "Jianping" "Wang" 20 

fstName :: Person -> String
fstName (Person fstName _ _) = fstName

lstName :: Person -> String
lstName (Person _ lstName _) = lstName
    
test_field1 = fstName guy
test_field2 = lstName guy

-- another way to pass parameters, more readable. called "Record Syntax"
-- the first time to see curly bracket in Haskell?
data Person2 = Person2 { firstName :: String  
                     , lastName :: String  
                     , age :: Int  
                     } deriving (Show) 
guy2 = Person2 {firstName="Jianping", lastName="Wang", age=30}

-- 3. "Type Parameter", comparied with "Value Parameter", giving a parameter, return 
-- a new type. like template do in C++.

data Maybe2 a = Nothing2 | Just2 a

-- type could be: Maybe2 Int, Maybe2 [Char]... Maybe2 is type constructor.
-- with a parameter, it creates a new type.
-- Just2 a is the function body, Just2 is "Value Constructor".
-- When to use?  when the type for "Value Constructor" is not important. like 
-- a list of something, the type of something doesn't important.

-- 4. never add typeclass constraints in data declarations
-- like data (Ord k) => Map k v = ...   we don't benefit from the typeclass.

-- 1st Vector is a type constructor; 2nd Vector is a value constructor.
-- left a is type parameter(Int Char), right a are values of that type.
data Vector a = Vector a a a deriving(Show)
vplus :: (Num a) => Vector a -> Vector a -> Vector a
(Vector i j k) `vplus` (Vector m n t) = Vector (i+m) (j+n) (k+t) -- brackets are needed, space has high precedance.

-- 5. specify return type when invoking a function. usually we use :: to specify type of a function. the last one is the 
-- return type. that's why we can do it this way.
test_read = read "8" :: Int 

-- 6. typeclass indicates a type implementing some behaviors. typeclass constraints 'behavior', a group of these values
-- can be sorted, can show, can read. first we create a type, then implement functions required by a typeclass.

data Day = Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday   
           deriving (Eq, Ord, Show, Read, Bounded, Enum) 

test_day1 = minBound :: Day  -- Bounded
test_day2 = succ Thursday
test_day3 = pred Monday  --exception. the first enum doesn't have pred

-- 7. Type Synonym.
-- type String = [Char]  keyword type is like typedef in C

type PhoneNumber = String
type Name = String
type PhoneBook = [(Name, PhoneNumber)]
inPhoneBook :: Name -> PhoneNumber -> PhoneBook -> Bool
inPhoneBook name pnum pbook = (name, pnum) `elem` pbook

-- 8.  type code from chapter 8.
data LockerState = Taken | Free deriving (Show, Eq)

type Code = String

type LockerMap = Map.Map Int (LockerState, Code)

lockerLookup :: Int -> LockerMap -> Either String Code
lockerLookup lockerNumber map = 
    case Map.lookup lockerNumber map of
        Nothing -> Left $ "Locker number" ++ show lockerNumber ++ " doesn't exist!"
        Just (state, code) -> if state /= Taken
                                then Right code
                                else Left $ "Locker" ++ show lockerNumber ++ "is already taken!"
                                
lockers :: LockerMap  
lockers = Map.fromList   
    [(100,(Taken,"ZD39I"))  
    ,(101,(Free,"JAH3I"))  
    ,(103,(Free,"IQSA9"))  
    ,(105,(Free,"QOTSA"))  
    ,(109,(Taken,"893JJ"))  
    ,(110,(Taken,"99292"))  
    ]
    
-- 9. Define our own list
-- Cons is :
data List a = Empty | Cons a (List a) deriving(Eq, Ord, Show, Read)

-- infixr 5 :-:  number is for precedence.

-- /= means not equal
-- 10. keywords: class instance data 

-- a must be a concrete type, type constructor is not enough
-- like Maybe a is good, but only Maybe is not.
class Eq2 a where  
    (-=) :: a -> a -> Bool  -- equal, operators are infix functions, infixr specify its precedance.
    (~=) :: a -> a -> Bool  -- not equal; like * should be higher than +
    x -= y = not (x ~= y)  
    x ~= y = not (x -= y) 

data TrafficLights = Red | Yellow | Green

-- class claims functions its instances must realize.
-- instance .. where, then implement functions needed by typeclass.
instance Eq2 TrafficLights where
    Red -= Red = True
    Yellow -= Yellow = True
    Green -= Green = True
    _ -= _ = False

instance Show TrafficLights where
    show Red = "Red, stop!"
    show Yellow = "Yellow, prepare to stop!"
    show Green = "Green, Nice!"
    
instance Enum TrafficLights where
    pred Red = Green
    pred Green = Yellow
    pred Yellow = Red
    succ Red = Yellow
    succ Yellow = Green
    succ Green = Red

-- typeclass conforms to typeclass 
-- class (Eq a) => Num a where 
    
-- :info Num, :info Enum check type and typeclass

-- 11. yesno typeclass
-- instance realize functions needed by typeclass, use pattern match.

-- typeclass definition, a is a type
class YesNo a where 
    yesno :: a -> Bool

instance YesNo Int where
    yesno 0 = False
    yesno _ = True

instance YesNo [a] where
    yesno [] = False
    yesno _  = True

-- 12. Functor
-- class Functor f where 
--      fmap :: (a->b) -> f a -> f b

-- Note that, different from other typeclass, it take a type constructor
-- instead of a type as its parameter.

-- 13. functions can be partial applied, so does type constructor.
-- e.g.  a type constructor takes 2 types as parameters, when it gets one,
-- it still a type constructor, which takes only one parameter.

-- now we have many types, concrete types, custom types created by type constructor.
-- we may classify these types. we call them type "kinds"
-- :k Int    :k Maybe to check them.
-- * is concrete type. 
-- we use :k on a type to get its kind; just like we use :t to get its type.

data Frank a b  = Frank {frankField :: b a} deriving (Show)
-- :k Frank


-- 14. Also, Haskell always takes one parameter and output one value.  that makes
-- it simple and also powerful. like we have only 0 - 1, and we have such a new 
-- world.
