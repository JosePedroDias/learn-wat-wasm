(module
    ;; fills part of the buffer with a string defined in WAT
    ;; calls JS function to print the buffer part via console.log

    (import "env" "buffer" (memory 1))

    (import "env" "PrintString" (func $print_string (param i32) (param i32)))
    
    ;; where to place the string in the buffer
    (global $start_string_index (import "env" "startStringIndex") i32)
    ;; length of the string
    (global $string_len i32 (i32.const 12))

    ;; set the string into the buffer
    (data (global.get $start_string_index) "hello world!")

    (func (export "HelloWorld")
        (call $print_string
            (global.get $start_string_index)
            (global.get $string_len) )
    )
)
