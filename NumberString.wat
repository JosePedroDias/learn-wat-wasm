(module
    (import "env" "PrintString" (func $print_string (param i32 i32)))

    (import "env" "buffer" (memory 1))

    (data (i32.const 128) "0123456789ABCDEF")
    (data (i32.const 256) " 0")

    (global $dec_string_len i32 (i32.const 16))

    (func $set_decimal_string
        (param $num i32)
        (param $string_len i32)

        (local $index i32)
        (local $digit_char i32)
        (local $digit_val i32)

        (local.set $index (local.get $string_len))

        (if (i32.eqz (local.get $num))
            (then
                (local.set $index (i32.sub (local.get $index) (i32.const 1))) ;; --$index
                (i32.store8 offset=256 (local.get $index) (i32.const 48)) ;; store '0' on 256+$index
            )
        )

        (loop $digit_loop
            (block $break
                (br_if $break (i32.eqz (local.get $index))) ;; $index === 0 -> break
                (local.set $digit_val (i32.rem_u (local.get $num) (i32.const 10))) ;; $digit_val = $num % 10

                (if (i32.eqz (local.get $num))
                    (then
                        (local.set $digit_char (i32.const 32)) ;; space
                    )
                    (else
                        (local.set $digit_char (i32.load8_u offset=128 (local.get $digit_val))) ;; set $digit_char to ascii
                    )
                )

                (local.set $index (i32.sub (local.get $index) (i32.const 1))) ;; --$index
                (i32.store8 offset=256 (local.get $index) (local.get $digit_char)) ;; store $digit_char
                (local.set $num (i32.div_u (local.get $num) (i32.const 10))) ;; $num /= 10
                (br $digit_loop)
            )
        )
    )

    (func (export "to_string")
        (param $num i32)
        (call $set_decimal_string (local.get $num) (global.get $dec_string_len))
        (call $print_string (i32.const 256) (global.get $dec_string_len))
    )
)