-- 7. modules

-- 1. import qualified Data.Map as M 

import Data.List
import Geometry  -- case sensitive
-- and also, a hierachy modules should be put into folder
-- create a folder name "Geometry", which consists of "Sphere.hs".. etc
-- import this way: import Geometry.Sphere

test_module1 = sphereVolume 3.4
test_module2 = cubeArea 4

test_trans = map sum $ transpose [[0,3,5,9],[10,0,0,9],[8,5,1,-1]]  

-- 2. stack overflow,
-- by default, lazy algorithm is used, which may cause stack overflow. in this case
-- use its strict version (non lazy) foldl' (not single quote)

-----------------------------------------------------------------------
--
-- didn't go really deep at Data.List, Data.Map, Data.Char .., check 
-- reference if needed
--
-----------------------------------------------------------------------


