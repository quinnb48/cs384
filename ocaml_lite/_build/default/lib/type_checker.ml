open Ast

exception TypeError of string

 let int_of_string (s: string) : int =
    int_of_string s

 let string_of_int (i : expr): string =
    match i with
    |EInt t -> string_of_int t
    | _ -> raise(TypeError(print_expr i ^ " is not an int"))

 let print_string (s: string) : unit =
    print_endline s

let rec get_typs g t =
    match t with
    |NilTy -> NilTy
    |IntTy -> IntTy
    |BoolTy -> BoolTy
    |StringTy -> StringTy
    |UnitTy -> UnitTy
    |UserTy s -> let rec search_gamma (g2: (expr*typ) list) =
        (match g2 with
            |[]-> raise(TypeError("id " ^ s ^ " not defined before use"))
            |(EID i, _)::r ->  if i = s then UserTy s else search_gamma r
            | _::r -> search_gamma r)
            in search_gamma g
    |ParenTy t1 -> get_typs g t1
    |FuncTy (f1, f2) -> FuncTy(get_typs g f1, get_typs g f2)
    |TuplTy (t1, t2) -> TuplTy(get_typs g t1, get_typs g t2)

 let rec check_typ_pipes_typ (gamma: (expr*typ) list)(p: pipes_typ) : (expr*typ) list= (* adds pipes_typs to gamma*)
    match p with
    |Pipe_typ b -> (match b with
        |BranchId i -> ((EID i, NilTy)::gamma)
        |BranchIdTyp (i,t) -> ((EID i, get_typs gamma t)::gamma))
    |Pipes_typ (b, p2) -> (match b with
        |BranchId i -> check_typ_pipes_typ ((EID i, NilTy)::gamma) p2
        |BranchIdTyp (i,t) -> check_typ_pipes_typ ((EID i, get_typs gamma t)::gamma) p2)

let rec get_typ_pipes_typ g (p: pipes_typ) =
   match p with
   |Pipe_typ b -> (match b with
       |BranchId i -> TuplTy(UserTy i, NilTy)
       |BranchIdTyp (i,t) -> TuplTy(UserTy i, get_typs g t))
   |Pipes_typ (b, p2) -> (match b with
       |BranchId i -> TuplTy(TuplTy(UserTy i, NilTy), get_typ_pipes_typ g p2)
       |BranchIdTyp (i,t) ->  TuplTy(TuplTy(UserTy i, get_typs g t), get_typ_pipes_typ g p2))

 let rec check_typ_param_lst(gamma: (expr*typ) list)(pl: param_lst) : (expr*typ) list=    (* adds params to gamma*)
    match pl with
        |Nil -> gamma
        |PLS (p,pl2) -> (match p with
            |P s ->  check_typ_param_lst ((EID s, NilTy)::gamma) pl2
            |Ps (s, t) -> check_typ_param_lst ((EID s, t)::gamma) pl2)

let rec pl_typ_func(pl: param_lst)(t: typ) =
    match pl with
        |Nil -> t
        |PLS(p, pl2) -> (match p with
            |P _ -> FuncTy(NilTy, pl_typ_func pl2 t)
            |Ps (_, t2) -> FuncTy(t2, pl_typ_func pl2 t))

let rec check_return_typ_functy (f: typ) =
    match f with
    |FuncTy(_,FuncTy(t1,t2)) -> check_return_typ_functy (FuncTy (t1,t2))
    |FuncTy(_, t2) -> t2
    |_ -> f

let search_vars g (v: vars) (t: typ) =
    match v with
    |Name _ -> (match t with
        |TuplTy (_, _) -> raise(TypeError("not enough vars for given type in match"))
        |FuncTy (_, _) -> raise(TypeError("not enough vars for given type in match"))
        |_ -> true )
    |NameList (_, idl) -> let rec search_idl (il: id_lst) (t2: typ) =
        (match t2 with
        |TuplTy (_, tt2) ->
            (match il with
            |Nil -> raise(TypeError("not enough vars for given type in match"))
            |IdL (_, il2) -> search_idl il2 tt2)
        |FuncTy (_, tt2) ->
            (match il with
            |Nil -> raise(TypeError("not enough vars for given type in match"))
            |IdL (_, il2) -> search_idl il2 tt2)
        |ParenTy p -> search_idl il p
        |UserTy s2 -> let rec search_gamma (g: (expr*typ) list) =
            (match g with
                |[]-> raise(TypeError("id " ^ s2 ^ " not defined before use"))
                |(EID i, _)::r ->  if i = s2 then true else search_gamma r
                | _::r -> search_gamma r)
                in search_gamma g
        |_ -> raise(TypeError("too many vars for given type in match: " ^ typ_to_str t2)))
        in search_idl idl t

