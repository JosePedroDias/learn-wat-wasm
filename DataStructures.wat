(module
	(import "env" "mem" (memory 1)) 

	(global $obj_base_addr (import "env" "obj_base_addr") i32)
	(global $obj_count (import "env" "obj_count") i32)
	(global $obj_stride (import "env" "obj_stride") i32)

	;; attribute offset locations
	(global $x_offset (import "env" "x_offset") i32)
	(global $y_offset (import "env" "y_offset") i32)
	(global $radius_offset (import "env" "radius_offset") i32)
	(global $collision_offset (import "env" "collision_offset") i32)

	(func $collision_check
		(param $x1 i32) (param $y1 i32) (param $r1 i32)
		(param $x2 i32) (param $y2 i32) (param $r2 i32)
		(result i32)

        (local $diff i32)
		(local $x_diff_sq i32)
		(local $y_diff_sq i32)
		(local $r_sum i32)

        (local.set $diff (i32.sub (local.get $x1) (local.get $x2)))
        (local.set $x_diff_sq (i32.mul (local.get $diff) (local.get $diff)))

        (local.set $diff (i32.sub (local.get $y1) (local.get $y2)))
        (local.set $y_diff_sq (i32.mul (local.get $diff) (local.get $diff)))

        (local.set $r_sum (i32.add (local.get $r1) (local.get $r2)))

        (return (i32.lt_u 
                    (i32.add (local.get $x_diff_sq) (local.get $y_diff_sq))
                    (i32.mul (local.get $r_sum) (local.get $r_sum))))
	)

	(func $get_attr (param $obj_base i32) (param $attr_offset i32)
		(result i32)

        (return (i32.load (i32.add (local.get $obj_base) (local.get $attr_offset))))
	)

	(func $set_collision
		(param $obj_base_1 i32)
        (param $obj_base_2 i32)

		(i32.store
            (i32.add (local.get $obj_base_1) (global.get $collision_offset)) ;; address = $obj_base_1 + $collision_offset
            (i32.const 1)) ;; store true in coll attr of o1

        (i32.store
            (i32.add (local.get $obj_base_2) (global.get $collision_offset)) ;; address = $obj_base_2 + $collision_offset
            (i32.const 1)) ;; store true in coll attr of o2
	)

	(func $init
		(local $i i32) ;; outer loop counter
        (local $j i32) ;; inner loop counter
		(local $i_obj i32) ;; address of ith object
        (local $j_obj i32) ;; address of the jth object
		(local $xi i32) (local $yi i32) (local $ri i32) ;; x,y,r for object i
        (local $xj i32) (local $yj i32) (local $rj i32) ;; x,y,r for object j

		(loop $outer_loop
			(local.set $j (i32.const 0)) ;; $j = 0
			(loop $inner_loop
				(block $inner_continue
					;; if $i == $j continue
					(br_if $inner_continue (i32.eq (local.get $i) (local.get $j)))

					;; $i_obj = $obj_base_addr + $i * $obj_stride
					(local.set $i_obj (i32.add
                        (global.get $obj_base_addr)
					    (i32.mul (local.get $i) (global.get $obj_stride))))

					;; load $i_obj + $x_offset and store in $xi
					(local.set $xi (call $get_attr (local.get $i_obj) (global.get $x_offset)))

					;; load $i_obj + $y_offset and store in $yi
					(local.set $yi (call $get_attr (local.get $i_obj) (global.get $y_offset)))
					
					;; load $i_obj + $radius_offset and store in $ri
					(local.set $ri (call $get_attr (local.get $i_obj) (global.get $radius_offset)))
					 
					;; $j_obj = $obj_base_addr + $j * $obj_stride
					(local.set $j_obj (i32.add
                        (global.get $obj_base_addr)
					    (i32.mul (local.get $j) (global.get $obj_stride))))

					;; load $j_obj + $x_offset and store in $xj
					(local.set $xj (call $get_attr (local.get $j_obj) (global.get $x_offset)))

					;; load $j_obj + $y_offset and store in $yj
					(local.set $yj (call $get_attr (local.get $j_obj) (global.get $y_offset)))

					;; load $j_obj + $radius_offset and store in $rj
					(local.set $rj (call $get_attr (local.get $j_obj) (global.get $radius_offset)))
					
					;; check for collision between ith and jth objects
					(if (call $collision_check
					        (local.get $xi) (local.get $yi) (local.get $ri)
					        (local.get $xj) (local.get $yj) (local.get $rj))
                        (then (call $set_collision (local.get $i_obj) (local.get $j_obj))))
                )
				(local.set $j (i32.add (local.get $j) (i32.const 1))) ;; ++$j

				;; if $j < $obj_count loop
				(br_if $inner_loop (i32.lt_u (local.get $j) (global.get $obj_count)))
			)

			(local.set $i (i32.add (local.get $i) (i32.const 1))) ;; ++$i

			;; if $i < $obj_count loop
			(br_if $outer_loop
				(i32.lt_u (local.get $i) (global.get $obj_count)))
		)
	)

	(start $init)
)
