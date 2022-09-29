/*
    Lab4: find iverse matrix (double)
    Input: filename as program arg
    Output: stdout

    Helper: https://www.geeksforgeeks.org/adjoint-inverse-matrix/
 */
    .arch   armv8-a
    .data
    .align  3


/*
    Main function
    Max matrix size - 20
 */
    .global main
    .type   main, %function
    .data
    .align  3

e_usg:
    .string "Usage: %s [filename]\n"

e_inv:
    .string "No inverse for such matrix\n"

    .equ    size, 16        // matrix (and it's inverse) size
    .equ    matrix, 32
    .equ    inverse, 3232       // matrix inverse
    .equ    main_stack, 6432

    .text
    .align  2

main:
    mov x2, main_stack
    sub sp, sp, x2
    stp x29, x30, [sp]
    mov x29, sp

    // check argc
    cmp x0, #2
    bne main_usg

    // load matrix from file
    ldr	x0, [x1, #8]
    add x1, x29, size
    add x2, x29, matrix
    bl  loadm
    cbnz    x0, main_end

    // find inverse
    ldr x0, [x29, size]
    add x1, x29, matrix
    add x2, x29, inverse
    bl  inv
    
    cbz x0, main_inv
    
    ldr x0, [x29, size]
    add x1, x29, inverse
    bl  printm

main_end:
    ldp x29, x30, [sp]
    mov x2, main_stack
    add sp, sp, x2
    ret

main_usg:
    // usage error
    ldr	x2, [x1]
	adr	x0, stderr
	ldr	x0, [x0]
	adr	x1, e_usg
	bl	fprintf
    mov x0, #1
    b   main_end

main_inv:
    // no inverse matrix error
    adr x0, e_inv
    adr x1, stderr
    ldr x1, [x1]
    bl  fputs
    mov x0, #1
    b   main_end

    .size   main, .-main


/*
    Load matrix from file by it's filename
    MATRIX IS RESTRICTED TO 20x20 SIZE MAX
    Matrix input format example:
    2
    1 2
    3 4
    Input:
        x0 - filename
        x1 - matrix size (by pointer)
        x2 - matrix
    Output:
        x0 - 0 if ok (1 on error)
 */
    .type   loadm, %function
    .data
    .align  3

mode_r:
    .string "r"

fmt_d:
    .string "%d"

fmt_lf:
    .string "%lf"

perr_loadm:
    .string "loadm"

e_msize:
    .string "Matrix size must be 0 < size <= 20\n"
    
    .equ    size, 16
    .equ    matrix, 24
    .equ    file, 32
    .equ    i, 40
    .equ    loadm_stack, 48

    .text
    .align  2

loadm:
    sub sp, sp, loadm_stack
    stp x29, x30, [sp]
    mov x29, sp
    
    str x1, [x29, size]
    str x2, [x29, matrix]

    // open file
    adr	x1, mode_r
    bl  fopen
    cbz x0, loadm_e0

    str x0, [x29, file]

    // read size
    adr	x1, fmt_d
    ldr x2, [x29, size]
    bl  fscanf

    cmp x0, #1
    bne loadm_e1

    // check size
    ldr x0, [x29, size]
    ldr x1, [x0]
    cmp x1, #0
    beq loadm_e2
    cmp x1, #20
    bhi loadm_e2

    // use size as array len (matrix as array)
    mul x1, x1, x1
    str x1, [x29, size]

    // setup i
    mov x0, #-1

loadm_lp:
    add x0, x0, #1
    ldr x1, [x29, size]
    cmp x0, x1
    bhs loadm_ok

    // store i
    str x0, [x29, i]

    // read num
    lsl x3, x0, #3
    ldr x0, [x29, file]
	adr	x1, fmt_lf
    ldr x2, [x29, matrix]
    add x2, x2, x3
	bl	fscanf

    cmp x0, #1
    bne loadm_e1

    ldr x0, [x29, i]
    b   loadm_lp

loadm_ok:
    // matrix successfuly read
    mov x0, #0

loadm_end:
    ldp x29, x30, [sp]
    add sp, sp, loadm_stack
    ret

loadm_e0:
    // open/close error
    adr x0, perr_loadm
    bl  perror
    mov x0, #1
    b   loadm_end

loadm_e1:
    // read error
    ldr x0, [x29, file]
    bl  fclose
    b   loadm_e0

loadm_e2:
    // incorrect matrix size
	adr	x0, e_msize
    adr	x1, stderr
	ldr	x1, [x1]
	bl	fputs
    mov x0, #1
    b   loadm_end

    .size   loadm, .-loadm


/*
    Find inverse matrix
    Input:
        x0 - matrix size
        x1 - matrix
        x2 - it's inverse (to store result)
    Output:
        x0 - 0 if no inverse (else 1)
 */
    .type   inv, %function
    
    .equ    size, 16
    .equ    matrix, 24
    .equ    inverse, 32
    .equ    determinant, 40
    .equ    adjoint, 48
    .equ    inv_stack, 3248
    
    .text
    .align  2

inv:
    sub sp, sp, inv_stack
    stp x29, x30, [sp]
    mov x29, sp

    str x0, [x29, size]
    str x1, [x29, matrix]
    str x2, [x29, inverse]

    // check for det
    bl  det
    fcmp    d0, #0.0
    beq inv_det0
    str d0, [x29, determinant]

    // call adjoint
    ldr x0, [x29, size]
    ldr x1, [x29, matrix]
    add x2, x29, adjoint
    bl  adj

    // return code
    mov x0, #1
    
    // i = -1 and others
    mov x1, #-1
    ldr x2, [x29, size]
    mul x2, x2, x2
    add x3, x29, adjoint
    ldr x4, [x29, inverse]
    ldr d0, [x29, determinant]

inv_lp:
    add x1, x1, #1
    cmp x1, x2
    bhs inv_end

    // get adjoint[i]
    ldr d1, [x3, x1, lsl #3]

    // divide it by det
    fdiv    d1, d1, d0

    // save as inverse[i]
    str d1, [x4, x1, lsl #3]

    b   inv_lp

inv_end:
    ldp x29, x30, [sp]
    add sp, sp, inv_stack
    ret

inv_det0:
    mov x0, #0
    b   inv_end
    
    .size   inv, .-inv


/*
    Calc matrix determinant
    Input:
        x0 - matrix size
        x1 - matrix
    Output:
        d0 - determinant
 */
    .type   det, %function
    
    .equ    size, 16
    .equ    matrix, 24
    .equ    determinant, 32
    .equ    sign, 40
    .equ    i, 48
    .equ    temp, 56
    .equ    det_stack, 3256
    
    .text
    .align  2

det:
    cmp x0, #1
    beq det_1

    sub sp, sp, det_stack
    stp x29, x30, [sp]
    mov x29, sp

    str x0, [x29, size]
    str x1, [x29, matrix]

    // det = 0
    fmov    d0, xzr

    // sign = 1
    fmov    d1, #1.0
    str d1, [x29, sign]

    // i = -1
    mov x3, #-1

det_lp:
    add x3, x3, #1
    ldr x0, [x29, size]
    cmp x3, x0
    bhs det_end

    str x3, [x29, i]
    str d0, [x29, determinant]

    // get cofactor
    ldr x1, [x29, matrix]
    mov x2, #0
    add x4, x29, temp
    bl  cofact

    // recursive call
    ldr x0, [x29, size]
    sub x0, x0, #1
    add x1, x29, temp
    bl  det

    // get matrix[0][i]
    ldr x0, [x29, matrix]
    ldr x1, [x29, i]
    ldr d1, [x0, x1, lsl #3]

    ldr d2, [x29, sign]

    fmul    d0, d0, d1
    fmul    d0, d0, d2
    ldr d1, [x29, determinant]
    fadd    d0, d0, d1

    // sign = -sign
    fneg d2, d2
    str d2, [x29, sign]

    ldr x3, [x29, i]
    b   det_lp

det_end:
    ldp x29, x30, [sp]
    add sp, sp, det_stack
    ret

det_1:
    // matrix consists of 1 element
    ldr d0, [x1]
    ret

    .size   det, .-det


/*
    Get adjoint
    Input:
        x0 - matrix size
        x1 - input matrix
        x2 - output matrix (adjoint)
 */
    .type   adj, %function
    
    .equ    size, 16
    .equ    matrix, 24
    .equ    adjoint, 32
    .equ    i, 40
    .equ    j, 48
    .equ    sign, 56
    .equ    temp, 64
    .equ    adj_stack, 3264
    
    .text
    .align  2

adj:
    cmp x0, #1
    beq adj_1

    sub sp, sp, adj_stack
    stp x29, x30, [sp]
    mov x29, sp

    str x0, [x29, size]
    str x1, [x29, matrix]
    str x2, [x29, adjoint]

    // i = -1
    mov x0, #-1

adj_row:
    add x0, x0, #1
    ldr x1, [x29, size]
    cmp x0, x1
    bhs adj_end

    str x0, [x29, i]

    // j = -1
    mov x1, #-1

    fmov    d2, #1.0
    fmov    d3, #-1.0

adj_col:
    add x1, x1, #1
    ldr x2, [x29, size]
    cmp x1, x2
    bhs adj_row_end

    str x1, [x29, j]

    // call cofactor
    ldr x2, [x29, i]
    mov x3, x1
    ldr x0, [x29, size]
    ldr x1, [x29, matrix]
    add x4, x29, temp
    bl  cofact

    // calc sign (if even)
    ldr x0, [x29, i]
    ldr x1, [x29, j]
    add x0, x0, x1

    fmov    d1, #1.0
    tst x0, #1
    beq adj_col_sign
    fmov    d1, #-1.0
adj_col_sign:
    str d1, [x29, sign]

    // call det
    ldr x0, [x29, size]
    sub x0, x0, #1
    add x1, x29, temp
    bl  det

    ldr d1, [x29, sign]
    fmul    d0, d0, d1

    // save res to adj[j][i]
    ldr x0, [x29, j]
    ldr x1, [x29, size]
    mul x0, x0, x1
    ldr x1, [x29, i]
    add x0, x0, x1
    ldr x2, [x29, adjoint]
    str d0, [x2, x0, lsl #3]

    ldr x1, [x29, j]
    b   adj_col

adj_row_end:
    ldr x0, [x29, i]
    b   adj_row

adj_end:
    ldp x29, x30, [sp]
    add sp, sp, adj_stack
    ret

adj_1:
    // adjoint of matrix of 1 element
    fmov    d0, #1.0
    str d0, [x2]
    ret

    .size   adj, .-adj

/*
    Get cofactor of matrix[p][q]
    Input:
        x0 - matrix size
        x1 - input matrix
        x2 - p
        x3 - q
        x4 - output matrix
 */
    .type   cofact, %function
    .text
    .align  2

cofact:
    // save n - 1 (output matrix size)
    sub x10, x0, #1

    // i = j = 0
    mov x5, #0
    mov x6, #0

    // row = -1
    mov x7, #-1

cofact_row:
    add x7, x7, #1
    cmp x7, x0
    bhs cofact_end

    // check if row excluded
    cmp x7, x2
    beq cofact_row

    // col = -1
    mov x8, #-1

cofact_col:
    add x8, x8, #1
    cmp x8, x0
    bhs cofact_row

    // check if column excluded
    cmp x8, x3
    beq cofact_col

    // get input[row][col]
    mul x9, x7, x0
    add x9, x9, x8
    ldr d0, [x1, x9, lsl #3]

    // output[i][j] = _
    mul x9, x5, x10
    add x9, x9, x6
    str d0, [x4, x9, lsl #3]

    // j++
    add x6, x6, #1

    // j == n - 1
    cmp x6, x10
    bne cofact_col

    // row is filled
    mov x6, #0
    add x5, x5, #1

    b   cofact_col

cofact_end:
    ret

    .size   cofact, .-cofact

/*
    Print matrix to stdout
    Input:
        x0 - matrix size
        x1 - matrix
    Output:
        x0 - 0 if ok (else 1)
 */
    .type   printm, %function
    .data
    .align  3

fmt_size:
    .string "%d\n"

fmt_elem:
    .string "%.2f "

fmt_empt:
    .string ""

perr_printm:
    .string "printm"

    .equ    size, 16
    .equ    matrix, 24
    .equ    i, 32
    .equ    j, 40
    .equ    offset, 48
    .equ    printm_stack, 64
    
    .text
    .align  2

printm:
    sub sp, sp, printm_stack
    stp x29, x30, [sp]
    mov x29, sp

    str x0, [x29, size]
    str x1, [x29, matrix]

    // print size
    mov x1, x0
    adr x0, fmt_size
    bl  printf

    cmp x0, #0
    blt printm_e

    // setup i
    mov x0, #-1

printm_l1:
    add x0, x0, #1
    ldr x1, [x29, size]
    cmp x0, x1
    bhs printm_ok

    str x0, [x29, i]
    
    // calc offset
    mul x0, x0, x1
    str x0, [x29, offset]

    mov x0, #-1

printm_l2:
    add x0, x0, #1
    ldr x1, [x29, size]
    cmp x0, x1
    bhs printm_nl

    str x0, [x29, j]

    // calc matrix[i * size + j]
    ldr x1, [x29, offset]
    add x1, x0, x1
    ldr x0, [x29, matrix]
    ldr d0, [x0, x1, lsl #3]

    // print element
    adr x0, fmt_elem
    bl printf

    ldr x0, [x29, j]
    b   printm_l2

printm_nl:
    // print \n
    adr x0, fmt_empt
    bl  puts

    ldr x0, [x29, i]
    b   printm_l1

printm_ok:
    // successfuly printed
    mov x0, #0

printm_end:
    ldp x29, x30, [sp]
    add sp, sp, printm_stack
    ret

printm_e:
    adr x0, perr_printm
    bl  perror
    mov x0, #1
    b   printm_end

    .size   printm, .-printm
