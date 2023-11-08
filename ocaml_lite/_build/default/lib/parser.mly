%{
open Ast
%}

%token Type             (** type - keyword *)
%token Of               (** of - keyword *)
%token Let              (** let - keyword *)
%token Rec              (** rec - keyword *)
%token In               (** in - keyword *)
%token If               (** if - keyword *)
%token Then             (** then - keyword *)
%token Else             (** else - keyword *)
%token Match            (** match - keyword *)
%token With             (** with - keyword *)
%token Fun              (** fun - keyword *)
%token True             (** true - keyword *)
%token False            (** false - keyword *)
%token Mod              (** mod - keyword *)
%token TInt             (** int - type name *)
%token TBool            (** bool - type name *)
%token TString          (** string - type name *)
%token TUnit            (** unit - type name *)
%token Eq               (** = - binary operator *)
%token Plus             (** + - binary operator *)
%token Minus            (** - - binary operator *)
%token Times            (** * - binary operator *)
%token Divide           (** / - binary operator *)
%token Lt               (** < - binary operator *)
%token Concat           (** ^ - binary operator *)
%token And              (** && - binary operator *)
%token Or               (** || - binary operator *)
%token Not              (** ! - unary operator *)
%token Negate           (** ~ - unary operator *)
%token DoubleSemicolon  (** ;; *)
%token Colon            (** : *)
%token Arrow            (** -> *)
%token DoubleArrow      (** => *)
%token LParen           (** ( *)
%token RParen           (** ) *)
%token Pipe             (** | *)
%token Comma            (** , *)
%token <string> Id      (** Identifier, like a variable or function name *)
%token <int> Int        (** Integer literal *)
%token <string> String  (** String literal *)
%token EOF              (** End-of-file - you can ignore this *)

%nonassoc Else
%right Arrow
%nonassoc DoubleArrow
%left Or
%left And
%right Pipe
%left Lt Eq
%right Concat
%left Minus
%left Plus
%left Times Divide Mod
%left In
%left Negate
%nonassoc Not


%start <prog> progp

%type <bind> bindp
%type <expr> exprp
%type <expr> func_app
%type <expr_lst> expr_lstp
%type <pipes> pipesp
%type <branch> branchp
%type <pipes_typ> typ_pipesp
%type <branch_typ> typ_branchp
%type <vars> varsp
%type <param> paramp
%type <param_lst> param_lstp
%type <id_lst> id_lstp
%type <typ> typp


(* <program> ::= [<binding> ;;]+

<binding> ::= let $id [<param>]* [: <type>] = <expr>
            | let rec $id [<param>]* [: <type>] = <expr>
            | type $id = ['|' $id [of <type>]]+

<param> ::= $id
          | ( $id : <type> )

<expr> ::= let $id [<param>]* [: <type>] = <expr> in <expr>
         | let rec $id [<param>]* [: <type>] = <expr> in <expr>
         | if <expr> then <expr> else <expr>
         | fun [<param>]+ [: <type>] => <expr>
         | ($id <func_app>)
         | ( <expr> [, <expr>]+ )
         | <expr> <binop> <expr>
         | <unop> <expr>
         | ( <expr> )
         | $int
         | true
         | false
         | $string
         | $id
         | ( )
         | match <expr> with ['|' <match_branch>]+

<func_app> ::= <expr> | <expr> <func_app>

<binop> ::= + | - | * | / | mod | < | = | ^ | && | ||

<unop> ::= not | ~

<type> ::= <type> -> <type>
         | ( <type> )
         | <type> * <type>
         | int
         | bool
         | string
         | unit
         | $id

<match_branch> ::= $id [<pattern_vars>] => <expr>

<pattern_vars> ::= $id
                          | ( $id [, $id ]+)
*)

%%
progp:
    | b = bindp; DoubleSemicolon; p = progp;          { Main (b,p) }
    | b = bindp; DoubleSemicolon; EOF                 { EndMain b }

bindp:
    |Let; s = Id; p = param_lstp; Colon; t = typp; Eq; e = exprp;        { FuncBind (s, p, t, e) }
    |Let; s = Id; p = param_lstp; Eq; e = exprp;                  { FuncBind (s, p, NilTy, e) } (* option for if inferring type*)
    |Let; s = Id; Colon; t = typp; Eq; e = exprp;                 { FuncBind (s, Nil, t, e) }
    |Let; s = Id; Eq; e = exprp;                                  { FuncBind (s, Nil, NilTy, e) } (* option for if inferring type*)
    |Let; Rec; s = Id; p = param_lstp; Colon; t = typp; Eq; e = exprp;   { FuncBindRec (s, p, t, e) }
    |Let; Rec; s = Id; p = param_lstp; Eq; e = exprp;             { FuncBindRec (s, p, NilTy, e) } (* option for if inferring type*)
    |Let; Rec; s = Id; Colon; t = typp; Eq; e = exprp;            { FuncBindRec (s, Nil, t, e) }
    |Let; Rec; s = Id; Eq; e = exprp;                             { FuncBindRec (s, Nil, NilTy, e) } (* option for if inferring type*)
    |Type; s = Id; Eq; p = typ_pipesp;                            { TypeBind (s, p)}

