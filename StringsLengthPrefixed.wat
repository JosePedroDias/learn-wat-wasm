(module
    (import "env" "str_pos_len" (func $str_pos_prefixed (param i32)))
    (import "env" "buffer" (memory 1))

    ;; stores this string in mem, starting at idx 100
    (data (i32.const 0) "\16length-prefixed string") ;; 22 ~> 16 hex
    ;; stores this string in mem, starting at idx 200
    (data (i32.const 32) "\1eanother length-prefixed string") ;; 30 ~ 1e hex

    (func (export "main")
        (call $str_pos_prefixed (i32.const 0))
        (call $str_pos_prefixed (i32.const 32))
    )
)
