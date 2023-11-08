(*
a = 1;
b = 1;
sum = 0;
while (b < 1000) {
  t = a + b;
  a = b;
  b = t;
  if (b % 2 == 0) {
    print(b);
  } else {
    sum = sum + b;
  }
}

B0:
%0 = 1              (* a *)
%1 = 1              (* b *)
%2 = 0              (* sum *)
br B1          (* while loop *)
B1:
%3 = icmp slt i32 %1 1000    (* if b < 1000 then true *)
br %3, B5, B2                (* if true go to B5, else go to B2*)
B2:
%4 = add i32 %0, %1     (* t = a + b *)
%0 = %1             (* a = b *)
%1 = %4             (* b = t *)
%5 = mod i32 %1, 2  (* b mod 2 *)
br i1 %5 , B3, B4   (* if %4 = 0 go to B3, else go to B4 *)
B3:
call @print(%1)
br B1               (* go back to while loop *)
B4:
%2 = sum i32 %2, %1     (* go back to while loop *)
B5
*)
