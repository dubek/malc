; Start of malc header.ll

%struct.timeval = type { i64, i64 }
%struct.timezone = type { i32, i32 }
%struct.timespec = type { i64, i64 }
%struct.stat = type { i64, i64, i64, i32, i32, i32, i32, i64, i64, i64, i64, %struct.timespec, %struct.timespec, %struct.timespec, [3 x i64] }

declare i32 @puts(i8*)
declare i32 @snprintf(i8*, i64, i8* readonly, ...)
declare i32 @exit(i32)
declare i32 @memcmp(i8*, i8*, i32)
declare i32 @strlen(i8*)
declare i32 @gettimeofday(%struct.timeval*, %struct.timezone*)
declare i32 @stat(i8*, %struct.stat*)
declare i32 @open(i8*, i32, ...)
declare i64 @read(i32, i8*, i64)
declare i32 @close(i32)
declare void @llvm.memcpy.p0i8.p0i8.i32(i8*, i8*, i32, i32, i1)
declare void @llvm.memset.p0i8.i64(i8*, i8, i64, i32, i1)

declare i8* @readline(i8*)          ; Link with -lreadline

declare void @GC_init()             ; Link with -lgc
declare i8* @GC_malloc(i64)
declare i8* @GC_malloc_atomic(i64)
declare i64 @GC_get_heap_size()
declare i64 @GC_get_total_bytes()

%mal_obj = type i64

; i32 - obj_type
; i32 - len (bytes/elements)
; i8* - points to data
%mal_obj_header_t = type { i32, i32, i8* }

@global_argv = global i8** null
@global_argc = global i32 0

define private %mal_obj @identity(%mal_obj %obj) {
  ret %mal_obj %obj
}

define private %mal_obj @bool_to_mal(i1 %cond) {
  br i1 %cond, label %IfEqual, label %IfUnequal
IfEqual:
  %1 = call %mal_obj @make_true()
  ret %mal_obj %1
IfUnequal:
  %2 = call %mal_obj @make_false()
  ret %mal_obj %2
}

define private %mal_obj @mal_integer_q(%mal_obj %obj) {
  %1 = and i64 %obj, 1
  %2 = icmp eq i64 %1, 1
  %3 = call %mal_obj @bool_to_mal(i1 %2)
  ret %mal_obj %3
}

define private %mal_obj @mal_nil_q(%mal_obj %obj) {
  %1 = icmp eq i64 %obj, 2
  %2 = call %mal_obj @bool_to_mal(i1 %1)
  ret %mal_obj %2
}

define private %mal_obj @mal_false_q(%mal_obj %obj) {
  %1 = icmp eq i64 %obj, 4
  %2 = call %mal_obj @bool_to_mal(i1 %1)
  ret %mal_obj %2
}

define private %mal_obj @mal_true_q(%mal_obj %obj) {
  %1 = icmp eq i64 %obj, 6
  %2 = call %mal_obj @bool_to_mal(i1 %1)
  ret %mal_obj %2
}

; Returns nil, false, true - for these constants
;         1 - integer
;         17/18/19 - symbol/string/keyword
;         33/34/35 - list/vector/hash-map
;         49 - atom
;         65 - env
;         66 - function
define private %mal_obj @mal_get_type(%mal_obj %obj) {
  %1 = and i64 %obj, 1
  %2 = icmp eq i64 %1, 1
  br i1 %2, label %IfInt, label %IfConstOrObj
IfConstOrObj:
  %3 = icmp ugt i64 %obj, 6
  br i1 %3, label %IfObj, label %IfConst
IfObj:
  %4 = inttoptr %mal_obj %obj to %mal_obj_header_t*
  %5 = getelementptr %mal_obj_header_t* %4, i32 0, i32 0
  %6 = load i32* %5
  %7 = sext i32 %6 to i64
  %8 = call %mal_obj @make_integer(i64 %7)
  ret %mal_obj %8
IfConst:
  ret %mal_obj %obj
IfInt:
  %9 = call %mal_obj @make_integer(i64 1)
  ret %mal_obj %9
}

