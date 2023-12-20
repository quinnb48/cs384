open Ast

exception ItptError of string

type itpt_typ =
    |NilIp
    |IntIp of int option
    |BoolIp of bool option
    |StringIp of string option
    |UnitIp of unit
    |TuplIp of itpt_typ * itpt_typ
    |FuncIp of itpt_typ * itpt_typ
    |UserIp of string * ((string * itpt_typ) list)

let rec itpt_typ_to_str (i: itpt_typ) : string =
    match i with
    |NilIp -> "NilIp"
    |IntIp _ -> "IntIp"
    |BoolIp _ -> "BoolIp"
    |StringIp _ -> "StringIp"
    |UnitIp _ -> "UnitIp"
    |TuplIp (it,it2) -> "TuplIp ("^ itpt_typ_to_str it ^ ", " ^ itpt_typ_to_str it2 ^ ")"
    |FuncIp (it,it2) -> "FuncIp ("^ itpt_typ_to_str it ^ ", " ^ itpt_typ_to_str it2 ^ ")"
    |UserIp (s, _) -> "UserIp " ^ s

let rec print_itpt (i: ((string * itpt_typ) list)) : string =
    let i2 = List.rev i in
    match i2 with
    |h::r -> (match h with
        |(s, it) -> let rec help its = (match its with
            |NilIp -> s ^ ": Nil; " ^ print_itpt r
            |IntIp ip -> (match ip with
                |None -> s ^ ": Int Undefined yet"
                |Some ips -> s ^ ": Int " ^ string_of_int ips ^ "; " ^ print_itpt r)
            |BoolIp b -> (match b with
                |None -> s ^ ": Bool Undefined yet"
                |Some bs -> if bs = true then s ^ ": True; " ^ print_itpt r else s ^ ": False; " ^ print_itpt r)
            |StringIp ss -> (match ss with
                |None -> s ^ ": String Undefined yet"
                |Some bs -> s ^ ": String " ^ bs ^ "; " ^ print_itpt r)
            |UnitIp _ -> s ^ ": Unit; " ^ print_itpt r
            |TuplIp (i2, i3) -> s ^ ": Tuple(" ^ help i2 ^ ", " ^ help i3 ^ "); " ^ print_itpt r
            |FuncIp (i2, i3) -> s ^ ": Function(" ^ help i2 ^ ", " ^ help i3 ^ "); " ^ print_itpt r
            |UserIp (s2, l) -> let rec help2 (l2: (string * itpt_typ) list) : string = (match l2 with
                |h2::r2 -> (match h2 with
                    |(s3, it2) -> "(" ^ s3 ^ help it2 ^ ") " ^ help2 r2)
                |_ -> "" ) in s ^ ": User " ^ s2 ^ "(" ^ help2 l ^ "); " ^ print_itpt r)
        in help it)
    |[] -> ""

let rec print_gam_itpt (g: (string*expr*itpt_typ) list) =
    match g with
    | h::r -> (match h with
        |(str, expr, typ) -> "(" ^ str ^ ": "^ print_expr expr ^ ", " ^ print_itpt ((str, typ)::[]) ^ "); " ^ print_gam_itpt r)
    | _ -> ""

let rec ast_typ_to_itpt_typ (t: typ) =
    match t with
    |NilTy -> NilIp
    |IntTy -> IntIp None
    |BoolTy -> BoolIp None
    |StringTy -> StringIp None
    |UnitTy -> UnitIp ()
    |TuplTy (t1,t2)-> TuplIp(ast_typ_to_itpt_typ t1, ast_typ_to_itpt_typ t2)
    |FuncTy (t1,t2)-> FuncIp(ast_typ_to_itpt_typ t1, ast_typ_to_itpt_typ t2)
    |ParenTy t1 -> ast_typ_to_itpt_typ t1
    |UserTy s -> UserIp(s, [])

