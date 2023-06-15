(module
    (import "env" "str_pos_len" (func $str_pos_len (param i32 i32)))
    (import "env" "str_pos_len_prefixed" (func $str_pos_prefixed (param i32)))

    (import "env" "buffer" (memory 1))

    ;; stores this string in mem, starting at idx 0
    (data (i32.const 0) "know the length of this string")      ;; 30
    ;; stores this string in mem, starting at idx 32
    (data (i32.const 32) "also know the length of this string") ;; 35

    ;; stores this string in mem, starting at idx 64
    (data (i32.const 64) "\16length-prefixed string") ;; 22 ~> 16 hex
    ;; stores this string in mem, starting at idx 96
    (data (i32.const 96) "\1eanother length-prefixed string") ;; 30 ~ 1e hex

    (func (export "main")
        (call $str_pos_len (i32.const 0) (i32.const 30))
        (call $str_pos_len (i32.const 32) (i32.const 35))

        (call $str_pos_prefixed (i32.const 64))
        (call $str_pos_prefixed (i32.const 96))
    )
)
