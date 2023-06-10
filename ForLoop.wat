(module
    ;; function that receives
    ;;   a starting number
    ;;   an ending number (less than it)
    ;;   (refers to a js-exposed logging function to call it)
    ;;   does not return any value

    (import "env" "PrintI32" (func $print_i32 (param i32)))

    (func (export "ForLoop")
        (param $start i32)
        (param $end i32)

        (local $i i32)
        (local $am_i_done i32)

        (local.set $i (local.get $start))
        (loop $br_me_to_loop ;; br takes us back to the loop start
            (block $br_me_to_break ;; br places us at block end
                (local.set $am_i_done (i32.eq (local.get $i) (local.get $end)))

                ;; (if (local.get $am_i_done)
                ;;     (then (br $br_me_to_break))
                ;; )

                (br_if $br_me_to_break (local.get $am_i_done))

                (call $print_i32 (local.get $i))

                (local.set $i
                    (i32.add (local.get $i) (i32.const 1)))

                (br $br_me_to_loop)
            )
        )
    )
)
