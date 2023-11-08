(* NOTE: This grammar deals with characters, rather than tokens as we have
typically done in the past. You can convert a string to a list of characters
using the code "List.of_seq (String.to_seq <string>)" in OCaml. Since we're
dealing with characters there is no need for a lexer.

<A> is the start symbol of this grammar

<A> ::= a <A> b <B> c
      | c <A>
      | ( <A> )
      | <A> d <C>
      | d

<B> ::= [ <B> ]
      | <C>
      | a <B> a
      | <A> b <A>

<C> ::= d d d
      | <A> <B>
      | <C> a
      *)

type ruleA =
        | A1 of ruleA * ruleB
        | A2 of ruleA
        | A3 of ruleA
        | A4 of ruleA * ruleC
        | A5

and ruleB =
        | B1 of ruleB
        | B2 of ruleC
        | B3 of ruleB
        | B4 of ruleA * ruleA

and ruleC =
        | C1
        | C2 of ruleA * ruleB
        | C3 of ruleC


let rec print_ruleA : ruleA -> string = function
        | A1 (e1, e2) -> "a" ^ print_ruleA e1 ^ "b" ^ print_ruleB e2 ^ "c"
        | A2 (e1) -> "a" ^ print_ruleA e1
        | A3 (e1) -> "(" ^ print_ruleA e1 ^ ")"
        | A4 (e1, e2) -> print_ruleA e1 ^ "d" ^ print_ruleC e2
        | A5 (e1) -> "d"

and rec print_ruleB : ruleB -> string = function
        | B1 (e1) -> "[" ^ print_ruleB e1 ^ "]"
        | B2 (e1, e2) -> print_ruleA e1 ^ print_ruleB e2
        | B3 (e1) -> "a" ^ print_ruleB e1 ^ "a"
        | B4 (e1, e2) -> print_ruleA e1 ^ "b" ^ print_ruleA e2

and rec print_ruleC : ruleC -> string = function
        | C1 (e1) -> "ddd"
        | C2 (e1) -> print_ruleC e1
        | C3 (e1) -> print_ruleC e1 ^ "a"


let expect (t : token) : token list -> token list = function
        | [] -> raise (ParseError
                     ("Unexpected end of input: expected " ^ t))
        | x :: xs ->
            if x = t then xs
            else raise (ParseError
                        ("Expected " ^ t ^ ", got " ^ x))

let parse_term : token list -> rule * token list =
    | LParen :: r ->
        let (e, r2) = bool_expr r in
        (e, expect RParen r2)
    | d :: d :: d :: r -> (C1, r)
    | d :: r -> (A5, r)
    | [] -> raise (ParseError "Expected <char> or (, got end of input")
    | t :: _ -> raise (ParseError ("Expected <char> or (, got " ^ t))

and AParse (s : token list) : rule * token list =
    match s with
    | a :: r ->
    | c :: r ->
    | d :: r ->
