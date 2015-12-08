; Start of malc header.ll

declare i32 @printf(i8*, ...)
declare i32 @exit(i32)

define private i32 @mal_add(i32 %a, i32 %b) {
  %1 = add nsw i32 %a, %b
  ret i32 %1
}

define private i32 @mal_sub(i32 %a, i32 %b) {
  %1 = sub nsw i32 %a, %b
  ret i32 %1
}

define private i32 @mal_mul(i32 %a, i32 %b) {
  %1 = mul nsw i32 %a, %b
  ret i32 %1
}

define private i32 @mal_div(i32 %a, i32 %b) {
  %1 = sdiv i32 %a, %b
  ret i32 %1
}

@printf_format_d = private unnamed_addr constant [3 x i8] c"%d\00"

define private i32 @mal_printnumber(i32 %x) {
  %1 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([3 x i8]* @printf_format_d, i64 0, i64 0), i32 %x)
  ret i32 0
}

@printf_newline = private unnamed_addr constant [2 x i8] c"\0A\00"

define private i32 @mal_printnewline() {
  %1 = tail call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([2 x i8]* @printf_newline, i64 0, i64 0))
  ret i32 0
}

; End of malc header.ll