define private i32 @mal_get_len_i32(%mal_obj %obj) {
  %1 = inttoptr %mal_obj %obj to %mal_obj_header_t*
  %2 = getelementptr %mal_obj_header_t* %1, i32 0, i32 1
  %3 = load i32* %2
  ret i32 %3
}

define private %mal_obj @mal_get_len(%mal_obj %obj) {
  %1 = call i32 @mal_get_len_i32(%mal_obj %obj)
  %2 = sext i32 %1 to i64
  %3 = call %mal_obj @make_integer(i64 %2)
  ret %mal_obj %3
}

define private i8* @mal_get_array_ptr_i8(%mal_obj %obj) {
  %1 = inttoptr %mal_obj %obj to %mal_obj_header_t*
  %2 = getelementptr %mal_obj_header_t* %1, i32 0, i32 2
  %3 = load i8** %2
  ret i8* %3
}

define private %mal_obj @mal_integer_equal_q(%mal_obj %a, %mal_obj %b) {
  %1 = icmp eq %mal_obj %a, %b
  %2 = call %mal_obj @bool_to_mal(i1 %1)
  ret %mal_obj %2
}

define private %mal_obj @mal_integer_gt_q(%mal_obj %a, %mal_obj %b) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %a)
  %2 = call i64 @mal_integer_to_raw(%mal_obj %b)
  %3 = icmp sgt i64 %1, %2
  %4 = call %mal_obj @bool_to_mal(i1 %3)
  ret %mal_obj %4
}

define private %mal_obj @mal_integer_gte_q(%mal_obj %a, %mal_obj %b) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %a)
  %2 = call i64 @mal_integer_to_raw(%mal_obj %b)
  %3 = icmp sge i64 %1, %2
  %4 = call %mal_obj @bool_to_mal(i1 %3)
  ret %mal_obj %4
}

define private %mal_obj @mal_integer_lt_q(%mal_obj %a, %mal_obj %b) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %a)
  %2 = call i64 @mal_integer_to_raw(%mal_obj %b)
  %3 = icmp slt i64 %1, %2
  %4 = call %mal_obj @bool_to_mal(i1 %3)
  ret %mal_obj %4
}

define private %mal_obj @mal_integer_lte_q(%mal_obj %a, %mal_obj %b) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %a)
  %2 = call i64 @mal_integer_to_raw(%mal_obj %b)
  %3 = icmp sle i64 %1, %2
  %4 = call %mal_obj @bool_to_mal(i1 %3)
  ret %mal_obj %4
}

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
  %mal_obj_header_temp = getelementptr %mal_obj_header_t* null, i64 1
  %mal_obj_header_t_size = ptrtoint %mal_obj_header_t* %mal_obj_header_temp to i64
  %1 = call i8* @GC_malloc(i64 %mal_obj_header_t_size)
  %2 = bitcast i8* %1 to %mal_obj_header_t*
  ret %mal_obj_header_t* %2
}

; len_bytes doesn't include the extra NULL char
define private %mal_obj @mal_make_bytearray_obj(i32 %objtype, i32 %len_bytes, i8* %bytes) {
  %1 = call %mal_obj_header_t* @alloc_obj_header()
  %2 = getelementptr %mal_obj_header_t* %1, i32 0, i32 0
  store i32 %objtype, i32* %2
  %3 = getelementptr %mal_obj_header_t* %1, i32 0, i32 1
  store i32 %len_bytes, i32* %3
  %4 = getelementptr %mal_obj_header_t* %1, i32 0, i32 2
  store i8* %bytes, i8** %4
  %new_obj = ptrtoint %mal_obj_header_t* %1 to %mal_obj
  ret %mal_obj %new_obj
}

