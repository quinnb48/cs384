open Ast

exception TypeError of string

(*
let check_type (lc: lc_expr) =
    let rec helper(gamma: (lc_expr*typ) list)(l: lc_expr) =
        match l with
        | EInt e -> IntTy
        | ETrue -> BoolTy
        | EFalse -> BoolTy
        | EUnit -> UnitTy
        | EVar v -> let rec search_gamma (g: (lc_expr*typ) list) =
            (match g with
                |[]-> raise(TypeError("var not given a type in gamma"))
                |(EVar v,t)::r -> t
                | h::r -> search_gamma r)
                in search_gamma gamma
        | ELambda(p,t,b) -> let t2 = helper ((EVar p,t)::gamma) b in FuncTy (t, t2)
        | EApp(a,b) -> (match helper gamma a with
                |FuncTy (t1, t2) -> if t1 = helper gamma b then t2 else
                    raise(TypeError("wrong type to a function type"))
                |_ -> raise(TypeError("EApp is not given a function type")))
    in helper [] lc
 *)
 let int_of_string (s: string) : int =
    TODO

 let string_of_int (i : expr): string =
    match i with
    |EInt t -> string_of_int t
    | _ -> raise(TypeError(print_expr i ^ " is not an int"))

 let print_string (s: string) : unit =
    TODO

 let rec check_typ_pipes_typ (gamma: (prog*typ) list)(p: pipes_typ) : (prog*typ) list= (* adds pipes_typs to gamma*)
    match p with
    |Pipe_typ b -> (match b with
        |BranchId i -> ((EID i, NilTy)::gamma)
        |BranchIdTyp (i,t) -> ((EID i, t)::gamma))
    |Pipes_typ (b, p2) -> (match b with
        |BranchId i -> check_typ_pipes_typ ((EID i, NilTy)::gamma) p2
        |BranchIdTyp (i,t) -> check_typ_pipes_typ ((EID i, t)::gamma) p2)