and itpt_expr (gamma: (string*expr*itpt_typ)list)(e: expr) : itpt_typ =
    match e with
    | EMatch (e1, pa) -> let h = itpt_expr gamma e1 in let rec help (p2: pipes) = (match p2 with
        |Pipep b -> (match b with
            |Branchs (s, v, e2) -> if ("TuplIp "^ itpt_typ_to_str h) = print_vars v || ("FuncIp "^ itpt_typ_to_str h) = print_vars v then itpt_expr ((s,e2,h)::gamma) e2 else raise(ItptError("Failed pattern matching on " ^ print_expr e1))
            |Branch (s, e2) -> (match h with
                |NilIp -> itpt_expr ((s,e1,h)::gamma) e2    (* honstly unsure how to check if equal... can't use type names in input because parser gets confused, they're all the same type anyways so type checking doesn't help anything, name doesn't matter anyway as long as they're the same type which they are*)
                |IntIp _ -> itpt_expr ((s,e1,h)::gamma) e2
                |BoolIp _ -> itpt_expr ((s,e1,h)::gamma) e2
                |StringIp _ ->  itpt_expr ((s,e1,h)::gamma) e2
                |UnitIp _ ->  itpt_expr ((s,e1,h)::gamma) e2
                |_ -> raise(ItptError("Failed pattern matching on " ^ print_expr e1)) ) )
        |Pipesp (b, p) -> (match b with
            |Branchs (s, v, e2) -> if ("TuplIp "^ itpt_typ_to_str h) = print_vars v || ("FuncIp "^ itpt_typ_to_str h) = print_vars v then itpt_expr ((s,e2,h)::gamma) e2 else help p
            |Branch (s, e2) -> (match h with
                |NilIp -> itpt_expr ((s,e1,h)::gamma) e2
                |IntIp (Some _) -> itpt_expr ((s,e1,h)::gamma) e2
                |BoolIp (Some _) -> itpt_expr ((s,e1,h)::gamma) e2
                |StringIp (Some _) -> itpt_expr ((s,e1,h)::gamma) e2
                |UnitIp _ -> itpt_expr ((s,e1,h)::gamma) e2
                |_ -> help p ) )) in help pa
    | EInt i -> IntIp (Some i)
    | ETrue -> BoolIp (Some true)
    | EFalse -> BoolIp (Some false)
    | EVar s -> StringIp (Some s)
    | EID i -> let rec search_gamma (g: (string*expr*itpt_typ) list) =
        (match g with
            |[]-> raise(ItptError("id " ^ i ^ " not defined before use: " ^ print_gam_itpt gamma))
            |(s,_, t)::r -> if i = s then t else search_gamma r)
            in search_gamma gamma
    | EUnit -> UnitIp ()
    | EParen s -> itpt_expr gamma s
    | UNot e1 -> (match itpt_expr gamma e1  with
        |BoolIp (Some true) -> BoolIp (Some false)
        |BoolIp (Some false) -> BoolIp (Some true)
        |BoolIp (_) -> BoolIp None
        |_ -> NilIp )
    | Squig e1 -> (match itpt_expr gamma e1 with
        |IntIp i -> (match i with
            |Some i2 -> IntIp (Some (-i2))
            |_ -> IntIp None)
        |_ -> NilIp)
    | BPlus (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(IntIp i1, IntIp i2) -> (match (i1, i2) with
            |(Some bs, Some bs2) -> IntIp (Some (bs + bs2))
            |_ -> IntIp None ) (* this is if i1 or i2 is undefined yet, a la in a recursive function *)
        |_ -> NilIp )
    | BMinus (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(IntIp i1, IntIp i2) -> (match (i1, i2) with
            |(Some bs, Some bs2) -> IntIp (Some (bs - bs2))
            |_ -> IntIp None )
        |_ -> NilIp )
    | BTimes (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(IntIp i1, IntIp i2) -> (match (i1, i2) with
            |(Some bs, Some bs2) -> IntIp (Some (bs * bs2))
            |_ -> IntIp None)
        |_ -> NilIp )
    | BDivide (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(IntIp i1, IntIp i2) -> (match (i1, i2) with
            |(Some bs, Some bs2) -> IntIp (Some (bs / bs2))
            |_ -> IntIp None)
        |_ -> NilIp )
    | BMod (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(IntIp i1, IntIp i2) -> (match (i1, i2) with
            |(Some bs, Some bs2) -> IntIp (Some (bs mod bs2))
            |_ -> IntIp None)
        |_ -> NilIp )
    | BLt  (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(IntIp i1, IntIp i2) -> (match (i1, i2) with
            |(Some bs, Some bs2) -> if bs < bs2 then BoolIp (Some true) else BoolIp (Some false)
            |_ -> BoolIp None)
        |_ -> NilIp )
    | BEq (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(i1, i2) -> if i1 = i2 then BoolIp (Some true) else BoolIp (Some false))
    | BConcat  (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(StringIp i1, StringIp i2) -> (match (i1, i2) with
            |(Some bs, Some bs2) -> StringIp (Some (bs ^ bs2))
            |_ -> StringIp None)
        |_ -> NilIp)
    | BAnd (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(BoolIp (Some true), BoolIp (Some true)) -> BoolIp (Some true)
        |(BoolIp (Some _), BoolIp (Some _)) -> BoolIp (Some false)
        |_ -> BoolIp None)
    | BOr (e1, e2) -> (match (itpt_expr gamma e1, itpt_expr gamma e2) with
        |(BoolIp (Some false), BoolIp(Some false)) -> BoolIp (Some false)
        |(BoolIp (Some _), BoolIp (Some _)) -> BoolIp (Some true)
        |_ -> BoolIp (None))
    | EVars (e1, e2, el) -> TuplIp(itpt_expr gamma e1, (match el with
        |Nil -> itpt_expr gamma e2
        |ExprL (e3, el3) -> let rec help (l: expr_lst) = (match l with
            |Nil -> itpt_expr gamma e3
            |ExprL (e4, el4) -> TuplIp(itpt_expr gamma e4, help el4)) in TuplIp(itpt_expr gamma e2, help el3)))
    | EFuncApp (e1, e2) -> (match e1 with
        |EID s -> let rec search_gamma (g: (string*expr*itpt_typ) list) (new_g: (string*expr*itpt_typ) list) =
            (match g with
                |[]-> raise(ItptError( s ^ " is not defined before use: " ^ print_expr e ^ "; Gamma: " ^ print_gam_itpt gamma))
                |(d, e3, t)::r -> if d = s then let rec h2 (ele:expr)gam1 gam2 = (match ele with
                    |EListEnd e4 ->  (match gam1 with
                        |(d2, _, _)::r2 -> itpt_expr (List.rev( r2 @ ((d2, e4, itpt_expr gamma e4)::gam2))) e3
                        |_ -> NilIp )
                    |EList (e4, el) -> (match gam1 with
                        |(d2, _, _)::r2 -> if itpt_expr gamma e4 = NilIp then NilIp else h2 el r2 (((d2, e4, itpt_expr gamma e4)::gam2))
                        |_ ->  if itpt_expr gamma e4 = NilIp then NilIp else raise(ItptError(print_gam_itpt gamma ^ ";;;" ^ print_gam_itpt gam1 ^ ";;;" ^ print_gam_itpt gam2 ^";;;" ^ print_expr ele ))  )
                    |_ -> raise(ItptError("???"))) in (h2 e2 r ((d, e3, t)::new_g))
                    else search_gamma r ((d, e3,t)::new_g)  )
                  in (search_gamma gamma [])
        |_ -> raise(ItptError(print_gam_itpt gamma))  )
    | EListEnd e1 -> itpt_expr gamma e1
    | EList (e1, l1) -> FuncIp (itpt_expr gamma e1, itpt_expr gamma l1)
    | EFun (p, pl, _, e1) -> let new_g = (match p with              (* adds params to gamma, with default values at this point*)
        |P s -> let h = let rec help g (plst: param_lst) = (match plst with
            |Nil -> g
            |PLS (p2, pl2) -> (match p2 with
                |P s2 -> help (( s2, e1, NilIp)::g) pl2
                |Ps (s2, t2) -> help (( s2, e1, (ast_typ_to_itpt_typ t2))::g) pl2))
            in help gamma pl in (( s, EUnit, NilIp)::h)
        |Ps (s, t2) -> let h = let rec help g (plst: param_lst) = (match plst with
            |Nil -> g
            |PLS (p2, pl2) -> (match p2 with
                |P s2 -> help (( s2, e1, NilIp)::g) pl2
                |Ps (s2, t3) -> help (( s2, e1, (ast_typ_to_itpt_typ t3))::g) pl2))
            in help gamma pl in (( s, e1,(ast_typ_to_itpt_typ t2))::h)) in itpt_expr new_g e1
    | EIf (e1, e2, e3) -> (match itpt_expr gamma e1 with
        |BoolIp (Some true) -> itpt_expr gamma e2
        |_ -> itpt_expr gamma e3)
    | ELetRec (s, pl, _, e1, e2) -> let h = let rec help g (plst: param_lst) = (match plst with              (* adds params to gamma, with default values at this point*)
            |Nil -> g
            |PLS (p2, pl2) -> (match p2 with
                |P s2 -> help (g@((s2, EUnit, NilIp)::[])) pl2
                |Ps (s2, _) -> help (g@(( s2, EUnit, NilIp)::[] )) pl2))
            in help gamma pl in itpt_expr ((s, e1, itpt_expr ((s, e1, NilIp)::h) e1)::gamma) e2
    | ELet (s, pl, _, e1, e2) -> let h = let rec help g (plst: param_lst) = (match plst with              (* adds params to gamma, with default values at this point*)
            |Nil -> g
            |PLS (p2, pl2) -> (match p2 with
                |P s2 -> help (g@(( s2, EUnit, NilIp)::[])) pl2
                |Ps (s2, _) -> help (g@(( s2, EUnit, NilIp)::[])) pl2))
            in help gamma pl in itpt_expr ((s, e1, itpt_expr h e1)::gamma) e2

 let interpret (pr: prog) : ((string * itpt_typ) list) =
    let rec helper (f: (string * itpt_typ) list)(gamma: (string*expr*itpt_typ) list) (o: prog) : (string * itpt_typ) list =
        match o with
        |EndMain b -> (match b with
            |TypeBind (s,p) -> let rec help (pt: pipes_typ) : (string * itpt_typ) list =
                (match pt with
                |Pipe_typ b -> (match b with
                    |BranchId i -> (i, NilIp)::[]
                    |BranchIdTyp (i,t) -> (i, ast_typ_to_itpt_typ t)::[])
                |Pipes_typ (b, p2) -> (match b with
                    |BranchId i -> (i, NilIp)::(help p2)
                    |BranchIdTyp (i,t) -> (i, ast_typ_to_itpt_typ t)::(help p2)))
                in ((s, UserIp(s, help p))::f)
            |FuncBindRec (s,pl,_,e) -> let rec help g (plst: param_lst) = (match plst with              (* adds params to gamma, with default values at this point*)
                |Nil -> g
                |PLS (p2, pl2) -> (match p2 with
                    |P s2 -> help (g@((s2, EUnit, NilIp)::[])) pl2
                    |Ps (s2, _) -> help (g@(( s2, EUnit, NilIp)::[] )) pl2))
                    in (s, itpt_expr ((s, EUnit, NilIp)::(help gamma pl)) e)::f
            |FuncBind (s,pl,_,e) -> let rec help (g: (string*expr*itpt_typ) list) (plst: param_lst) = (match plst with              (* adds params to gamma, with default values at this point*)
                    |Nil -> g
                    |PLS (p2, pl2) -> (match p2 with
                        |P s2 -> help (g@(( s2, EUnit, NilIp)::[])) pl2
                        |Ps (s2, _) -> help (g@(( s2, EUnit, NilIp)::[])) pl2))
                    in (s, itpt_expr (help gamma pl) e)::f )
        |Main (b, p2) -> (match b with
            |TypeBind (s,p) -> let rec help (pt: pipes_typ) : (string * itpt_typ) list =
                (match pt with
                |Pipe_typ b -> (match b with
                    |BranchId i -> (i, NilIp)::[]
                    |BranchIdTyp (i,t) -> (i, ast_typ_to_itpt_typ t)::[])
                |Pipes_typ (b, p2) -> (match b with
                    |BranchId i -> (i, NilIp)::(help p2)
                    |BranchIdTyp (i,t) -> (i, ast_typ_to_itpt_typ t)::(help p2)))
                in helper ((s, UserIp(s, help p))::f) ((s, EUnit, UserIp(s, help p))::gamma) p2
            |FuncBindRec (s,pl,_,e) -> let rec help (g: (string*expr*itpt_typ) list) (plst: param_lst): (string * expr * itpt_typ) list = (match plst with              (* adds params to gamma, with default values at this point*)
                    |Nil -> g
                    |PLS (p2, pl2) -> (match p2 with
                        |P s2 -> help (g@((s2, EUnit, NilIp)::[])) pl2
                        |Ps (s2, _) -> help (g@(( s2, EUnit, NilIp)::[] )) pl2))
                    in helper ((s, (itpt_expr ((s, e, NilIp)::(help gamma pl)) e) )::f) ((s, e, NilIp)::(help gamma pl)) p2
            |FuncBind (s,pl,_,e) -> let h = let rec help (g:(string*expr*itpt_typ) list) (plst: param_lst) = (match plst with              (* adds params to gamma, with default values at this point*)
                    |Nil -> g
                    |PLS (p2, pl2) -> (match p2 with
                        |P s2 -> help (g@(( s2, EUnit, NilIp)::[])) pl2
                        |Ps (s2, _) -> help (g@(( s2, EUnit, NilIp)::[])) pl2))
                    in help gamma pl in helper ((s, itpt_expr h e)::f) ((s,e, itpt_expr h e)::h) p2 )
    in helper [] [] pr