; len_bytes doesn't include the extra NULL char
define private %mal_obj @mal_empty_bytearray_obj(%mal_obj %objtype, %mal_obj %len_bytes) {
  %objtype.i64 = call i64 @mal_integer_to_raw(%mal_obj %objtype)
  %objtype.i32 = trunc i64 %objtype.i64 to i32
  %len_bytes.i64 = call i64 @mal_integer_to_raw(%mal_obj %len_bytes)
  %len_bytes.i32 = trunc i64 %len_bytes.i64 to i32
  %buf_len = add i64 %len_bytes.i64, 1 ; space for terminating NULL char
  %strptr = call i8* @GC_malloc_atomic(i64 %buf_len)
  call void @llvm.memset.p0i8.i64(i8* %strptr, i8 0, i64 %buf_len, i32 0, i1 0)
  %strobj = call %mal_obj @mal_make_bytearray_obj(i32 %objtype.i32, i32 %len_bytes.i32, i8* %strptr)
  ret %mal_obj %strobj
}

define private %mal_obj @mal_set_bytearray_range(%mal_obj %dstobj, %mal_obj %offset, %mal_obj %len, %mal_obj %srcobj) {
  %dst_hdr_ptr = inttoptr %mal_obj %dstobj to %mal_obj_header_t*
  %dst_buf_ptr = getelementptr %mal_obj_header_t* %dst_hdr_ptr, i32 0, i32 2
  %dst_buf = load i8** %dst_buf_ptr
  %offset.i64 = call i64 @mal_integer_to_raw(%mal_obj %offset)
  %len.i64 = call i64 @mal_integer_to_raw(%mal_obj %len)
  %len.i32 = trunc i64 %len.i64 to i32
  %src_hdr_ptr = inttoptr %mal_obj %srcobj to %mal_obj_header_t*
  %src_buf_ptr = getelementptr %mal_obj_header_t* %src_hdr_ptr, i32 0, i32 2
  %src_buf = load i8** %src_buf_ptr
  %dst_buf_offset_ptr = getelementptr i8* %dst_buf, i64 %offset.i64
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %dst_buf_offset_ptr, i8* %src_buf, i32 %len.i32, i32 0, i1 0)
  ret %mal_obj %dstobj
}

define private %mal_obj @mal_set_bytearray_char(%mal_obj %dstobj, %mal_obj %offset, %mal_obj %ascii_value) {
  %dst_hdr_ptr = inttoptr %mal_obj %dstobj to %mal_obj_header_t*
  %dst_buf_ptr = getelementptr %mal_obj_header_t* %dst_hdr_ptr, i32 0, i32 2
  %dst_buf = load i8** %dst_buf_ptr
  %offset.i64 = call i64 @mal_integer_to_raw(%mal_obj %offset)
  %dst_buf_offset_ptr = getelementptr i8* %dst_buf, i64 %offset.i64
  %ascii_value.i64 = call i64 @mal_integer_to_raw(%mal_obj %ascii_value)
  %ascii_byte = trunc i64 %ascii_value.i64 to i8
  store i8 %ascii_byte, i8* %dst_buf_offset_ptr
  ret %mal_obj %dstobj
}

define private %mal_obj @mal_raw_obj_to_integer(%mal_obj %obj) {
  %1 = bitcast %mal_obj %obj to i64
  %2 = call %mal_obj @make_integer(i64 %1)
  ret %mal_obj %2
}

@snprintf_format_ld = private unnamed_addr constant [4 x i8] c"%ld\00"
define private %mal_obj @mal_integer_to_string(%mal_obj %intobj) {
  %num = call i64 @mal_integer_to_raw(%mal_obj %intobj)
  %vector = alloca [32 x i8]
  %buf = getelementptr inbounds [32 x i8]* %vector, i64 0, i64 0
  %len_bytes_without_nullchar = call i32 (i8*, i64, i8*, ...)* @snprintf(i8* %buf, i64 32, i8* getelementptr inbounds ([4 x i8]* @snprintf_format_ld, i32 0, i32 0), i64 %num)
  %len_bytes = add i32 %len_bytes_without_nullchar, 1
  %len_bytes.i64 = sext i32 %len_bytes to i64
  %bufcopy = call i8* @GC_malloc_atomic(i64 %len_bytes.i64)
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %bufcopy, i8* %buf, i32 %len_bytes, i32 0, i1 0)
  %resstr = call %mal_obj @mal_make_bytearray_obj(i32 18, i32 %len_bytes_without_nullchar, i8* %bufcopy)
  ret %mal_obj %resstr
}

