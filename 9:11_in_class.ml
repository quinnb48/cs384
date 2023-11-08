p::= e
    |(p)
    |p p

b::= ""
    | b
a::= ""
    |a
    |a b

g::= if c then <expr> else <expr>
    | if c then <expr> else g
    | if c then g else <expr>
    | if c then g else g

c::= true | false
    | <expr> < <expr>
    | <expr> > <expr>
    | <expr> = <expr>
    | <expr> != <expr>
