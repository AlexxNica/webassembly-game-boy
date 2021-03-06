(module $gb_cpu
    (import "js" "memory" (memory 1))

    ;; import functions
    (func $raw_log  (import "console" "raw_log")  (param i32))
    (func $char_log (import "console" "char_log") (param i32))
    (func $hex_log  (import "console" "hex_log")  (param i32))

    ;; instruction set
    (table 256 anyfunc)
    (elem (i32.const 0)
        $0x00 $0x01 $0x02 $0x03 $0x04 $0x05 $0x06 $0x07 $0x08 $0x09 $0x0a $0x0b $0x0c $0x0d $0x0e $0x0f
        $0x10 $0x11 $0x12 $0x13 $0x14 $0x15 $0x16 $0x17 $0x18 $0x19 $0x1a $0x1b $0x1c $0x1d $0x1e $0x1f
        $0x20 $0x21 $0x22 $0x23 $0x24 $0x25 $0x26 $0x27 $0x28 $0x29 $0x2a $0x2b $0x2c $0x2d $0x2e $0x2f
        $0x30 $0x31 $0x32 $0x33 $0x34 $0x35 $0x36 $0x37 $0x38 $0x39 $0x3a $0x3b $0x3c $0x3d $0x3e $0x3f
        $0x40 $0x41 $0x42 $0x43 $0x44 $0x45 $0x46 $0x47 $0x48 $0x49 $0x4a $0x4b $0x4c $0x4d $0x4e $0x4f
        $0x50 $0x51 $0x52 $0x53 $0x54 $0x55 $0x56 $0x57 $0x58 $0x59 $0x5a $0x5b $0x5c $0x5d $0x5e $0x5f
        $0x60 $0x61 $0x62 $0x63 $0x64 $0x65 $0x66 $0x67 $0x68 $0x69 $0x6a $0x6b $0x6c $0x6d $0x6e $0x6f
        $0x70 $0x71 $0x72 $0x73 $0x74 $0x75 $0x76 $0x77 $0x78 $0x79 $0x7a $0x7b $0x7c $0x7d $0x7e $0x7f
        $0x80 $0x81 $0x82 $0x83 $0x84 $0x85 $0x86 $0x87 $0x88 $0x89 $0x8a $0x8b $0x8c $0x8d $0x8e $0x8f
        $0x90 $0x91 $0x92 $0x93 $0x94 $0x95 $0x96 $0x97 $0x98 $0x99 $0x9a $0x9b $0x9c $0x9d $0x9e $0x9f
        $0xa0 $0xa1 $0xa2 $0xa3 $0xa4 $0xa5 $0xa6 $0xa7 $0xa8 $0xa9 $0xaa $0xab $0xac $0xad $0xae $0xaf
        $0xb0 $0xb1 $0xb2 $0xb3 $0xb4 $0xb5 $0xb6 $0xb7 $0xb8 $0xb9 $0xba $0xbb $0xbc $0xbd $0xbe $0xbf
        $0xc0 $0xc1 $0xc2 $0xc3 $0xc4 $0xc5 $0xc6 $0xc7 $0xc8 $0xc9 $0xca $0xcb $0xcc $0xcd $0xce $0xcf
        $0xd0 $0xd1 $0xd2 $0xd3 $0xd4 $0xd5 $0xd6 $0xd7 $0xd8 $0xd9 $0xda $0xdb $0xdc $0xdd $0xde $0xdf
        $0xe0 $0xe1 $0xe2 $0xe3 $0xe4 $0xe5 $0xe6 $0xe7 $0xe8 $0xe9 $0xea $0xeb $0xec $0xed $0xee $0xef
        $0xf0 $0xf1 $0xf2 $0xf3 $0xf4 $0xf5 $0xf6 $0xf7 $0xf8 $0xf9 $0xfa $0xfb $0xfc $0xfd $0xfe $0xff
    )
    (type $instr (func))
    (global $pc_addr i32 (i32.const 0x11000))
    (global $sp_addr i32 (i32.const 0x11004))

    ;; interrupts
    (global $i_addr i32 (i32.const 0x11010))
    (global $i_master i32 (i32.const 0x01))
    (global $i_enabled i32 (i32.const 0x02))
    (global $i_vblank i32 (i32.const 0x04))
    (global $i_lcdstat i32 (i32.const 0x08))
    (global $i_timer i32 (i32.const 0x10))
    (global $i_serial i32 (i32.const 0x20))
    (global $i_joypad i32 (i32.const 0x40))

    (global $reg_a_addr i32 (i32.const 0x1100f))
    (global $reg_f_addr i32 (i32.const 0x1100e))
    (global $reg_b_addr i32 (i32.const 0x1100d))
    (global $reg_c_addr i32 (i32.const 0x1100c))
    (global $reg_d_addr i32 (i32.const 0x1100b))
    (global $reg_e_addr i32 (i32.const 0x1100a))
    (global $reg_h_addr i32 (i32.const 0x11009))
    (global $reg_l_addr i32 (i32.const 0x11008))

    (global $flag_z i32 (i32.const 0x80))
    (global $flag_n i32 (i32.const 0x40))
    (global $flag_h i32 (i32.const 0x20))
    (global $flag_c i32 (i32.const 0x10))
    

    ;; init
    (start $init)
    (func $init
        call $reset
    )

    ;; reset the emulator
    (export "reset" (func $reset))
    (func $reset
        ;; clear ram
        (local $start i32)
        (local $end i32)

        i32.const 0x7fff
        set_local $start

        i32.const 0xffff
        set_local $end

        block $exit
            loop $loop
                get_local $start
                get_local $start
                i32.const 1
                i32.add
                tee_local $start

                (i32.store (i32.const 0))

                get_local $start
                get_local $end 
                i32.lt_u
                br_if $loop

                br $exit
            end
        end


        ;; reset pc
        get_global $pc_addr
        (i32.store16 (i32.const 0x0100))

        ;; reset sp
        get_global $sp_addr
        (i32.store16 (i32.const 0xfffe))

        ;; set registers
        get_global $reg_a_addr
        (i32.store8 (i32.const 0x01))

        get_global $reg_f_addr
        (i32.store8 (i32.const 0xb0))

        get_global $reg_b_addr
        (i32.store8 (i32.const 0x00))

        get_global $reg_c_addr
        (i32.store8 (i32.const 0x13))

        get_global $reg_d_addr
        (i32.store8 (i32.const 0x00))

        get_global $reg_e_addr
        (i32.store8 (i32.const 0xd8))

        get_global $reg_h_addr
        (i32.store8 (i32.const 0x01))

        get_global $reg_l_addr
        (i32.store8 (i32.const 0x4d))
    )

    ;; execute next instruction
    (export "tick" (func $tick))
    (func $tick
        (local $inst_addr i32)

        loop $loop
            ;; get the pc
            get_global $pc_addr
            i32.load

            ;; get opcode
            i32.load8_u
            set_local $inst_addr

            call $_pc++

            ;; execute instruction
            get_local $inst_addr
            call_indirect $instr

            br $loop
        end
    )
    
    ;; push to stack
    (func $stack_push (param i32)
        ;; decrement sp
        get_global $sp_addr
        get_global $sp_addr
        i32.load
        i32.const 2
        (i32.store (i32.sub))
    )

    ;; pop from stack
    (func $stack_pop)

    (func $_pc++
        ;; increment pc
        get_global $pc_addr
        get_global $pc_addr
        i32.load
        i32.const 1
        (i32.store (i32.add))
    )


    ;;
    ;; Game Boy instruction set
    ;;

    (func $0x00) ;; nop
    (func $0x01 ;; LD BC,nn 
        get_global $reg_c_addr
        call $_load16
    )
    (func $0x02 i32.const 0x02 call $hex_log unreachable)
    (func $0x03 i32.const 0x03 call $hex_log unreachable)
    (func $0x04 i32.const 0x04 call $hex_log unreachable)
    (func $0x05 ;; DEC B
        get_global $reg_b_addr
        call $_dec8
    )
    (func $0x06 ;; LD B,n
        get_global $reg_b_addr
        call $_load8
    )
    (func $0x07 i32.const 0x07 call $hex_log unreachable)
    (func $0x08 i32.const 0x08 call $hex_log unreachable)
    (func $0x09 i32.const 0x09 call $hex_log unreachable)
    (func $0x0a i32.const 0x0a call $hex_log unreachable)
    (func $0x0b i32.const 0x0b call $hex_log unreachable)
    (func $0x0c i32.const 0x0c call $hex_log unreachable)
    (func $0x0d ;; DEC C
        get_global $reg_c_addr
        call $_dec8
    )
    (func $0x0e ;; LD C,n
        get_global $reg_c_addr
        call $_load8
    )
    (func $0x0f i32.const 0x0f call $hex_log unreachable)

    (func $0x10 i32.const 0x10 call $hex_log unreachable)
    (func $0x11 ;; LD DE,nn 
        get_global $reg_e_addr
        call $_load16
    )
    (func $0x12 i32.const 0x12 call $hex_log unreachable)
    (func $0x13 i32.const 0x13 call $hex_log unreachable)
    (func $0x14 i32.const 0x14 call $hex_log unreachable)
    (func $0x15 ;; DEC D
        get_global $reg_d_addr
        call $_dec8
    )
    (func $0x16 ;; LD D,n
        get_global $reg_d_addr
        call $_load8
    )
    (func $0x17 i32.const 0x17 call $hex_log unreachable)
    (func $0x18 i32.const 0x18 call $hex_log unreachable)
    (func $0x19 i32.const 0x19 call $hex_log unreachable)
    (func $0x1a i32.const 0x1a call $hex_log unreachable)
    (func $0x1b i32.const 0x1b call $hex_log unreachable)
    (func $0x1c i32.const 0x1c call $hex_log unreachable)
    (func $0x1d ;; DEC E
        get_global $reg_e_addr
        call $_dec8
    )
    (func $0x1e ;; LD E
        get_global $reg_e_addr
        call $_load8
    )
    (func $0x1f i32.const 0x1f call $hex_log unreachable)

    (func $0x20 ;; JR NZ,n
        block $exit
            block $pc
                get_global $flag_z
                call $_check_flag
                i32.const 0
                i32.ne

                br_if $pc

                get_global $pc_addr
                get_global $pc_addr
                i32.load
                i32.load8_s

                ;; 
                call $_pc++

                ;; current pc addr
                get_global $pc_addr
                i32.load

                (i32.store (i32.add))

                br $exit
            end

            call $_pc++
        end
    )
    (func $0x21 ;; LD HL,nn
        get_global $reg_l_addr
        call $_load16
    )
    (func $0x22 i32.const 0x22 call $hex_log unreachable)
    (func $0x23 i32.const 0x23 call $hex_log unreachable)
    (func $0x24 i32.const 0x24 call $hex_log unreachable)
    (func $0x25 ;; DEC H
        get_global $reg_h_addr
        call $_dec8
    )
    (func $0x26 ;; LD H,n
        get_global $reg_h_addr
        call $_load8
    )
    (func $0x27 i32.const 0x27 call $hex_log unreachable)
    (func $0x28 i32.const 0x28 call $hex_log unreachable)
    (func $0x29 i32.const 0x29 call $hex_log unreachable)
    (func $0x2a i32.const 0x2a call $hex_log unreachable)
    (func $0x2b i32.const 0x2b call $hex_log unreachable)
    (func $0x2c i32.const 0x2c call $hex_log unreachable)
    (func $0x2d ;; DEC L
        get_global $reg_l_addr
        call $_dec8
    )
    (func $0x2e ;; LD L,n
        get_global $reg_l_addr
        call $_load8
    )
    (func $0x2f i32.const 0x2f call $hex_log unreachable)

    (func $0x30 i32.const 0x30 call $hex_log unreachable)
    (func $0x31 ;; LD SP,nn
        i32.const 0x31 call $hex_log unreachable)
    (func $0x32 ;; LDD A,(HL)
        ;; get mem address at HL
        get_global $reg_l_addr
        i32.load16_u
        
        ;; get value at register A
        get_global $reg_a_addr
        i32.load

        ;; store reg A value at mem address HL
        (i32.store(i32.load8_u))

        ;; decrement HL (don't set flags)
        get_global $reg_l_addr
        get_global $reg_l_addr
        i32.load8_u
        i32.const 1
        (i32.store8 (i32.sub))
    )
    (func $0x33 i32.const 0x33 call $hex_log unreachable)
    (func $0x34 i32.const 0x34 call $hex_log unreachable)
    (func $0x35 ;; DEC (HL)
        i32.const 0x35 call $hex_log unreachable)
    (func $0x36 i32.const 0x36 call $hex_log unreachable)
    (func $0x37 i32.const 0x37 call $hex_log unreachable)
    (func $0x38 i32.const 0x38 call $hex_log unreachable)
    (func $0x39 i32.const 0x39 call $hex_log unreachable)
    (func $0x3a i32.const 0x3a call $hex_log unreachable)
    (func $0x3b i32.const 0x3b call $hex_log unreachable)
    (func $0x3c i32.const 0x3c call $hex_log unreachable)
    (func $0x3d ;; DEC A
        get_global $reg_a_addr
        call $_dec8
    )
    (func $0x3e ;; LD A,n
        get_global $reg_a_addr
        call $_load8
    )
    (func $0x3f i32.const 0x3f call $hex_log unreachable)

    (func $0x40 i32.const 0x40 call $hex_log unreachable)
    (func $0x41 i32.const 0x41 call $hex_log unreachable)
    (func $0x42 i32.const 0x42 call $hex_log unreachable)
    (func $0x43 i32.const 0x43 call $hex_log unreachable)
    (func $0x44 i32.const 0x44 call $hex_log unreachable)
    (func $0x45 i32.const 0x45 call $hex_log unreachable)
    (func $0x46 i32.const 0x46 call $hex_log unreachable)
    (func $0x47 i32.const 0x47 call $hex_log unreachable)
    (func $0x48 i32.const 0x48 call $hex_log unreachable)
    (func $0x49 i32.const 0x49 call $hex_log unreachable)
    (func $0x4a i32.const 0x4a call $hex_log unreachable)
    (func $0x4b i32.const 0x4b call $hex_log unreachable)
    (func $0x4c i32.const 0x4c call $hex_log unreachable)
    (func $0x4d i32.const 0x4d call $hex_log unreachable)
    (func $0x4e i32.const 0x4e call $hex_log unreachable)
    (func $0x4f i32.const 0x4f call $hex_log unreachable)

    (func $0x50 i32.const 0x50 call $hex_log unreachable)
    (func $0x51 i32.const 0x51 call $hex_log unreachable)
    (func $0x52 i32.const 0x52 call $hex_log unreachable)
    (func $0x53 i32.const 0x53 call $hex_log unreachable)
    (func $0x54 i32.const 0x54 call $hex_log unreachable)
    (func $0x55 i32.const 0x55 call $hex_log unreachable)
    (func $0x56 i32.const 0x56 call $hex_log unreachable)
    (func $0x57 i32.const 0x57 call $hex_log unreachable)
    (func $0x58 i32.const 0x58 call $hex_log unreachable)
    (func $0x59 i32.const 0x59 call $hex_log unreachable)
    (func $0x5a i32.const 0x5a call $hex_log unreachable)
    (func $0x5b i32.const 0x5b call $hex_log unreachable)
    (func $0x5c i32.const 0x5c call $hex_log unreachable)
    (func $0x5d i32.const 0x5d call $hex_log unreachable)
    (func $0x5e i32.const 0x5e call $hex_log unreachable)
    (func $0x5f i32.const 0x5f call $hex_log unreachable)

    (func $0x60 i32.const 0x60 call $hex_log unreachable)
    (func $0x61 i32.const 0x61 call $hex_log unreachable)
    (func $0x62 i32.const 0x62 call $hex_log unreachable)
    (func $0x63 i32.const 0x63 call $hex_log unreachable)
    (func $0x64 i32.const 0x64 call $hex_log unreachable)
    (func $0x65 i32.const 0x65 call $hex_log unreachable)
    (func $0x66 i32.const 0x66 call $hex_log unreachable)
    (func $0x67 i32.const 0x67 call $hex_log unreachable)
    (func $0x68 i32.const 0x68 call $hex_log unreachable)
    (func $0x69 i32.const 0x69 call $hex_log unreachable)
    (func $0x6a i32.const 0x6a call $hex_log unreachable)
    (func $0x6b i32.const 0x6b call $hex_log unreachable)
    (func $0x6c i32.const 0x6c call $hex_log unreachable)
    (func $0x6d i32.const 0x6d call $hex_log unreachable)
    (func $0x6e i32.const 0x6e call $hex_log unreachable)
    (func $0x6f i32.const 0x6f call $hex_log unreachable)

    (func $0x70 i32.const 0x70 call $hex_log unreachable)
    (func $0x71 i32.const 0x71 call $hex_log unreachable)
    (func $0x72 i32.const 0x72 call $hex_log unreachable)
    (func $0x73 i32.const 0x73 call $hex_log unreachable)
    (func $0x74 i32.const 0x74 call $hex_log unreachable)
    (func $0x75 i32.const 0x75 call $hex_log unreachable)
    (func $0x76 i32.const 0x76 call $hex_log unreachable)
    (func $0x77 i32.const 0x77 call $hex_log unreachable)
    (func $0x78 i32.const 0x78 call $hex_log unreachable)
    (func $0x79 i32.const 0x79 call $hex_log unreachable)
    (func $0x7a i32.const 0x7a call $hex_log unreachable)
    (func $0x7b i32.const 0x7b call $hex_log unreachable)
    (func $0x7c i32.const 0x7c call $hex_log unreachable)
    (func $0x7d i32.const 0x7d call $hex_log unreachable)
    (func $0x7e i32.const 0x7e call $hex_log unreachable)
    (func $0x7f i32.const 0x7f call $hex_log unreachable)

    (func $0x80 i32.const 0x80 call $hex_log unreachable)
    (func $0x81 i32.const 0x81 call $hex_log unreachable)
    (func $0x82 i32.const 0x82 call $hex_log unreachable)
    (func $0x83 i32.const 0x83 call $hex_log unreachable)
    (func $0x84 i32.const 0x84 call $hex_log unreachable)
    (func $0x85 i32.const 0x85 call $hex_log unreachable)
    (func $0x86 i32.const 0x86 call $hex_log unreachable)
    (func $0x87 i32.const 0x87 call $hex_log unreachable)
    (func $0x88 i32.const 0x88 call $hex_log unreachable)
    (func $0x89 i32.const 0x89 call $hex_log unreachable)
    (func $0x8a i32.const 0x8a call $hex_log unreachable)
    (func $0x8b i32.const 0x8b call $hex_log unreachable)
    (func $0x8c i32.const 0x8c call $hex_log unreachable)
    (func $0x8d i32.const 0x8d call $hex_log unreachable)
    (func $0x8e i32.const 0x8e call $hex_log unreachable)
    (func $0x8f i32.const 0x8f call $hex_log unreachable)

    (func $0x90 i32.const 0x90 call $hex_log unreachable)
    (func $0x91 i32.const 0x91 call $hex_log unreachable)
    (func $0x92 i32.const 0x92 call $hex_log unreachable)
    (func $0x93 i32.const 0x93 call $hex_log unreachable)
    (func $0x94 i32.const 0x94 call $hex_log unreachable)
    (func $0x95 i32.const 0x95 call $hex_log unreachable)
    (func $0x96 i32.const 0x96 call $hex_log unreachable)
    (func $0x97 i32.const 0x97 call $hex_log unreachable)
    (func $0x98 i32.const 0x98 call $hex_log unreachable)
    (func $0x99 i32.const 0x99 call $hex_log unreachable)
    (func $0x9a i32.const 0x9a call $hex_log unreachable)
    (func $0x9b i32.const 0x9b call $hex_log unreachable)
    (func $0x9c i32.const 0x9c call $hex_log unreachable)
    (func $0x9d i32.const 0x9d call $hex_log unreachable)
    (func $0x9e i32.const 0x9e call $hex_log unreachable)
    (func $0x9f i32.const 0x9f call $hex_log unreachable)

    (func $0xa0 i32.const 0xa0 call $hex_log unreachable)
    (func $0xa1 i32.const 0xa1 call $hex_log unreachable)
    (func $0xa2 i32.const 0xa2 call $hex_log unreachable)
    (func $0xa3 i32.const 0xa3 call $hex_log unreachable)
    (func $0xa4 i32.const 0xa4 call $hex_log unreachable)
    (func $0xa5 i32.const 0xa5 call $hex_log unreachable)
    (func $0xa6 i32.const 0xa6 call $hex_log unreachable)
    (func $0xa7 i32.const 0xa7 call $hex_log unreachable)
    (func $0xa8 ;; XOR B
        get_global $reg_b_addr
        get_global $reg_a_addr
        call $_xor8
    )
    (func $0xa9 ;; XOR C
        get_global $reg_c_addr
        get_global $reg_a_addr
        call $_xor8
    )
    (func $0xaa ;; XOR D
        get_global $reg_d_addr
        get_global $reg_a_addr
        call $_xor8
    )
    (func $0xab ;; XOR E
        get_global $reg_e_addr
        get_global $reg_a_addr
        call $_xor8
    )
    (func $0xac ;; XOR H
        get_global $reg_h_addr
        get_global $reg_a_addr
        call $_xor8
    )
    (func $0xad ;; XOR L
        get_global $reg_l_addr
        get_global $reg_a_addr
        call $_xor8
    )
    (func $0xae ;; XOR HL
        i32.const 0xae call $hex_log unreachable)
    (func $0xaf ;; XOR A
        get_global $reg_a_addr
        get_global $reg_a_addr
        call $_xor8
    )

    (func $0xb0 i32.const 0xb0 call $hex_log unreachable)
    (func $0xb1 i32.const 0xb1 call $hex_log unreachable)
    (func $0xb2 i32.const 0xb2 call $hex_log unreachable)
    (func $0xb3 i32.const 0xb3 call $hex_log unreachable)
    (func $0xb4 i32.const 0xb4 call $hex_log unreachable)
    (func $0xb5 i32.const 0xb5 call $hex_log unreachable)
    (func $0xb6 i32.const 0xb6 call $hex_log unreachable)
    (func $0xb7 i32.const 0xb7 call $hex_log unreachable)
    (func $0xb8 ;; CP B
        get_global $reg_b_addr
        call $_cp8_reg
    )
    (func $0xb9 ;; CP C
        get_global $reg_c_addr
        call $_cp8_reg
    )
    (func $0xba ;; CP D
        get_global $reg_d_addr
        call $_cp8_reg
    )
    (func $0xbb ;; CP E
        get_global $reg_e_addr
        call $_cp8_reg
    )
    (func $0xbc ;; CP H
        get_global $reg_h_addr
        call $_cp8_reg
    )
    (func $0xbd ;; CP L
        get_global $reg_l_addr
        call $_cp8_reg
    )
    (func $0xbe i32.const 0xbe call $hex_log unreachable)
    (func $0xbf ;; CP A 
        get_global $reg_a_addr
        call $_cp8_reg
    )

    (func $0xc0 i32.const 0xc0 call $hex_log unreachable)
    (func $0xc1 i32.const 0xc1 call $hex_log unreachable)
    (func $0xc2 i32.const 0xc2 call $hex_log unreachable)
    (func $0xc3 ;; JP nn
        get_global $pc_addr
        get_global $pc_addr
        i32.load
        (i32.store (i32.load16_u))
    )
    (func $0xc4 i32.const 0xc4 call $hex_log unreachable)
    (func $0xc5 i32.const 0xc5 call $hex_log unreachable)
    (func $0xc6 i32.const 0xc6 call $hex_log unreachable)
    (func $0xc7 i32.const 0xc7 call $hex_log unreachable)
    (func $0xc8 i32.const 0xc8 call $hex_log unreachable)
    (func $0xc9 i32.const 0xc9 call $hex_log unreachable)
    (func $0xca i32.const 0xca call $hex_log unreachable)
    (func $0xcb i32.const 0xcb call $hex_log unreachable)
    (func $0xcc i32.const 0xcc call $hex_log unreachable)
    (func $0xcd i32.const 0xcd call $hex_log unreachable)
    (func $0xce i32.const 0xce call $hex_log unreachable)
    (func $0xcf i32.const 0xcf call $hex_log unreachable)

    (func $0xd0 i32.const 0xd0 call $hex_log unreachable)
    (func $0xd1 i32.const 0xd1 call $hex_log unreachable)
    (func $0xd2 i32.const 0xd2 call $hex_log unreachable)
    (func $0xd3 i32.const 0xd3 call $hex_log unreachable)
    (func $0xd4 i32.const 0xd4 call $hex_log unreachable)
    (func $0xd5 i32.const 0xd5 call $hex_log unreachable)
    (func $0xd6 i32.const 0xd6 call $hex_log unreachable)
    (func $0xd7 i32.const 0xd7 call $hex_log unreachable)
    (func $0xd8 i32.const 0xd8 call $hex_log unreachable)
    (func $0xd9 i32.const 0xd9 call $hex_log unreachable)
    (func $0xda i32.const 0xda call $hex_log unreachable)
    (func $0xdb i32.const 0xdb call $hex_log unreachable)
    (func $0xdc i32.const 0xdc call $hex_log unreachable)
    (func $0xdd i32.const 0xdd call $hex_log unreachable)
    (func $0xde i32.const 0xde call $hex_log unreachable)
    (func $0xdf i32.const 0xdf call $hex_log unreachable)

    (func $0xe0 ;; LDH (n),A
        i32.const 0xff00
        get_global $pc_addr
        i32.load
        i32.load8_u
        i32.add

        get_global $reg_a_addr

        (i32.store (i32.load8_u))

        call $_pc++
    )
    (func $0xe1 i32.const 0xe1 call $hex_log unreachable)
    (func $0xe2 i32.const 0xe2 call $hex_log unreachable)
    (func $0xe3 i32.const 0xe3 call $hex_log unreachable)
    (func $0xe4 i32.const 0xe4 call $hex_log unreachable)
    (func $0xe5 i32.const 0xe5 call $hex_log unreachable)
    (func $0xe6 i32.const 0xe6 call $hex_log unreachable)
    (func $0xe7 i32.const 0xe7 call $hex_log unreachable)
    (func $0xe8 i32.const 0xe8 call $hex_log unreachable)
    (func $0xe9 i32.const 0xe9 call $hex_log unreachable)
    (func $0xea i32.const 0xea call $hex_log unreachable)
    (func $0xeb i32.const 0xeb call $hex_log unreachable)
    (func $0xec i32.const 0xec call $hex_log unreachable)
    (func $0xed i32.const 0xed call $hex_log unreachable)
    (func $0xee i32.const 0xee call $hex_log unreachable)
    (func $0xef i32.const 0xef call $hex_log unreachable)

    (func $0xf0 ;; LDH A,(n)
        get_global $reg_a_addr

        i32.const 0xff00
        get_global $pc_addr
        i32.load
        i32.load8_u
        i32.add

        (i32.store (i32.load8_u))

        call $_pc++
    )
    (func $0xf1 i32.const 0xf1 call $hex_log unreachable)
    (func $0xf2 i32.const 0xf2 call $hex_log unreachable)
    (func $0xf3 ;; DI
        get_global $i_master
        call $_clear_interrupt  ;; TODO rename this function
    )
    (func $0xf4 i32.const 0xf4 call $hex_log unreachable)
    (func $0xf5 i32.const 0xf5 call $hex_log unreachable)
    (func $0xf6 i32.const 0xf6 call $hex_log unreachable)
    (func $0xf7 i32.const 0xf7 call $hex_log unreachable)
    (func $0xf8 i32.const 0xf8 call $hex_log unreachable)
    (func $0xf9 i32.const 0xf9 call $hex_log unreachable)
    (func $0xfa i32.const 0xfa call $hex_log unreachable)
    (func $0xfb ;; EI
        get_global $i_master
        call $_set_interrupt  ;; TODO rename this function
    )
    (func $0xfc i32.const 0xfc call $hex_log unreachable)
    (func $0xfd i32.const 0xfd call $hex_log unreachable)
    (func $0xfe ;; CP n
        get_global $reg_a_addr
        i32.load8_u

        get_global $pc_addr
        i32.load
        i32.load8_u

        call $_cp8

        call $_pc++

        get_global $pc_addr
        i32.load
        i32.load8_u
        call $hex_log
    )
    (func $0xff ;; RST 38
        i32.const 0x0038
        call $_rst
    )

    (func $_cp8_reg (param $reg_addr i32)
        get_global $reg_a_addr
        i32.load8_u

        get_local $reg_addr
        i32.load8_u

        call $_cp8
    )

    (func $_cp8 (param $reg_val i32) (param $cmp_val i32)
        ;; check if values are the same
        block $false
            block $true
                get_local $reg_val
                get_local $cmp_val
                
                i32.eq

                br_if $true

                get_global $flag_z
                call $_clear_flag

                br $false
            end

            get_global $flag_z
            call $_set_flag
        end
	
        ;; check for borrow from bit 4
        block $false
            block $true
                get_local $cmp_val
                i32.const 0x0f
                i32.and

                get_local $reg_val
                i32.const 0xf0
                i32.and

                i32.gt_u

                br_if $true

                get_global $flag_h
                call $_clear_flag

                br $false
            end

            get_global $flag_h
            call $_set_flag
        end

        ;; A < C
        block $false
            block $true
                get_local $cmp_val
                get_local $reg_val

                i32.gt_u
                br_if $true

                get_global $flag_c
                call $_clear_flag

                br $false
            end

            get_global $flag_c
            call $_set_flag
        end

        get_global $flag_n
        call $_set_flag
    )

    (func $_dec8 (param $reg_addr i32)
        ;; check whether the half-carry flag
        ;; needs to be set
        block $exit
            block $eqz
                get_local $reg_addr
                i32.load8_u

                i32.const 0x0f
                
                i32.and
                i32.eqz
                br_if $eqz
               
                get_global $flag_h
                call $_clear_flag
                br $exit
            end

            get_global $flag_h
            call $_set_flag
        end

        get_local $reg_addr
        get_local $reg_addr
        i32.load8_u
        i32.const 1
        (i32.store8 (i32.sub))

        ;; set (non)zero flags accordingly
        block $exit
            block $neqz
                get_local $reg_addr
                i32.load8_u

                br_if $neqz

                get_global $flag_z
                call $_set_flag
                br $exit
            end

            get_global $flag_z
            call $_clear_flag
        end

        get_global $flag_n
        call $_set_flag
    )

    (func $_jp (param $addr i32)
        get_global $pc_addr
        get_local $addr
        (i32.store)
    )

    (func $_load8 (param $reg_addr i32)
        get_local $reg_addr
        get_global $pc_addr
        i32.load
        (i32.store8 (i32.load8_u))
        
        call $_pc++
    )

    (func $_load16 (param $reg_addr i32)
        get_local $reg_addr
        get_global $pc_addr
        i32.load
        (i32.store16 (i32.load16_u))

        call $_pc++
        call $_pc++
    )

    (func $_rst (param $addr i32)
        ;; push current address onto stack
        get_global $pc_addr
        i32.load
        i32.const 1
        i32.sub
        call $stack_push

        ;; jmp
        get_global $pc_addr
        (i32.store (get_local $addr))
    )

    (func $_xor8 (param $src_reg_addr i32) (param $tgt_reg_addr i32)
        get_local $tgt_reg_addr

        ;; get value of target register
        get_local $tgt_reg_addr
        i32.load8_u

        ;; get value at source register
        get_local $src_reg_addr
        i32.load8_u

        ;; xor and store result in reg
        (i32.store8 (i32.xor))

        ;; set flag z if result is zero
        block $exit
            get_local $tgt_reg_addr
            i32.load8_u
            i32.eqz
            i32.const 0
            
            i32.eq
            br_if $exit

            get_global $flag_z
            call $_set_flag
        end

        ;; clear other flags
        get_global $flag_c
        call $_clear_flag

        get_global $flag_h
        call $_clear_flag

        get_global $flag_n
        call $_clear_flag
    )

    (func $_check_flag (param $flag i32) (result i32)
        get_global $reg_f_addr
        i32.load8_u

        get_local $flag

        i32.and
    )

    (func $_set_flag (param $flag i32)
        get_global $reg_f_addr

        get_global $reg_f_addr
        i32.load8_u

        get_local $flag

        (i32.store8 (i32.or))
    )

    (func $_clear_flag (param $flag i32)
        get_global $reg_f_addr

        get_global $reg_f_addr
        i32.load8_u

        get_local $flag
        call $_not

        (i32.store8 (i32.and))
    )

    (func $_not (param $value i32) (result i32)
        i32.const 0xff
        get_local $value
        i32.sub
    )

    ;;
    ;; TODO - these are identical to flag reg
    ;;        operations. Don't duplicate code!
    ;;        Also, poorly named, as set/clear
    ;;        apply to master/enable, not just
    ;;        interrupt flags.
    ;;

    (func $_check_interrupt (param $flag i32) (result i32)
        get_global $i_addr
        i32.load8_u

        get_local $flag

        i32.and
    )

    (func $_set_interrupt (param $flag i32)
        get_global $i_addr

        get_global $i_addr
        i32.load8_u

        get_local $flag

        (i32.store8 (i32.or))
    )

    (func $_clear_interrupt (param $flag i32)
        get_global $i_addr

        get_global $i_addr
        i32.load8_u

        get_local $flag
        call $_not

        (i32.store8 (i32.and))
    )
)