; Compare two bytearrays. Length must be equal.
define private %mal_obj @mal_bytearray_equal_q(%mal_obj %a, %mal_obj %b) {
  %a_hdr_ptr = inttoptr %mal_obj %a to %mal_obj_header_t*
  %a_len_ptr = getelementptr %mal_obj_header_t* %a_hdr_ptr, i32 0, i32 1
  %a_len = load i32* %a_len_ptr
  %a_buf_ptr = getelementptr %mal_obj_header_t* %a_hdr_ptr, i32 0, i32 2
  %a_buf = load i8** %a_buf_ptr

  %b_hdr_ptr = inttoptr %mal_obj %b to %mal_obj_header_t*
  %b_len_ptr = getelementptr %mal_obj_header_t* %b_hdr_ptr, i32 0, i32 1
  %b_len = load i32* %b_len_ptr
  %b_buf_ptr = getelementptr %mal_obj_header_t* %b_hdr_ptr, i32 0, i32 2
  %b_buf = load i8** %b_buf_ptr

  %res = call i32 @memcmp(i8* %a_buf, i8* %b_buf, i32 %a_len)
  %is_equal = icmp eq i32 %res, 0
  %mal_bool_res = call %mal_obj @bool_to_mal(i1 %is_equal)
  ret %mal_obj %mal_bool_res
}

define private %mal_obj @mal_make_elementarray_obj(%mal_obj %objtype, %mal_obj %len_elements) {
  %objtype.i64 = call i64 @mal_integer_to_raw(%mal_obj %objtype)
  %objtype.i32 = trunc i64 %objtype.i64 to i32

  %len_elements.i64 = call i64 @mal_integer_to_raw(%mal_obj %len_elements)
  %len_elements.i32 = trunc i64 %len_elements.i64 to i32
  %bytes = mul i64 %len_elements.i64, 8

  %1 = call %mal_obj_header_t* @alloc_obj_header()

  %2 = getelementptr %mal_obj_header_t* %1, i32 0, i32 0
  store i32 %objtype.i32, i32* %2
  %3 = getelementptr %mal_obj_header_t* %1, i32 0, i32 1
  store i32 %len_elements.i32, i32* %3

  %elementarrayptr = call i8* @GC_malloc(i64 %bytes)
  %4 = getelementptr %mal_obj_header_t* %1, i32 0, i32 2
  store i8* %elementarrayptr, i8** %4

  %new_obj = ptrtoint %mal_obj_header_t* %1 to %mal_obj
  ret %mal_obj %new_obj
}

define private %mal_obj @mal_set_elementarray_item(%mal_obj %obj, %mal_obj %item_index, %mal_obj %new_item) {
  %1 = inttoptr %mal_obj %obj to %mal_obj_header_t*
  %2 = getelementptr %mal_obj_header_t* %1, i32 0, i32 2
  %3 = bitcast i8** %2 to %mal_obj**
  %4 = load %mal_obj** %3
  %5 = call i64 @mal_integer_to_raw(%mal_obj %item_index)
  %6 = getelementptr %mal_obj* %4, i64 %5
  store %mal_obj %new_item, %mal_obj* %6
  ret %mal_obj %obj
}

define private %mal_obj @mal_get_elementarray_item(%mal_obj %obj, %mal_obj %item_index) {
  %1 = inttoptr %mal_obj %obj to %mal_obj_header_t*
  %2 = getelementptr %mal_obj_header_t* %1, i32 0, i32 2
  %3 = bitcast i8** %2 to %mal_obj**
  %4 = load %mal_obj** %3
  %5 = call i64 @mal_integer_to_raw(%mal_obj %item_index)
  %6 = getelementptr %mal_obj* %4, i64 %5
  %7 = load %mal_obj* %6
  ret %mal_obj %7
}

