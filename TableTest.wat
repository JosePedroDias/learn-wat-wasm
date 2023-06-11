(module
    (import "js" "tbl" (table $tbl 4 funcref))

	(import "js" "increment" (func $increment (result i32)))
	(import "js" "decrement" (func $decrement (result i32)))
	(import "js" "wasm_increment" (func $wasm_increment (result i32)))
	(import "js" "wasm_decrement" (func $wasm_decrement (result i32)))
	
	(type $returns_i32 (func (result i32)))

	(global $inc_ptr i32 (i32.const 0))
	(global $dec_ptr i32 (i32.const 1))
	(global $wasm_inc_ptr i32 (i32.const 2))
	(global $wasm_dec_ptr i32 (i32.const 3))

	(func (export "js_table_test")
		(loop $inc_cycle
			(call_indirect (type $returns_i32) (global.get $inc_ptr))
			i32.const 20_000_000
			i32.le_u ;; is the value returned by call to $inc_ptr <= 4,000,000?
			br_if $inc_cycle ;; if so, loop
		)
		(loop $dec_cycle
			(call_indirect (type $returns_i32) (global.get $dec_ptr))
			i32.const 20_000_000
			i32.le_u ;; is the value returned by call to $dec_ptr <= 4,000,000?
			br_if $dec_cycle ;; if so, loop
		)
	)	

	(func (export "js_import_test")
		(loop $inc_cycle
			call $increment ;; direct call to JavaScript increment function
			i32.const 20_000_000
			i32.le_u ;; is the value returned by call to $increment<=4,000,000?
			br_if $inc_cycle ;; if so, loop
		)
		(loop $dec_cycle
			call $decrement ;; direct call to JavaScript decrement function
			i32.const 20_000_000
			i32.le_u ;; is the value returned by call to $decrement<=4,000,000?
			br_if $dec_cycle ;; if so, loop
		)
	)
	
	(func (export "wasm_table_test")
		(loop $inc_cycle
			;; indirect call to WASM increment function
			(call_indirect (type $returns_i32) (global.get $wasm_inc_ptr))
			i32.const 20_000_000
			i32.le_u ;; is the value returned by call to $wasm_inc_ptr<=4,000,000?
			br_if $inc_cycle ;; if so, loop
		)
		(loop $dec_cycle
			;; indirect call to WASM decrement function
			(call_indirect (type $returns_i32) (global.get $wasm_dec_ptr))
			i32.const 20_000_000
			i32.le_u ;; is the value returned by call to $wasm_dec_ptr<=4,000,000?
			br_if $dec_cycle ;; if so, loop
		)
	)
	
	(func (export "wasm_import_test")
		(loop $inc_cycle
			call $wasm_increment ;; direct call to WASM increment function
			i32.const 20_000_000
			i32.le_u
			br_if $inc_cycle
		)
		(loop $dec_cycle
			call $wasm_decrement ;; direct call to WASM decrement function
			i32.const 20_000_000
			i32.le_u
			br_if $dec_cycle
		)
	)
)
