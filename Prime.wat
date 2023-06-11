(module
    (func $even_check
        (param $n i32)
        (result i32)

        (i32.eq
            (i32.const 0)
            (i32.rem_u (local.get $n) (i32.const 2))
        )
    )

    (func $eq2
        (param $n i32)
        (result i32)

        (i32.eq (local.get $n) (i32.const 2))
    )

    (func $multiple_check
        (param $n i32)
        (param $m i32)
        (result i32)

        (i32.eq
            (i32.const 0)
            (i32.rem_u (local.get $n) (local.get $m))
        )
    )

    (func $is_prime
        (param $n i32)
        (result i32)

        (local $i i32)

        (if (i32.eq (local.get $n) (i32.const 1)) ;; if n === 1 => false
            (then (return (i32.const 0))))

        (if (call $eq2 (local.get $n)) ;; if n === 2 => true
            (then (return (i32.const 1))))

        (block $not_prime
            (br_if $not_prime (call $even_check (local.get $n))) ;; if evenCheck(n) break block => false

            (local.set $i (i32.const 1)) ;; i = 1

            (loop $prime_test_loop
                (local.set $i (i32.add (local.get $i) (i32.const 2))) ;; i = i + 2 (test next odd $i)

                (if (i32.ge_u (local.get $i) (local.get $n)) ;; if i >= n => return true
                    (then (return (i32.const 1))))

                (br_if $not_prime (call $multiple_check (local.get $n) (local.get $i))) ;; if isMultiple(n, i) break block => false
                    
                (br $prime_test_loop) ;; continue loop
            )
        )
        (return (i32.const 0)) ;; return false
    )

    ;; (export "EvenCheck" (func $even_check))
    ;; (export "Eq2" (func $eq2))
    ;; (export "MultipleCheck" (func $multiple_check))
    (export "IsPrime" (func $is_prime))
)
