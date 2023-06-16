(module
    (import "env" "str_pos_len" (func $str_pos_len (param i32 i32)))
    (import "env" "str_pos_len_prefixed" (func $str_pos_prefixed (param i32)))

    (import "env" "buffer" (memory 1))

    ;; stores this string in mem, starting at idx 0
    (data (i32.const 0) "know the length of this string")      ;; 30
    ;; stores this string in mem, starting at idx 32
    (data (i32.const 32) "also know the length of this string") ;; 35

    ;; stores this string in mem, starting at idx 64
    (data (i32.const 128) "\16length-prefixed string") ;; 22 ~> 16 hex
    ;; stores this string in mem, starting at idx 96
    (data (i32.const 192) "\1eanother length-prefixed string") ;; 30 ~ 1e hex

    (func $copy_8_bits
        (param $src i32)
        (param $dst i32)
        (param $len i32)

        (local $last_src_byte i32)

        (local.set $last_src_byte
            (i32.add
                (local.get $src)
                (local.get $len)))

        (loop $copy_loop
            (block $break
                (i32.store8
                    (local.get $dst) ;; to
                    (i32.load8_u (local.get $src))) ;; what

                (local.set $src
                    (i32.add (local.get $src) (i32.const 1))) ;; ++ 1 byte
                (local.set $dst
                    (i32.add (local.get $dst) (i32.const 1)))

                (br_if $break (i32.eq (local.get $src) (local.get $last_src_byte)))
                (br $copy_loop)
            )
        )
    )

    (func $copy_64_bits
        (param $src i32)
        (param $dst i32)
        (param $len i32)

        (local $last_src_byte i32)

        (local.set $last_src_byte
            (i32.add
                (local.get $src)
                (local.get $len)))
        
        (loop $copy_loop
            (block $break
                (i64.store
                    (local.get $dst) ;; to
                    (i64.load (local.get $src))) ;; what

                (local.set $src
                    (i32.add (local.get $src) (i32.const 8))) ;; ++ 8 bytes
                (local.set $dst
                    (i32.add (local.get $dst) (i32.const 8)))

                (br_if $break (i32.ge_u (local.get $src) (local.get $last_src_byte)))
                (br $copy_loop)
            )
        )
    )

    (func $string_copy
        (param $src i32)
        (param $dst i32)
        (param $len i32)

        (local $start_src_byte i32)
        (local $start_dst_byte i32)
        (local $singles i32)
        (local $len_less_singles i32)

        (local.set $len_less_singles (local.get $len))

        (local.set $singles
            (i32.and (local.get $len) (i32.const 7))) ;; 0111b

        (if (local.get $singles)
            (then
                (local.set $len_less_singles
                    (i32.sub
                        (local.get $len)
                        (local.get $singles)))
            
                (local.set $start_src_byte (i32.add (local.get $src) (local.get $len_less_singles)))
                (local.set $start_dst_byte (i32.add (local.get $dst) (local.get $len_less_singles)))

                (call $copy_8_bits (local.get $start_src_byte) (local.get $start_dst_byte) (local.get $singles))
            )
        )
        
        (local.set $len
            (i32.and (i32.const 0xff_ff_ff_f8) (local.get $len))) ;; all bits 1 expect last 3

        (call $copy_64_bits (local.get $src) (local.get $dst) (local.get $len))
    )

    (func (export "main")
        (call $str_pos_len (i32.const 0) (i32.const 30))
        (call $str_pos_len (i32.const 32) (i32.const 35))

        (call $str_pos_prefixed (i32.const 128))
        (call $str_pos_prefixed (i32.const 192))

        ;; src dst len
        (call $string_copy (i32.const 32) (i32.const 128) (i32.const 10))
        ;;(call $copy_8_bits (i32.const 32) (i32.const 128) (i32.const 10))
        ;;(call $copy_64_bits (i32.const 1) (i32.const 31) (i32.const 2))

        (call $str_pos_len (i32.const 128) (i32.const 12))
    )
)
