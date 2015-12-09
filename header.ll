; Start of malc header.ll

declare i32 @printf(i8*, ...)
declare i32 @exit(i32)
declare i8* @calloc(i32, i32)
declare void @free(i8*)

%mal_obj = type i64
%mal_obj_header_t = type { i32, i32, i8* }

define private %mal_obj @make_integer(i64 %x) {
  %1 = shl i64 %x, 1
  %2 = or i64 %1, 1
  ret %mal_obj %2
}

define private i64 @mal_integer_to_raw(%mal_obj %obj) {
  %1 = ashr i64 %obj, 1
  ret i64 %1
}

define private %mal_obj @make_nil() {
  ret %mal_obj 2
}

define private %mal_obj @make_false() {
  ret %mal_obj 4
}

define private %mal_obj @make_true() {
  ret %mal_obj 6
}

define private %mal_obj_header_t* @alloc_obj_header() {
  %mal_obj_header_temp = getelementptr %mal_obj_header_t* null, i32 1
  %mal_obj_header_t_size = ptrtoint %mal_obj_header_t* %mal_obj_header_temp to i32
  %1 = call i8* @calloc(i32 1, i32 %mal_obj_header_t_size)
  %2 = bitcast i8* %1 to %mal_obj_header_t*
  ret %mal_obj_header_t* %2
}

define private %mal_obj @make_string_obj(i32 %objtype, i32 %len_bytes) {
  %1 = call %mal_obj_header_t* @alloc_obj_header()
  ret %mal_obj 0
}

define private %mal_obj @make_vector_obj(i32 %objtype, i32 %len_elements) {
  ret %mal_obj 0
}

define private %mal_obj @mal_add(%mal_obj %a, %mal_obj %b) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %a)
  %2 = call i64 @mal_integer_to_raw(%mal_obj %b)
  %3 = add nsw i64 %1, %2
  %4 = call %mal_obj @make_integer(i64 %3)
  ret %mal_obj %4
}

define private %mal_obj @mal_sub(%mal_obj %a, %mal_obj %b) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %a)
  %2 = call i64 @mal_integer_to_raw(%mal_obj %b)
  %3 = sub nsw i64 %1, %2
  %4 = call %mal_obj @make_integer(i64 %3)
  ret %mal_obj %4
}

define private %mal_obj @mal_mul(%mal_obj %a, %mal_obj %b) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %a)
  %2 = call i64 @mal_integer_to_raw(%mal_obj %b)
  %3 = mul nsw i64 %1, %2
  %4 = call %mal_obj @make_integer(i64 %3)
  ret %mal_obj %4
}

define private %mal_obj @mal_div(%mal_obj %a, %mal_obj %b) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %a)
  %2 = call i64 @mal_integer_to_raw(%mal_obj %b)
  %3 = sdiv i64 %1, %2
  %4 = call %mal_obj @make_integer(i64 %3)
  ret %mal_obj %4
}

@printf_format_d = private unnamed_addr constant [5 x i8] c"%lld\00"

define private %mal_obj @mal_printnumber(%mal_obj %obj) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %obj)
  %2 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([5 x i8]* @printf_format_d, i32 0, i32 0), i64 %1)
  %3 = call %mal_obj @make_nil()
  ret %mal_obj %3
}

@printf_newline = private unnamed_addr constant [2 x i8] c"\0A\00"

define private %mal_obj @mal_printnewline() {
  %1 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([2 x i8]* @printf_newline, i32 0, i32 0))
  %2 = call %mal_obj @make_nil()
  ret %mal_obj %2
}

@printf_nil = private unnamed_addr constant [4 x i8] c"nil\00"

define private %mal_obj @mal_printnil() {
  %1 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @printf_nil, i32 0, i32 0))
  %2 = call %mal_obj @make_nil()
  ret %mal_obj %2
}

@printf_false = private unnamed_addr constant [6 x i8] c"false\00"

define private %mal_obj @mal_printfalse() {
  %1 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([6 x i8]* @printf_false, i32 0, i32 0))
  %2 = call %mal_obj @make_nil()
  ret %mal_obj %2
}

@printf_true = private unnamed_addr constant [5 x i8] c"true\00"

define private %mal_obj @mal_printtrue() {
  %1 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([5 x i8]* @printf_true, i32 0, i32 0))
  %2 = call %mal_obj @make_nil()
  ret %mal_obj %2
}

; End of malc header.ll
