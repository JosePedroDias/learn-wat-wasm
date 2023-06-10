(module
    ;; function that adds two 32-bit integers

    (func $add
        (param $i1 i32) 
        (param $i2 i32)
        (result i32)
            (i32.add
                (local.get $i1)
                (local.get $i2)) )

    (export "AddInt" (func $add))
)
