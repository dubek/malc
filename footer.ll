; Start of malc footer.ll

define i32 @main(i32 %argc, i8** %argv) #0 {
  %1 = call %mal_obj @mal_prog_main()
  ret i32 0
}

; End of malc footer.ll