let add_vars gam (v: vars) (t: typ) =
    match v with
    |Name s -> (match t with
        |_ -> ((EID s, t)::gam))
    |NameList (s, idl) -> let rec search_idl g (il: id_lst) (t2: typ) =
        (match t2 with
        |TuplTy (tt1, tt2) ->
            (match il with
            |IdL (ils, il2) -> search_idl ((EID ils, tt1)::g) il2 tt2
            |Nil -> ((EID s, t2)::gam))
        |FuncTy (tt1, tt2) ->
            (match il with
            |IdL (ils, il2) -> search_idl ((EID ils, tt1)::g) il2 tt2
            |Nil -> ((EID s, t2)::gam))
        |ParenTy p -> search_idl g il p
        |UserTy s2 -> let rec search_gamma (g: (expr*typ) list) =
            (match g with
                |[]-> raise(TypeError("id " ^ s2 ^ " not defined before use"))
                |(EID i, t)::r ->  if i = s2 then (match il with
                    |IdL (ils, il2) -> search_idl ((EID ils, t)::g) il2 t
                    |Nil -> ((EID s, t)::gam))
                    else search_gamma r
                | _::r -> search_gamma r)
                in search_gamma g
        |_ -> raise(TypeError("too many vars for given type in match: " ^ typ_to_str t2)))
        in search_idl gam idl t


 let rec check_typ_expr(gamma: (expr*typ) list)(e: expr) : typ =
    match e with
        | EMatch (e1, p) -> let t = check_typ_expr gamma e1 in let rec search_pipes ps =
            (match ps with
                |Pipep b -> (match b with
                    |Branch (s,e2) -> (match t with
                        |TuplTy (_, _) -> let rec search_tup t4 =
                            (match t4 with
                            |TuplTy (TuplTy(UserTy s2, t5), r) -> if s = s2 then t5 else search_tup r
                            |TuplTy (UserTy s2, t5) -> if s = s2 then t5 else raise(TypeError( s ^ " not defined before matching: " ^ print_gamma gamma))
                            |_ -> raise(TypeError("agh")))
                            in search_tup t
                        |FuncTy (_, _) -> raise(TypeError("EMatch error at: " ^ s ^ ";; " ^ typ_to_str t ^ ";; " ^ print_gamma gamma))
                        |UserTy i2 -> let rec search_gamma (g: (expr*typ) list) =
                            (match g with
                                |[]-> raise(TypeError("UserTy " ^ s ^ " not defined before use"))
                                |(EID i, t)::r ->  if i = i2 then if s = i then check_typ_expr ((EID i2, t)::gamma) e2 else search_gamma r else search_gamma r
                                | _::r -> search_gamma r)
                                in search_gamma gamma
                        |ParenTy t2 -> get_typs gamma t2
                        | _ -> check_typ_expr ((EID s, t)::gamma) e2)
                    |Branchs (_, v, e2) -> if search_vars gamma v t then check_typ_expr (add_vars gamma v t) e2 else raise(TypeError("not all EMatch types are matching")))
                |Pipesp (b,p3) -> (match b with
                    |Branch (s,e2) -> if check_typ_expr ((EID s, t)::gamma) e2 = search_pipes p3 then check_typ_expr ((EID s, t)::gamma) e2 else raise(TypeError("not all EMatch types are matching: " ^ s ^ " => " ^ print_expr e2 ^ ";; " ^ print_gamma gamma ^ ";; " ^ typ_to_str(check_typ_expr ((EID s, t)::gamma) e2) ^ " vs. " ^typ_to_str (search_pipes p3)))
                    |Branchs (_,v,e2) -> if search_vars gamma v t then if check_typ_expr (add_vars gamma v t) e2 = search_pipes p3 then check_typ_expr gamma e2 else raise(TypeError("not all EMatch types are matching")) else raise(TypeError("not all EMatch types are matching"))))
            in search_pipes p
        | EInt _ -> IntTy
        | ETrue -> BoolTy
        | EFalse -> BoolTy
        | EVar _ -> StringTy
        | EID i -> let rec search_gamma (g: (expr*typ) list) =
            (match g with
                |[]-> raise(TypeError("id " ^ i ^ " not defined before use: " ^ print_gamma gamma))
                |(EID i2, t)::r -> if i = i2 then t else search_gamma r
                |(EVar v,t)::r -> if v = i then t else search_gamma r
                | _::r -> search_gamma r)
                in search_gamma gamma
        | EUnit -> UnitTy
        | EParen e1 -> check_typ_expr gamma e1
        | UNot e1 -> if check_typ_expr gamma e1 = BoolTy then BoolTy else raise(TypeError(print_expr (UNot e1) ^ " is not a bool"))
        | Squig e1 -> if check_typ_expr gamma e1 = IntTy then IntTy else raise(TypeError(print_expr (UNot e1) ^ " is not an int"))
        | BPlus (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Adding non-integers at " ^ print_expr (BPlus(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Adding non-integers " ^ print_expr e)))
            |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Adding non-integers at " ^ print_expr (BPlus(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Adding non-integers " ^ print_expr e)))
                else raise(TypeError("Adding non-integers at " ^ print_expr (BPlus(e1,e2))))
            |NilTy -> (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Adding non-integers at " ^ print_expr (BLt(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Adding non-integers " ^ print_expr e)))
            |_ -> raise(TypeError("Adding non-integers at " ^ print_expr e)))
        | BMinus (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Subtracting non-integers at " ^ print_expr (BMinus(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Subtracting non-integers " ^ print_expr e)))
            |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Subtracting non-integers at " ^ print_expr (BMinus(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Subtracting non-integers " ^ print_expr e)))
                else raise(TypeError("Subtracting non-integers at " ^ print_expr (BMinus(e1,e2))))
            |NilTy -> (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Subtracting non-integers at " ^ print_expr (BLt(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Subtracting non-integers " ^ print_expr e)))
            |_ -> raise(TypeError("Subtracting non-integers at " ^ print_expr e)))
        | BTimes (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Multiplying non-integers at " ^ print_expr (BTimes(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Multiplying non-integers " ^ print_expr e)))
            |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Multiplying non-integers at " ^ print_expr (BTimes(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Multiplying non-integers " ^ print_expr e)))
                else raise(TypeError("Multiplying non-integers at " ^ print_expr (BTimes(e1,e2))))
            |NilTy -> (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Multiplying non-integers at " ^ print_expr (BLt(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Multiplying non-integers " ^ print_expr e)))
            |_ -> raise(TypeError("Multiplying non-integers at " ^ print_expr e)))
        | BDivide (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Dividing non-integers at " ^ print_expr (BDivide(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Dividing non-integers at " ^ print_expr e)))
            |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Dividing non-integers at " ^ print_expr (BDivide(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Dividing non-integers at " ^ print_expr e)))
                else raise(TypeError("Dividing non-integers at " ^ print_expr (BDivide(e1,e2))))
            |NilTy -> (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Dividing non-integers at " ^ print_expr (BLt(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Dividing non-integers at " ^ print_expr e)))
            |_ -> raise(TypeError("Dividing non-integers at " ^ print_expr e)))
        | BMod (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Modding non-integers at " ^ print_expr (BMod(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Modding non-integers at " ^ print_expr e)))
            |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Modding non-integers at " ^ print_expr (BMod(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Modding non-integers at " ^ print_expr e)))
                else raise(TypeError("Modding non-integers at " ^ print_expr (BMod(e1,e2))))
            |NilTy -> (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Modding non-integers at " ^ print_expr e))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Modding non-integers at " ^ print_expr e)))
            |_ -> raise(TypeError("Modding non-integers at " ^ print_expr e)))
        | BLt (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Comparing non-integers at " ^ print_expr (BLt(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Comparing non-integers at " ^ print_expr e)))
            |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Comparing non-integers at " ^ print_expr (BLt(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Comparing non-integers at " ^ print_expr e)))
                else raise(TypeError("Comparing non-integers at " ^ print_expr (BLt(e1,e2))))
            |NilTy -> (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Comparing non-integers at " ^ print_expr (BLt(e1,e2))))
                |NilTy -> IntTy
                |_ -> raise(TypeError("Comparing non-integers at " ^ print_expr e)))
            |_ -> raise(TypeError("Comparing non-integers at " ^ print_expr e)))
        | BEq (e1,e2) -> if check_typ_expr gamma e1 = check_typ_expr gamma e2 then BoolTy
            else raise(TypeError("Comparing different types at " ^ print_expr (BEq(e1,e2))))
        | BConcat (e1,e2) -> (match check_typ_expr gamma e1 with
            |StringTy -> (match check_typ_expr gamma e2 with
                |StringTy -> StringTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = StringTy then StringTy
                    else raise(TypeError("concatting non-strings at " ^ print_expr (BConcat(e1,e2))))
                |NilTy -> StringTy
                |_ -> raise(TypeError("concatting non-strings at " ^ print_expr e)))
            |FuncTy (_, f2) -> if check_return_typ_functy f2 = StringTy then (match check_typ_expr gamma e2 with
                |StringTy -> StringTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = StringTy then StringTy
                    else raise(TypeError("concatting non-strings at " ^ print_expr (BConcat(e1,e2))))
                |NilTy -> StringTy
                |_ -> raise(TypeError("concatting non-strings at " ^ print_expr e)))
                else raise(TypeError("concatting non-strings at " ^ print_expr (BConcat(e1,e2))))
            |NilTy -> (match check_typ_expr gamma e2 with
                |StringTy -> StringTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = StringTy then StringTy
                    else raise(TypeError("concatting non-strings at " ^ print_expr e))
                |NilTy -> StringTy
                |_ -> raise(TypeError("concatting non-strings at " ^ print_expr e)))
            |_ -> raise(TypeError("concatting non-strings at " ^ print_expr e)))
        | BAnd (e1,e2) -> (match check_typ_expr gamma e1 with
            |BoolTy -> (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr (BAnd(e1,e2))))
                |NilTy -> BoolTy
                |_ -> raise(TypeError("comparing non-bools at " ^ print_expr e)))
            |FuncTy (_, f2) -> if check_return_typ_functy f2 = BoolTy then (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr (BAnd(e1,e2))))
                |NilTy -> BoolTy
                |_ -> raise(TypeError("comparing non-bools at " ^ print_expr e)))
                else raise(TypeError("comparing non-bools at " ^ print_expr (BAnd(e1,e2))))
            |NilTy -> (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr e))
                |NilTy -> BoolTy
                |_ -> raise(TypeError("comparing non-bools at " ^ print_expr e)))
            |_ -> raise(TypeError("comparing non-bools at " ^ print_expr e)))
        | BOr (e1,e2) -> (match check_typ_expr gamma e1 with
            |BoolTy -> (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr (BOr(e1,e2))))
                |NilTy -> BoolTy
                |_ -> raise(TypeError("comparing non-bools at " ^ print_expr e)))
            |FuncTy (_, f2) -> if check_return_typ_functy f2 = BoolTy then (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr (BOr(e1,e2))))
                |NilTy -> BoolTy
                |_ -> raise(TypeError("comparing non-bools at " ^ print_expr e)))
                else raise(TypeError("comparing non-bools at " ^ print_expr (BOr(e1,e2))))
            |NilTy -> (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (_, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr e))
                |NilTy -> BoolTy
                |_ -> raise(TypeError("comparing non-bools at " ^ print_expr e)))
            |_ -> raise(TypeError("comparing non-bools at " ^ print_expr e)))
        | EFuncApp (e1, e2) -> (match e1 with
            |EID s -> let rec search_gamma (g: (expr*typ) list) =
                (match g with
                    |[]-> raise(TypeError("function " ^ s ^ " not defined before use"))
                    |(EID d, t)::r -> if d = s then let rec help l h =
                        (match h with
                        | EList (el1, el2) -> (match l with
                                |FuncTy (f1, f2) -> if check_typ_expr gamma el1 = f1 then check_return_typ_functy l else help f2 el2
                                |_ -> check_return_typ_functy l)
                        | EListEnd _ -> (match l with
                                |FuncTy (_, _) -> check_return_typ_functy l
                                |_ -> check_return_typ_functy l)
                        | _ -> t )
                        in help (check_typ_expr gamma e1) e2
                        else search_gamma r
                    | _::r -> search_gamma r)
                    in search_gamma gamma
            |_ -> raise(TypeError("FuncApp with no id as first input")))
        | EFun (p, pl, t, e1) -> if t = NilTy then (match p with
            |P s -> let g = check_typ_param_lst gamma pl in check_typ_expr ((EID s, NilTy)::g) e1
            |Ps (s, t2) -> let g = check_typ_param_lst gamma pl in let h = pl_typ_func pl t2 in check_typ_expr ((EID s, h)::g) e1)
            else (match p with
                |P s -> let g = check_typ_param_lst gamma pl in if check_typ_expr ((EID s, NilTy)::g) e1 = t then t else raise(TypeError(print_expr e1 ^ " returns " ^ typ_to_str (check_typ_expr ((EID s, NilTy)::g) e1) ^ ", not the expected " ^ typ_to_str t))
                |Ps (s, t2) -> let g = check_typ_param_lst gamma pl in let h = pl_typ_func pl t2 in if check_typ_expr ((EID s, h)::g) e1 = t then t else raise(TypeError(print_expr e1 ^ " returns " ^ typ_to_str (check_typ_expr ((EID s, NilTy)::g) e1) ^ ", not the expected " ^ typ_to_str t)))
        | EIf (e1, e2, e3) -> (match check_typ_expr gamma e1 with
            |BoolTy -> if check_typ_expr gamma e2 = check_typ_expr gamma e3 then check_typ_expr gamma e2 else raise(TypeError( print_expr e2 ^ " and " ^ print_expr e3 ^ " have different types"))
            |_ -> raise(TypeError( print_expr e1 ^ " is not a bool")))
        | ELetRec (s,pl,t,e1,e2) -> if t = NilTy then let g = pl_typ_func pl (check_typ_expr gamma e1) in check_typ_expr ((EID s,g)::gamma) e2 else check_typ_expr ((EID s,t)::gamma) e2
        | ELet (s,pl,t,e1,e2) -> if t = NilTy then let g = pl_typ_func pl (check_typ_expr gamma e1) in check_typ_expr ((EID s,g)::gamma) e2 else check_typ_expr ((EID s,t)::gamma) e2
        | _ -> raise(TypeError("item not given a good E-type"))

 let check_type (pr: prog) =
    let rec helper(gamma: (expr*typ) list)(p: prog) =
        match p with
        |EndMain b -> (match b with
            |TypeBind (s, p) -> if let rec help pip =
                (match pip with
                |Pipe_typ b -> (match b with
                    |BranchId _ -> true
                    |BranchIdTyp (_,t) -> (match t with
                        |UserTy s2 -> let rec search_gamma (g: (expr*typ) list) =
                            (match g with
                                |[]-> raise(TypeError("id " ^ s2 ^ " not defined before use"))
                                |(EID i, _)::r ->  if i = s2 then true else search_gamma r
                                | _::r -> search_gamma r)
                                in search_gamma ((EID s, UserTy s)::gamma)
                        |_ -> true))
                |Pipes_typ (b, p2) -> (match b with
                    |BranchId _ -> help p2
                    |BranchIdTyp (_,t) -> (match t with
                        |UserTy s2 -> let rec search_gamma (g: (expr*typ) list) =
                            (match g with
                                |[]-> raise(TypeError("id " ^ s2 ^ " not defined before use"))
                                |(EID i, _)::r ->  if i = s2 then help p2 else search_gamma r
                                | _::r -> search_gamma r)
                                in search_gamma ((EID s, UserTy s)::gamma)
                        |_ -> help p2))) in help p then UserTy s else raise(TypeError("hjgg"))
            |FuncBindRec (s,pl,t,e) -> let check_typ = let g = check_typ_param_lst gamma pl in pl_typ_func pl (check_typ_expr ((EID s, t)::g) e) in if t = NilTy then check_typ else if check_typ = pl_typ_func pl t then pl_typ_func pl t else raise(TypeError("Expected " ^ (typ_to_str (pl_typ_func pl t)) ^ " but got " ^ (typ_to_str check_typ)))
            |FuncBind (_,pl,t,e) -> let check_typ = let g = check_typ_param_lst gamma pl in pl_typ_func pl (check_typ_expr g e) in if t = NilTy then check_typ else if check_typ = pl_typ_func pl t then pl_typ_func pl t else raise(TypeError("Expected " ^ (typ_to_str (pl_typ_func pl t)) ^ " but got " ^ (typ_to_str check_typ))))
        |Main (b, p2) -> (match b with
            |TypeBind (s, p) -> let cp = check_typ_pipes_typ ((EID s, UserTy s)::gamma) p in helper ((EID s, get_typ_pipes_typ ((EID s, UserTy s)::gamma) p)::cp) p2
            |FuncBindRec (s,pl,t,e) -> if t = NilTy then let g = check_typ_param_lst gamma pl in let t2 = pl_typ_func pl (check_typ_expr ((EID s, t)::g) e) in helper ((EID s,t2)::gamma) p2 else helper ((EID s,(pl_typ_func pl t))::gamma) p2
            |FuncBind (s,pl,t,e) -> if t = NilTy then let g = check_typ_param_lst gamma pl in let t2 = pl_typ_func pl (check_typ_expr g e) in helper ((EID s,t2)::gamma) p2 else helper ((EID s,(pl_typ_func pl t))::gamma) p2)
    in helper [] pr