exprp:
    |Let; i = Id; p = param_lstp; Colon; t = typp; Eq; e = exprp; In; e2 = exprp;       { ELet(i,p,t,e,e2) }
    |Let; i = Id; p = param_lstp; Eq; e = exprp; In; e2 = exprp;        { ELet(i,p,NilTy,e,e2) }  (* option for if inferring type*)
    |Let; i = Id; Colon; t = typp; Eq; e = exprp; In; e2 = exprp;       { ELet(i,Nil,t,e,e2) }
    |Let; i = Id; Eq; e = exprp; In; e2 = exprp;                        { ELet(i,Nil,NilTy,e,e2) }  (* option for if inferring type*)
    |Let; Rec; i = Id; p = param_lstp; Colon; t = typp; Eq; e = exprp; In; e2 = exprp;  { ELetRec(i,p,t,e,e2) }
    |Let; Rec; i = Id; p = param_lstp; Eq; e = exprp; In; e2 = exprp;    { ELetRec(i,p,NilTy,e,e2) }  (* option for if inferring type*)
    |Let; Rec; i = Id; Colon; t = typp; Eq; e = exprp; In; e2 = exprp;   { ELetRec(i,Nil,t,e,e2) }
    |Let; Rec; i = Id; Eq; e = exprp; In; e2 = exprp;                { ELetRec(i,Nil,NilTy,e,e2) }  (* option for if inferring type*)
    |If; e = exprp; Then; e2 = exprp; Else; e3 = exprp;              { EIf(e,e2,e3) }
    |Fun; p = paramp; pl = param_lstp; Colon; t = typp; DoubleArrow; e = exprp; { EFun(p,pl,t,e) }
    |Fun; p = paramp; pl = param_lstp; DoubleArrow; e = exprp;       { EFun(p,pl,NilTy,e) }     (* option for if inferring type*)
    |Fun; p = paramp; Colon; t = typp; DoubleArrow; e = exprp;       { EFun(p,Nil,t,e) }
    |Fun; p = paramp; DoubleArrow; e = exprp;                        { EFun(p,Nil,NilTy,e) }     (* option for if inferring type*)
    |LParen; i = Id; f = func_app; RParen;                           { EFuncApp (EID i, f) }
    |LParen; e = exprp; Comma; e2 = exprp; l = expr_lstp;            { EVars(e,e2,l) }
    |e = exprp; Plus; e2 = exprp;                                    { BPlus(e,e2) }
    |e = exprp; Minus; e2 = exprp;                                   { BMinus(e,e2) }
    |e = exprp; Times; e2 = exprp;                                   { BTimes(e,e2) }
    |e = exprp; Divide; e2 = exprp;                                  { BDivide(e,e2) }
    |e = exprp; Mod; e2 = exprp;                                     { BMod(e,e2) }
    |e = exprp; Lt; e2 = exprp;                                      { BLt(e,e2) }
    |e = exprp; Eq; e2 = exprp;                                      { BEq(e,e2) }
    |e = exprp; Concat; e2 = exprp;                                  { BConcat(e,e2) }
    |e = exprp; And; e2 = exprp;                                     { BAnd(e,e2) }
    |e = exprp; Or; e2 = exprp;                                      { BOr(e,e2) }
    |Not; e = exprp;                                                 { UNot e }
    |Negate; e = exprp;                                              { Squig e }
    |LParen; e = exprp; RParen;                                      { EParen e }
    |i = Int;                                                        { EInt i }
    |True;                                                           { ETrue }
    |False;                                                          { EFalse }
    |i = Id;                                                         { EID i }
    |s = String;                                                     { EVar s }
    |LParen; RParen;                                                 { EUnit }
    |Match; e = exprp; With; p = pipesp;                             { EMatch (e,p) }

func_app:
    |e = exprp; f = func_app;                                        { EList (e,f) }
    |e = exprp;                                                      { EListEnd e }


expr_lstp:
    | RParen;                                         { Nil }
    | Comma; e = exprp; l = expr_lstp;                { ExprL (e,l) }

pipesp:
    | Pipe; b = branchp;                             { Pipep b }
    | Pipe; b = branchp; p = pipesp;                 { Pipesp (b, p) }

branchp:
    | i = Id; v = varsp; DoubleArrow; e = exprp;    { Branchs (i, v, e) }
    | i = Id; DoubleArrow; e = exprp;               { Branch (i, e)}

typ_pipesp:
    | Pipe; b = typ_branchp;                         { Pipe_typ b }
    | Pipe; b = typ_branchp; p = typ_pipesp;         { Pipes_typ (b, p) }

typ_branchp:
    |i = Id;                                        { BranchId i }
    |i = Id; Of; t = typp;                          { BranchIdTyp (i,t) }

varsp:
    |i = Id;                                        { Name i }
    |LParen; i = Id; l = id_lstp;                   { NameList (i, l)}

paramp:
    | s = Id;                                       { P s }
    | LParen; s = Id; Colon; t = typp; RParen;      { Ps (s,t) }

param_lstp:
    | p = paramp;                                   { PLS (p, Nil) }
    | p = paramp; l = param_lstp;                   { PLS (p,l) }

id_lstp:
    | RParen;                                       { Nil }
    | Comma; i = Id; l = id_lstp;                   { IdL (i,l) }

typp:
    |t = typp; Arrow; t2 = typp;                     { FuncTy (t,t2) }
    |LParen; t=typp; RParen;                         { ParenTy t}
    |t = typp; Times; t2 = typp;                     { TuplTy (t, t2)}
    |TInt;                                           { IntTy }
    |TBool;                                          { BoolTy }
    |TString;                                        { StringTy }
    |TUnit;                                          { UnitTy }
    |s = Id;                                         { UserTy s }
