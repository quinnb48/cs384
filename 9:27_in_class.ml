(* (lambda x.x) y reduces to y
     |     |  \
function input output

above means x(y/x) which means y replaces x in x
(lambda x.xx) y => xx(y/x)

infinite loop: (lambda x.xx) (lambda x.xx)



=> means "reduce(s) to"
irr means irreducable
x is for variables
l means lambda
l x is for functions
T or S are for terms

irreducables:
1:

------
x irr

2:
T irr
-------
(x T) irr

3:
T irr
------
l x. T irr

4:
(T1 T2) irr    T3 irr
------------------------------------
(T1 T2)T3 irr

reducables:
5:
T => S
------
lx.T => lx.S

6:

----------------
(l x T1) T2 => T1(T2/x)

7:
T => S
----------------
X T => x S

8:
(T1 T2) => S
-----------
(T1 T2)T3 => S T3

9:
(T1 T2) irr    T3 => S
------------------------------------
(T1 T2)T3 => (T1 T2)S



eg:
l x. l y. x y (l z. z) irr  is better written as

l x. l y. (x (y (l z. z))) irr

to prove is irr (working from bottom up):

------         ---------   <- by rule 1 above
 y irr           x irr
--------      ----------     <- by rule 3 above
x y irr       l z.z irr
-------------------        <- by rule 4 above
x y (l z.z) irr
------------------------    <- by rule 3 above
l y ((x y) (l z.z)) irr
------------------------------     <- by rule 3 above
l x. l y. ((x y) (l z. z)) irr


classwork:


-------  <- rule 1
x irr
-------   <- rule 2
s x irr
------------- <- rule 3
 lx. s x irr
------------    <- irreducable by lambda rule/ rule 3 above
ls. lx. s x irr


------
b
---------------   <- rule 6
(ly. y) b => b
---------------------  <- rule 7
a ((ly. y) b) => a b
------------------------------ <- rule 5
lx. a ((ly. y) b) => lx. a b




*)
