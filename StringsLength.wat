(module
    ;; 

    (import "env" "str_pos_len" (func $str_pos_len (param i32 i32)))
    (import "env" "buffer" (memory 1))

    ;; stores this string in mem, starting at idx 100
    (data (i32.const 0) "know the length of this string")      ;; 30
    ;; stores this string in mem, starting at idx 200
    (data (i32.const 32) "also know the length of this string") ;; 35

    (func (export "main")
        (call $str_pos_len (i32.const 0) (i32.const 30))
        (call $str_pos_len (i32.const 32) (i32.const 35))
    )
)
