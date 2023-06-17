(module
    ;; https://www.utf8-chartable.de/

    (import "env" "buffer" (memory 1))
    (import "env" "PrintChar" (func $print_char (param i32)))
    (import "env" "PrintString3x3" (func $print_string (param i32 i32)))

    (global $char_empty i32 (i32.const 0x2e)) ;; space(20) .(2e)
    (global $char_x i32 (i32.const 0x58)) ;; 'X'
    (global $char_o i32 (i32.const 0x4F)) ;; 'O'

    (func $init
        (local $i i32)
        (local.set $i (i32.const 0))

        (loop $loop
            (block $block
                (i32.store8 (local.get $i) (global.get $char_empty))
                (local.set $i (local.get $i) (i32.add (local.get $i) (i32.const 1)))
                (br_if $block (i32.ge_u (local.get $i) (i32.const 9)))
                (br $loop)
            )
        )
    )

    (func $get_char_at
        (param $x i32)
        (param $y i32)
        (result i32)

        (return (i32.load8_u
            (i32.add
                (i32.mul
                    (local.get $y)
                    (i32.const 3))
                (local.get $x)))))

    (func $set_char_at
        (param $x i32)
        (param $y i32)
        (param $char i32)

        (i32.store8
            (i32.add
                (i32.mul
                    (local.get $y)
                    (i32.const 3))
                (local.get $x))
            (local.get $char)))

    (func $is_hor_line
        (param $y i32)
        (param $char i32)
        (result i32)

        (local $xi i32)
        (local.set $xi (i32.const 0))

        (block $break_block
            (loop $loop
                (br_if $break_block (i32.eq (local.get $xi) (i32.const 3)))
                (if (i32.ne (call $get_char_at (local.get $xi) (local.get $y)) (local.get $char))
                    (then (return (i32.const 0))))
                (local.set $xi (i32.add (local.get $xi) (i32.const 1)))
                (br $loop)
            )
        )

        (return (i32.const 1))
    )

    (func $is_ver_line
        (param $x i32)
        (param $char i32)
        (result i32)

        (local $yi i32)
        (local.set $yi (i32.const 0))

        (block $break_block
            (loop $loop
                (br_if $break_block (i32.eq (local.get $yi) (i32.const 3)))
                (if (i32.ne (call $get_char_at (local.get $x) (local.get $yi)) (local.get $char))
                    (then (return (i32.const 0))))
                (local.set $yi (i32.add (local.get $yi) (i32.const 1)))
                (br $loop)
            )
        )

        (return (i32.const 1))
    )

    (func $is_diag_line
        (param $i i32)
        (param $char i32)
        (result i32)

        (block $break_false
            (if (i32.eq (local.get $i) (i32.const 0))
            (then
                (br_if $break_false (i32.ne (local.get $char) (call $get_char_at (i32.const 0) (i32.const 0))))
                (br_if $break_false (i32.ne (local.get $char) (call $get_char_at (i32.const 1) (i32.const 1))))
                (br_if $break_false (i32.ne (local.get $char) (call $get_char_at (i32.const 2) (i32.const 2)))))
            (else
                (br_if $break_false (i32.ne (local.get $char) (call $get_char_at (i32.const 2) (i32.const 0))))
                (br_if $break_false (i32.ne (local.get $char) (call $get_char_at (i32.const 1) (i32.const 1))))
                (br_if $break_false (i32.ne (local.get $char) (call $get_char_at (i32.const 0) (i32.const 2))))))
            (return (i32.const 1))
        )

        (return (i32.const 0))
    )

    (func $has_won
        (param $char i32)
        (result i32)

        (block $break_true
            (br_if $break_true (call $is_hor_line (i32.const 0) (local.get $char)))
            (br_if $break_true (call $is_hor_line (i32.const 1) (local.get $char)))
            (br_if $break_true (call $is_hor_line (i32.const 2) (local.get $char)))

            (br_if $break_true (call $is_ver_line (i32.const 0) (local.get $char)))
            (br_if $break_true (call $is_ver_line (i32.const 1) (local.get $char)))
            (br_if $break_true (call $is_ver_line (i32.const 2) (local.get $char)))

            (br_if $break_true (call $is_diag_line (i32.const 0) (local.get $char)))
            (br_if $break_true (call $is_diag_line (i32.const 1) (local.get $char)))

            (return (i32.const 0))
        )
        (return (i32.const 1))
    )

    (func $count_cells_of_type
        (param $char i32)
        (result i32)

        (local $i i32)
        (local $count i32)
        (local.set $i (i32.const 0))
        (local.set $count (i32.const 0))

        (loop $loop
            (block $block
                (if (i32.eq (i32.load8_u (local.get $i)) (local.get $char))
                    (then
                        (local.set $count (i32.add (local.get $count) (i32.const 1)))
                    ))
                (br_if $block (i32.ge_u (local.get $i) (i32.const 9)))
                (local.set $i (i32.add (local.get $i) (i32.const 1)))
                (br $loop)
            )
        )

        (return (local.get $count))
    )

    (func $next_char_to_play
        (result i32)

        (local $count i32)

        (local.set $count (call $count_cells_of_type (global.get $char_empty)))

        (if (i32.eqz (i32.rem_u (local.get $count) (i32.const 2)))
            (then (return (global.get $char_o))))
        (return (global.get $char_x))
    )

    (func $other_player_char
        (param $char i32)
        (result i32)

        (if (i32.eq (local.get $char) (global.get $char_x))
            (then (return (global.get $char_o))))
        (return (global.get $char_x))
    )

    (func $is_valid_set
        (param $x i32)
        (param $y i32)
        (param $char i32)
        (result i32)

        (block $break
            (br_if $break (i32.gt_u (local.get $x) (i32.const 2)))
            (br_if $break (i32.gt_u (local.get $y) (i32.const 2)))

            (br_if $break (i32.ne (call $get_char_at (local.get $x) (local.get $y)) (global.get $char_empty)))

            (br_if $break (i32.ne (call $next_char_to_play) (local.get $char)))

            (return (i32.const 1))
        )
        (return (i32.const 0))
    )

    (func $is_board_full
        (result i32)

        (return (i32.eqz (call $count_cells_of_type (global.get $char_empty))))
    )

    (func $get_move_number
        (result i32)

        (return (i32.sub (i32.const 9) (call $count_cells_of_type (global.get $char_empty))))
    )

    (func (export "printBoard")
        (call $print_string (i32.const 0) (i32.const 9)))

    (export "getCharAt" (func $get_char_at))
    (export "setCharAt" (func $set_char_at))
    (export "isValidSet" (func $is_valid_set))
    (export "nextCharToPlay" (func $next_char_to_play))
    (export "getMoveNumber" (func $get_move_number))
    (export "otherPlayerChar" (func $other_player_char))
    (export "hasWon" (func $has_won))
    (export "isBoardFull" (func $is_board_full))

    (export "charEmpty" (global $char_empty))
    (export "charX" (global $char_x))
    (export "charO" (global $char_o))

    (start $init)
)
