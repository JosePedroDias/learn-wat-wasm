(module
    ;; function that adds two 64-bit integers

    (func $add_big_ints
        (param $i1 i64) 
        (param $i2 i64)
        (result i64)

        (i64.add
            (local.get $i1)
            (local.get $i2)))

    (export "AddBigInts" (func $add_big_ints))
)
