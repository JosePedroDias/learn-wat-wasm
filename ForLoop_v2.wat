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

        (local.set $i (local.get $start))
        (loop $br_me_to_loop ;; br takes us back to the loop start
            (call $print_i32 (local.get $i))

            (local.set $i
                (i32.add (local.get $i) (i32.const 1)))

            (br_if
                $br_me_to_loop
                (i32.ne (local.get $i) (local.get $end))
            )
        )
    )
)