(* let rec check_typ_pipes (gamma: (prog*typ) list)(p: pipes_typ)=
    let helper (t: (expr*expr) list) (pip: pipes_typ)  =
        match pip with
            |Pipep b -> (match b with
                |Branch (s,e) -> ((s,EUnit)::t)
                |Branchs (s, v ,e) -> ((s,v)::t)
            |Pipesp (b,p) -> (match b with
                |Branch (s,e) -> helper ((s,EUnit)::t) p
                |Branchs (s, v ,e) -> helper ((s,v)::t) p
    in helper [] p *)

 let rec check_typ_param_lst(gamma: (prog*typ) list)(pl: param_lst) : (prog*typ) list=    (* adds params to gamma*)
    match pl with
        |Nil -> []
        |PLS (p,pl2) -> (match p with
            |P s -> check_typ_param_lst ((EID s, NilTy)::gamma) pl2
            |Ps (s, t) -> check_typ_param_lst ((EID s, t)::gamma) pl2)

let rec check_return_typ_functy (f: typ) =
    match f with
    |FuncTy(_,FuncTy(t1,t2)) -> check_return_typ_functy FuncTy(t1,t2)
    |FuncTy(_, t2) -> t2
    |_ -> raise(TypeError(typ_to_str f ^ " is not a FuncTy"))


 let rec check_typ_expr(gamma: (prog*typ) list)(e: expr)=
    match e with
        (* needs editing *)
        | EMatch (e1, p) -> TODO  (* (match e1 with
            |EID v -> let helpy (pip: pipes_typ)  =
                (match pip with
                    |Pipep b -> (match b with
                        |Branch (s,e2) -> if v = s then check_typ_expr gamma e2 else UnitTy
                        |Branchs (s, v2 ,e2) -> UnitTy
                    |Pipesp (b,p) -> (match b with
                        |Branch (s,e2) -> if v = s then check_typ_expr gamma e2 else helpy p
                        |Branchs (_, _, _) -> helpy p
                in helpy p
            |EFuncApp(i, EListEnd e2) -> let helpy2 (pip: pipes_typ)  =
                (match pip with
                    |Pipep b -> (match b with
                        |Branch (_, _) -> UnitTy
                        |Branchs (s, v2 ,e3) -> if v = s then (match v2 with
                            |Name o -> if e2 = o then check_typ_expr gamma e2 else UnitTy
                            |NameList -> UnitTy)
                    |Pipesp (b,p) -> (match b with
                        |Branch (_, _) -> helpy2 p
                        |Branchs (s, v2 ,e3) -> if v = s then (match v2 with
                            |Name o -> if e2 = o then check_typ_expr gamma e2 else helpy2 p
                            |NameList -> helpy2 p)
                in helpy2 p)
            |EFuncApp(i, EList (e2, e3)) -> let helpy3 (pip: pipes_typ)  =
                (match pip with
                    |Pipep b -> (match b with
                        |Branch (_, _) -> UnitTy
                        |Branchs (s, v2 ,e4) -> if v = s then (match v2 with
                            |Name o -> if e2 = o then check_typ_expr e2 else UnitTy
                            |NameList -> UnitTy)
                    |Pipesp (b,p) -> (match b with
                        |Branch (_, _) -> helpy3 p
                        |Branchs (s, v2 ,e4) -> if v = s then (match v2 with
                            |Name o -> if e2 = o then check_typ_expr e2 else helpy3 p
                            |NameList -> helpy3 p)
                in helpy3 p) *)
        | EInt i -> IntTy
        | ETrue -> BoolTy
        | EFalse -> BoolTy
        | EVar i -> let rec search_gamma (g: (prog*typ) list) =
            (match g with
                |[]-> raise(TypeError("var " ^ i ^ " not defined before use"))
                |(EVar i,t)::r -> t
                |(EID d, t)::r -> if d = i then t else search_gamma r
                | h::r -> search_gamma r)
                in search_gamma gamma
        | EID i -> let rec search_gamma (g: (prog*typ) list) =
            (match g with
                |[]-> raise(TypeError("id " ^ i ^ " not defined before use"))
                |(EID i, t)::r -> t
                |(EVar v,t)::r -> if v = i then t else search_gamma r
                | h::r -> search_gamma r)
                in search_gamma gamma
        | EUnit -> UnitTy
        | EParen e1 -> check_typ_expr gamma e1
        | UNot e1 -> check_typ_expr gamma e1
        | Squig e1 -> check_typ_expr gamma e1
        | BPlus (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Adding non-integers at " ^ print_expr BPlus(e1,e2))))
            |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Adding non-integers at " ^ print_expr BPlus(e1,e2))))
                else raise(TypeError("Adding non-integers at " ^ print_expr BPlus(e1,e2))))
        | BMinus (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Subtracting non-integers at " ^ print_expr BMinus(e1,e2))))
            |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Subtracting non-integers at " ^ print_expr BMinus(e1,e2))))
                else raise(TypeError("Subtracting non-integers at " ^ print_expr BMinus(e1,e2))))
        | BTimes (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Multiplying non-integers at " ^ print_expr BTimes(e1,e2))))
            |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Multiplying non-integers at " ^ print_expr BTimes(e1,e2))))
                else raise(TypeError("Multiplying non-integers at " ^ print_expr BTimes(e1,e2))))
        | BDivide (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Dividing non-integers at " ^ print_expr BDivide(e1,e2))))
            |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Dividing non-integers at " ^ print_expr BDivide(e1,e2))))
                else raise(TypeError("Dividing non-integers at " ^ print_expr BDivide(e1,e2))))
        | BMod (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Modding non-integers at " ^ print_expr BMod(e1,e2))))
            |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> IntTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then IntTy
                    else raise(TypeError("Modding non-integers at " ^ print_expr BMod(e1,e2))))
                else raise(TypeError("Modding non-integers at " ^ print_expr BMod(e1,e2))))
        | BLt (e1,e2) -> (match check_typ_expr gamma e1 with
            |IntTy -> (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Comparing non-integers at " ^ print_expr BLt(e1,e2))))
            |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then (match check_typ_expr gamma e2 with
                |IntTy -> BoolTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = IntTy then BoolTy
                    else raise(TypeError("Comparing non-integers at " ^ print_expr BLt(e1,e2))))
                else raise(TypeError("Comparing non-integers at " ^ print_expr BLt(e1,e2))))
        | BEq (e1,e2) -> if check_typ_expr gamma e1 =  check_typ_expr gamma e2 then BoolTy
            else raise(TypeError("Comparing different types at " ^ print_expr BEq(e1,e2)))
        | BConcat (e1,e2) -> (match check_typ_expr gamma e1 with
            |StringTy -> (match check_typ_expr gamma e2 with
                |StringTy -> StringTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = StringTy then StringTy
                    else raise(TypeError("concatting non-strings at " ^ print_expr BConcat(e1,e2))))
            |FuncTy (f1, f2) -> if check_return_typ_functy f2 = StringTy then (match check_typ_expr gamma e2 with
                |StringTy -> StringTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = StringTy then StringTy
                    else raise(TypeError("concatting non-strings at " ^ print_expr BConcat(e1,e2))))
                else raise(TypeError("concatting non-strings at " ^ print_expr BConcat(e1,e2))))
        | BAnd (e1,e2) -> (match check_typ_expr gamma e1 with
            |BoolTy -> (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr BAnd(e1,e2))))
            |FuncTy (f1, f2) -> if check_return_typ_functy f2 = BoolTy then (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr BAnd(e1,e2))))
                else raise(TypeError("comparing non-bools at " ^ print_expr BAnd(e1,e2))))
        | BOr (e1,e2) -> (match check_typ_expr gamma e1 with
            |BoolTy -> (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr BOr(e1,e2))))
            |FuncTy (f1, f2) -> if check_return_typ_functy f2 = BoolTy then (match check_typ_expr gamma e2 with
                |BoolTy -> BoolTy
                |FuncTy (f1, f2) -> if check_return_typ_functy f2 = BoolTy then BoolTy
                    else raise(TypeError("comparing non-bools at " ^ print_expr BOr(e1,e2))))
                else raise(TypeError("comparing non-bools at " ^ print_expr BOr(e1,e2))))

            (* needs editing *)
        | EFuncApp (e1, e2) -> (match e1 with
            |EID s -> let rec search_gamma (g: (prog*typ) list) =
                (match g with
                    |[]-> raise(TypeError("function " ^ s ^ " not defined before use"))
                    |(EID d, t)::r -> if d = s then (match e2 with
                        | EList (el1, el2) -> TODO          (* somehow record params for a function to match these correctly? *)
                        | EListEnd e -> TODO (* then t else raise(TypeError("function " ^ s ^ " not defined before use" )) *)
                        | _ -> t)
                        else search_gamma r  (* need to check params also?*)
                    | h::r -> search_gamma r)
                    in search_gamma gamma
            |_ -> raise(TypeError("FuncApp with no id as first input")))
        | EFun (p, pl, t, e1) -> if t = NilTy then (match p with
            |P s -> let g = check_typ_param_lst [] pl in check_typ_expr ((EID s, NilTy)::g::gamma) e1
            |Ps (s, t2) -> let g = check_typ_param_lst [] pl in check_typ_expr ((EID s, t2)::g::gamma) e1) else t
        | EIf (e1, e2, e3) -> (match check_typ_expr gamma e1 with
            |BoolTy -> if interpret_expr e1 = true then check_typ_expr gamma e2 else check_typ_expr gamma e3
            |_ -> raise(TypeError( print_expr e1 ^ " not a bool")))

            (* needs editing: these should have type ((pl types) -> return type of e1), inputted to e2*)
        | ELetRec (s,pl,t,e1,e2) -> if t = NilTy then let g = check_typ_expr gamma e1 in let h = check_typ_param_lst [] pl in check_typ_expr ((s,g)::h::gamma) e2 else check_typ_expr ((s,t)::gamma) e2
        | ELet (s,pl,t,e1,e2) -> if t = NilTy then let g = check_typ_expr gamma e1 in let h = check_typ_param_lst [] pl in check_typ_expr ((s,g)::h::gamma) e2 else check_typ_expr ((s,t)::gamma) e2
        | _ -> raise(TypeError("item not given a good E-type"))

 let check_type (pr: prog) =
    let rec helper(gamma: (prog*typ) list)(p: prog) =
        match p with
        |Main b -> (match b with
            |TypeBind (s, p) -> UserTy s
                (* needs editing: these should have type ((pl types) -> return type of e) *)
            |FuncBindRec (s,pl,t,e) -> if t = NilTy then let g = check_typ_param_lst [] pl in check_typ_expr (g::gamma) e else t
            |FuncBind (s,pl,t,e) -> if t = NilTy then let g = check_typ_param_lst [] pl in check_typ_expr (g::gamma) e else t)
        |EndMain (b, p2) -> (match b with
            |TypeBind (s, p) -> let cp = check_typ_pipes_typ gamma p in let UG = ((EID s, UserTy)::cp::gamma) in helper UG p2
                (* needs editing: these should have type ((pl types) -> return type of e) *)
            |FuncBindRec (s,pl,t,e) -> if t = NilTy then let g = check_typ_param_lst [] pl in let t2 = check_typ_expr (g::gamma) e in helper ((EID s,t2)::gamma) p2 else helper ((EID s,t)::gamma) p2
            |FuncBind (s,pl,t,e) -> if t = NilTy then let g = check_typ_param_lst [] pl in let t2 = check_typ_expr (g::gamma) e in helper ((EID s,t2)::gamma) p2 else helper ((EID s,t)::gamma) p2)
    in helper [] pr
