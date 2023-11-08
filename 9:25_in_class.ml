(* Which symbols occur free in the following expressions? Which ones occur bound?

p a b
free: p a b

&b. p a b
free: p a

&s. &x. s (s (s x))
free: None

(&b. a b) (&a. a)
free: a in first lambda

(&p. &a. &b. p b a) (&a. &b. a) (&s. &x. x) (&s. &x. s (s (s (n s x))))
free: n

Substitution
Use substitution to reduce the following terms as much as possible.

&x. &y. (f y) x
can't be reduced

(&p. &a. &b. p b a) ((&n. n (&z. &a. &b. b) (&a. &b. a)) (&s. &z. z))
(&a. &b. ((&n. n (&z. &a. &b. b) (&a. &b. a)) (&s. &z. z)) b a)
(&a. &b. (((&s. &z. z) (&z. &a. &b. b) (&a. &b. a)) ) b a)
(&a. &b. ((&z. z) (&a. &b. a)) b a)


(&n. &s. &x. s (n s x)) (&s. &x. s (s x))

(&a. &b. a) (&s. &x. s (s x)) (&z. &a. &b. b) *)