define private %mal_obj @mal_concat_elementarrays(%mal_obj %objtype, %mal_obj %a, %mal_obj %b) {
  %a_len = call i32 @mal_get_len_i32(%mal_obj %a)
  %a_len_bytes = mul nsw i32 %a_len, 8
  %a_arrayptr = call i8* @mal_get_array_ptr_i8(%mal_obj %a)
  %b_len = call i32 @mal_get_len_i32(%mal_obj %b)
  %b_len_bytes = mul nsw i32 %b_len, 8
  %b_arrayptr = call i8* @mal_get_array_ptr_i8(%mal_obj %b)
  %new_len_i32 = add nsw i32 %a_len, %b_len
  %new_len_i64 = sext i32 %new_len_i32 to i64
  %new_len = call %mal_obj @make_integer(i64 %new_len_i64)
  %new_obj = call %mal_obj @mal_make_elementarray_obj(%mal_obj %objtype, %mal_obj %new_len)
  %new_arrayptr = call i8* @mal_get_array_ptr_i8(%mal_obj %new_obj)
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %new_arrayptr, i8* %a_arrayptr, i32 %a_len_bytes, i32 0, i1 0)
  %next_arrayptr = getelementptr i8* %new_arrayptr, i32 %a_len_bytes
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %next_arrayptr, i8* %b_arrayptr, i32 %b_len_bytes, i32 0, i1 0)
  ret %mal_obj %new_obj
}

define private %mal_obj @mal_slice_elementarray(%mal_obj %newobjtype, %mal_obj %obj, %mal_obj %from, %mal_obj %len) {
  %from_index = call i64 @mal_integer_to_raw(%mal_obj %from)

  %obj_arrayptr = call i8* @mal_get_array_ptr_i8(%mal_obj %obj)
  %obj_arrayptr_malobjs = bitcast i8* %obj_arrayptr to %mal_obj*
  %obj_arrayptr_malobjs_start = getelementptr %mal_obj* %obj_arrayptr_malobjs, i64 %from_index
  %obj_arrayptr_start = bitcast %mal_obj* %obj_arrayptr_malobjs_start to i8*

  %len_elements_i64 = call i64 @mal_integer_to_raw(%mal_obj %len)
  %len_elements_i32 = trunc i64 %len_elements_i64 to i32
  %len_bytes = mul nsw i32 %len_elements_i32, 8

  %new_obj = call %mal_obj @mal_make_elementarray_obj(%mal_obj %newobjtype, %mal_obj %len)
  %new_arrayptr = call i8* @mal_get_array_ptr_i8(%mal_obj %new_obj)
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %new_arrayptr, i8* %obj_arrayptr_start, i32 %len_bytes, i32 0, i1 0)
  ret %mal_obj %new_obj
}

