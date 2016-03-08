; Start of malc footer.ll

define i32 @main(i32 %argc, i8** %argv) #0 {
  call void @GC_init()
  %env = call %mal_obj @new_root_env()
  call void @save_argc_argv(i32 %argc, i8** %argv)
  call %mal_obj @mal_init_globals(%mal_obj %env)
  call %mal_obj @mal_prog_main(%mal_obj %env)
  ret i32 0
}

; End of malc footer.ll
