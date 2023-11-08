type prop =
  | And of prop * prop
  | Or of prop * prop
  | Not of prop
  | True
  | False
  | Sym of string
  | Let of string * prop * prop

(* RULES:
And:
    p1 => true, p2 => true, then p1 And p2 => true
    p1 => true, p2 => false, then p1 And p2 => false
    p1 => false, p2 => true, then p1 And p2 => false
    p1 => false, p2 => false, then p1 And p2 => false
Or:
    p1 => true, p2 => true, then p1 Or p2 => true
    p1 => true, p2 => false, then p1 Or p2 => true
    p1 => false, p2 => true, then p1 Or p2 => true
    p1 => false, p2 => false, then p1 Or p2 => false
Not:
    p1 => true, then Not p1 => false
    p1 => false, then Not p1 => true
Sym:
    p1 => string, then Sym p1 => string
Let:

    *)


let rec interpret (program : prop) : prop =
    match program with
    | And (e1, e2) ->
      let v1 = interpret e1 in
      let v2 = interpret e2 in
      (match (v1, v2) with
       | (True, True) -> True
       | (True, False) -> False
       | (False, True) -> False
       | (False, False) -> False
       | (_, _) -> failwith "Type Error")
    | Or (e1, e2) ->
      let v1 = interpret e1 in
      let v2 = interpret e2 in
      (match (v1, v2) with
       | (True, True) -> True
       | (True, False) -> True
       | (False, True) -> True
       | (False, False) -> False
       | (_, _) -> failwith "Type Error")
     | Not (e1) ->
        let v1 = interpret e1 in
        (match (v1 ) with
          | (True) -> False
          | (False) -> True
          | _ -> failwith "Type Error")
    | True -> True
    | False -> False
