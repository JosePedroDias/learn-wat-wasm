(module
    (import "env" "PrintString" (func $print_string (param i32 i32)))

    (import "env" "buffer" (memory 1))

    (data (i32.const 128) "0123456789ABCDEF")
    (data (i32.const 256) "               0")
    (data (i32.const 384) "             0x0")
    (data (i32.const 512) " 0000 0000 0000 0000 0000 0000 0000 0000")

    (global $dec_string_len i32 (i32.const 16))
    (global $hex_string_len i32 (i32.const 16))
    (global $bin_string_len i32 (i32.const 40))

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

    (func $set_hex_string
        (param $num i32)
        (param $string_len i32)

        (local $index i32)
        (local $digit_char i32)
        (local $digit_val i32)
        (local $x_pos i32)

        (local.set $index (local.get $string_len))

        (loop $digit_loop
            (block $break
                (br_if $break (i32.eqz (local.get $index))) ;; $index === 0 -> break
                (local.set $digit_val (i32.and (local.get $num) (i32.const 0xf))) ;; isolate last 4 bits

                (if (i32.eqz (local.get $num))
                    (then
                        (if (i32.eqz (local.get $x_pos))
                            (then (local.set $x_pos (local.get $index)))
                            (else (local.set $digit_char (i32.const 32))))
                    )
                    (else
                        (local.set $digit_char (i32.load8_u offset=128 (local.get $digit_val)))
                    )
                )

                (local.set $index (i32.sub (local.get $index) (i32.const 1))) ;; --$index
                (i32.store8 offset=384 (local.get $index) (local.get $digit_char)) ;; store $digit_char
                (local.set $num (i32.shr_u (local.get $num) (i32.const 4))) ;; $num shr4 (move to next nibble)
                (br $digit_loop)
            )
        )

        (i32.store8 offset=384 (i32.sub (local.get $x_pos) (i32.const 1)) (i32.const 120)) ;; store 'x'
        (i32.store8 offset=384 (i32.sub (local.get $x_pos) (i32.const 2)) (i32.const 48)) ;; store '0'
    )

    (func $set_bin_string
        (param $num i32)
        (param $string_len i32)

        (local $index i32)
        (local $loops_remaining i32)
        (local $nibble_bits i32)

        (local.set $index (local.get $string_len))
        (local.set $loops_remaining (i32.const 8))

        (loop $bin_loop
            (block $outer_break ;; outer loop for spaces
                (br_if $outer_break (i32.eqz (local.get $index))) ;; $index === 0 -> break
                (local.set $nibble_bits (i32.const 4)) ;; 4 bits per nibble

                (loop $nibble_loop ;; inner loop for digits
                    (block $nibble_break
                        (local.set $index (i32.sub (local.get $index) (i32.const 1))) ;; --$index
                        (if (i32.and (local.get $num) (i32.const 1)) ;; only 1 if last bit is 1
                            (then (i32.store8 offset=512 (local.get $index) (i32.const 49))) ;; store '1'
                            (else (i32.store8 offset=512 (local.get $index) (i32.const 48))) ;; store '0'
                        )
                        (local.set $num (i32.shr_u (local.get $num) (i32.const 1))) ;; $num shr1 (move to next bit)
                        (local.set $nibble_bits (i32.sub (local.get $nibble_bits) (i32.const 1))) ;; --$nibble_bits

                        (br_if $nibble_break (i32.eqz (local.get $nibble_bits)))
                        (br $nibble_loop)
                    )
                )

                (local.set $index (i32.sub (local.get $index) (i32.const 1))) ;; --$index
                (i32.store8 offset=512 (local.get $index) (i32.const 32)) ;; store ' '
                (br $bin_loop)
            )
        )
    )

    (func (export "to_string")
        (param $num i32)

        (call $set_decimal_string (local.get $num) (global.get $dec_string_len))
        (call $print_string (i32.const 256) (global.get $dec_string_len))

        (call $set_hex_string (local.get $num) (global.get $hex_string_len))
        (call $print_string (i32.const 384) (global.get $hex_string_len))

        (call $set_bin_string (local.get $num) (global.get $bin_string_len))
        (call $print_string (i32.const 512) (global.get $bin_string_len))
    )
)