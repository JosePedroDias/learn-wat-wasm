(module
    (import "env" "frame" (memory 1))

    (global $width (import "env" "width") i32)
    (global $height (import "env" "height") i32)

    (func $init)

    (func $process_frame
        (local $i i32)
        (local $f i32)

        (local $r i32)
        (local $g i32)
        (local $b i32)
        (local $gray i32)
        (local $mask i32)

        (local.set $i (i32.const 0))
        (local.set $f (i32.mul (i32.const 4) (i32.mul (global.get $width) (global.get $height))))
        ;;(local.set $mask (i32.const 0x00f0)) ;; 1111 - 8 bits to 4
        (local.set $mask (i32.const 0x00e0)) ;; 1110 - 8 bits to 3
        ;;(local.set $mask (i32.const 0x00c0)) ;; 1100 - 8 bits to 2

        (loop $loop
            ;; get pixel channels
            (local.set $r (i32.load8_u (local.get $i)))
            (local.set $g (i32.load8_u (i32.add (local.get $i) (i32.const 1))))
            (local.set $b (i32.load8_u (i32.add (local.get $i) (i32.const 2))))

            ;; transform pixel
            ;; (local.set $gray
            ;;     (i32.div_u
            ;;         (i32.add
            ;;             (local.get $r)
            ;;             (i32.add (local.get $g) (local.get $b)))
            ;;         (i32.const 3)))

            ;; threshold gray
            ;; (if (i32.lt_u (local.get $gray) (i32.const 127))
            ;;     (then (local.set $gray (i32.const 0)))
            ;;     (else (local.set $gray (i32.const 255)))
            ;; )

            ;; posterize gray
            ;;(local.set $gray (i32.and (local.get $gray) (local.get $mask)))

            ;; (local.set $r (local.get $gray))
            ;; (local.set $g (local.get $gray))
            ;; (local.set $b (local.get $gray))

            ;; posterize rgb
            (local.set $r (i32.and (local.get $r) (local.get $mask)))
            (local.set $g (i32.and (local.get $g) (local.get $mask)))
            (local.set $b (i32.and (local.get $b) (local.get $mask)))

            ;;(local.set $r (i32.const 0))
            ;;(local.set $g (i32.const 0))
            ;;(local.set $b (i32.const 0))
            
            ;; set pixel channels
            (i32.store8 (local.get $i) (local.get $r))
            (i32.store8 (i32.add (local.get $i) (i32.const 1)) (local.get $g))
            (i32.store8 (i32.add (local.get $i) (i32.const 2)) (local.get $b))

            (local.set $i (i32.add (local.get $i) (i32.const 4)))

            (br_if $loop (i32.le_u (local.get $i) (local.get $f)))
        )
    )

    (export "processFrame" (func $process_frame))
)