define private %mal_obj @mal_native_func_apply_list(%mal_obj %fn, %mal_obj %argslist) {
  %i0 = call %mal_obj @make_integer(i64 0)
  %i1 = call %mal_obj @make_integer(i64 1)
  %i2 = call %mal_obj @make_integer(i64 2)
  %args_names = call %mal_obj @fn_args_names(%mal_obj %fn)
  %args_num = call i32 @mal_get_len_i32(%mal_obj %args_names)
  %funcptr = call %mal_obj @fn_func_ptr(%mal_obj %fn)
  switch i32 %args_num, label %TooMany [ i32 0, label %ZeroArgs
                                         i32 1, label %OneArg
                                         i32 2, label %TwoArgs
                                         i32 3, label %ThreeArgs ]
ZeroArgs:
  %casted_funcptr_0 = inttoptr %mal_obj %funcptr to %mal_obj()*
  %result_0 = call %mal_obj %casted_funcptr_0()
  ret %mal_obj %result_0
OneArg:
  %arg_0_1 = call %mal_obj @mal_get_elementarray_item(%mal_obj %argslist, %mal_obj %i0)
  %casted_funcptr_1 = inttoptr %mal_obj %funcptr to %mal_obj(%mal_obj)*
  %result_1 = call %mal_obj %casted_funcptr_1(%mal_obj %arg_0_1)
  ret %mal_obj %result_1
TwoArgs:
  %arg_0_2 = call %mal_obj @mal_get_elementarray_item(%mal_obj %argslist, %mal_obj %i0)
  %arg_1_2 = call %mal_obj @mal_get_elementarray_item(%mal_obj %argslist, %mal_obj %i1)
  %casted_funcptr_2 = inttoptr %mal_obj %funcptr to %mal_obj(%mal_obj,%mal_obj)*
  %result_2 = call %mal_obj %casted_funcptr_2(%mal_obj %arg_0_2, %mal_obj %arg_1_2)
  ret %mal_obj %result_2
ThreeArgs:
  %arg_0_3 = call %mal_obj @mal_get_elementarray_item(%mal_obj %argslist, %mal_obj %i0)
  %arg_1_3 = call %mal_obj @mal_get_elementarray_item(%mal_obj %argslist, %mal_obj %i1)
  %arg_2_3 = call %mal_obj @mal_get_elementarray_item(%mal_obj %argslist, %mal_obj %i2)
  %casted_funcptr_3 = inttoptr %mal_obj %funcptr to %mal_obj(%mal_obj,%mal_obj,%mal_obj)*
  %result_3 = call %mal_obj %casted_funcptr_3(%mal_obj %arg_0_3, %mal_obj %arg_1_3, %mal_obj %arg_2_3)
  ret %mal_obj %result_3
TooMany:
  call %mal_obj @runtime_error(%mal_obj %i0)
  ret %mal_obj 0
}

define private %mal_obj @mal_func_apply_list(%mal_obj %fn, %mal_obj %argslist) {
  %funcenv = call %mal_obj @fn_env(%mal_obj %fn)
  %binds = call %mal_obj @fn_args_names(%mal_obj %fn)
  %callenv = call %mal_obj @new_env(%mal_obj %funcenv, %mal_obj %binds, %mal_obj %argslist)
  %funcptr = call %mal_obj @fn_func_ptr(%mal_obj %fn)
  %casted_funcptr = inttoptr %mal_obj %funcptr to %mal_obj(%mal_obj)*
  %result = call %mal_obj %casted_funcptr(%mal_obj %callenv)
  ret %mal_obj %result
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

define private %mal_obj @mal_time_ms() {
  %tv = alloca %struct.timeval, align 8
  %1 = call i32 @gettimeofday(%struct.timeval* %tv, %struct.timezone* null)
  %2 = getelementptr inbounds %struct.timeval* %tv, i32 0, i32 0
  %3 = load i64* %2, align 8
  %4 = mul nsw i64 %3, 1000
  %5 = getelementptr inbounds %struct.timeval* %tv, i32 0, i32 1
  %6 = load i64* %5, align 8
  %7 = sdiv i64 %6, 1000
  %8 = add nsw i64 %4, %7
  %9 = call %mal_obj @make_integer(i64 %8)
  ret %mal_obj %9
}

define private %mal_obj @mal_os_exit(%mal_obj %exitcode) {
  %1 = call i64 @mal_integer_to_raw(%mal_obj %exitcode)
  %2 = trunc i64 %1 to i32
  call i32 @exit(i32 %2)
  unreachable
  ret %mal_obj 0
}

define private %mal_obj @mal_gc_get_heap_size() {
  %1 = call i64 @GC_get_heap_size()
  %2 = call %mal_obj @make_integer(i64 %1)
  ret %mal_obj %2
}

define private %mal_obj @mal_gc_get_total_bytes() {
  %1 = call i64 @GC_get_total_bytes()
  %2 = call %mal_obj @make_integer(i64 %1)
  ret %mal_obj %2
}

define private %mal_obj @mal_readline(%mal_obj %prompt) {
  %promptobj = inttoptr %mal_obj %prompt to %mal_obj_header_t*
  %promptstrptr = getelementptr %mal_obj_header_t* %promptobj, i32 0, i32 2
  %promptstr = load i8** %promptstrptr
  %line = call i8* @readline(i8* %promptstr)
  %islinenull = icmp eq i8* %line, null
  br i1 %islinenull, label %GotEof, label %GotString
GotEof:
  %resnil = call %mal_obj @make_nil()
  ret %mal_obj %resnil
GotString:
  %len_bytes_without_nullchar = call i32 @strlen(i8* %line)
  %len_bytes = add i32 %len_bytes_without_nullchar, 1
  %len_bytes.i64 = sext i32 %len_bytes to i64
  %linecopy = call i8* @GC_malloc_atomic(i64 %len_bytes.i64)
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %linecopy, i8* %line, i32 %len_bytes, i32 0, i1 0)
  %resstr = call %mal_obj @mal_make_bytearray_obj(i32 18, i32 %len_bytes_without_nullchar, i8* %linecopy)
  ret %mal_obj %resstr
}

define private %mal_obj @mal_slurp(%mal_obj %filename) {
  ; Get the filename
  %st = alloca %struct.stat, align 8
  %filenameobj = inttoptr %mal_obj %filename to %mal_obj_header_t*
  %filenamestrptr = getelementptr %mal_obj_header_t* %filenameobj, i32 0, i32 2
  %filenamestr = load i8** %filenamestrptr
  ; Get the file size in bytes
  call i32 @stat(i8* %filenamestr, %struct.stat* %st)
  %sizeptr = getelementptr inbounds %struct.stat* %st, i32 0, i32 8
  %sizebytes = load i64* %sizeptr, align 8
  %sizebytes_i32 = trunc i64 %sizebytes to i32
  %sizebytes_with_nullchar = add i64 %sizebytes, 1
  %bufsize_i32 = trunc i64 %sizebytes_with_nullchar to i32
  ; Allocate buffer for file content
  %buf = call i8* @GC_malloc_atomic(i64 %sizebytes_with_nullchar)
  ; Open-Read-Close
  %fd = call i32 (i8*, i32, ...)* @open(i8* %filenamestr, i32 0)
  call i64 @read(i32 %fd, i8* %buf, i64 %sizebytes)
  call i32 @close(i32 %fd)
  ; Build a Mal string object with the file's content
  %resstr = call %mal_obj @mal_make_bytearray_obj(i32 18, i32 %sizebytes_i32, i8* %buf)
  ret %mal_obj %resstr
}

define private %mal_obj @mal_printbytearray(%mal_obj %obj) {
  %1 = inttoptr %mal_obj %obj to %mal_obj_header_t*
  %2 = getelementptr %mal_obj_header_t* %1, i32 0, i32 2
  %3 = load i8** %2
  call i32 @puts(i8* %3)
  %5 = call %mal_obj @make_nil()
  ret %mal_obj %5
}

define private void @save_argc_argv(i32 %argc, i8** %argv) {
  store i32 %argc, i32* @global_argc
  store i8** %argv, i8*** @global_argv
  ret void
}

define private %mal_obj @mal_c_argc() {
  %argc.i32 = load i32* @global_argc
  %argc.i64 = sext i32 %argc.i32 to i64
  %argcobj = call %mal_obj @make_integer(i64 %argc.i64)
  ret %mal_obj %argcobj
}

define private %mal_obj @mal_c_argv_str(%mal_obj %argindex) {
  %argindex.i64 = call i64 @mal_integer_to_raw(%mal_obj %argindex)
  %argv = load i8*** @global_argv
  %argviptr = getelementptr inbounds i8** %argv, i64 %argindex.i64
  %argvistr = load i8** %argviptr
  %argvilen = call i32 @strlen(i8* %argvistr)
  %argviobj = call %mal_obj @mal_make_bytearray_obj(i32 18, i32 %argvilen, i8* %argvistr)
  ret %mal_obj %argviobj
}

; End of malc header.ll
