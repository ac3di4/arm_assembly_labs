/*
    Lab3: delete all words != first one by length
    Input: File; filename in env INPUTFN
    Output: stdout
 */
    .arch   armv8-a


/*
    Initial setup:
    Find filename and call main
    Or call error
 */
    .global _start
    .type   _start, %function
    .data
    .align  3

env:
    .string "INPUTFN="
    .equ    env_shift, .-env-1
    
    .text
    .align  2

_start:
    // point x2 to \0 after argv
    ldr x2, [sp]
    add x2, x2, #2
    sub sp, sp, #8
    mov x29, sp

_start_lp:
    // search loop
    add x2, x2, #1
    ldr x0, [x29, x2, lsl #3]
    
    // check for end
    cbz x0, _start_nf

    // check env name
    str x2, [x29]
    adr x1, env
    bl  startsw
    ldr x2, [x29]
    cbz x0, _start_lp

    // env found => call main
    ldr x0, [x29, x2, lsl #3]
    add x0, x0, env_shift
    add sp, sp, #8
    mov x29, sp
    bl  main
    b   _start_end

_start_nf:
    // env not found
    bl  error
    add sp, sp, #8

_start_end:
    mov x8, #93
    svc #0

    .size   _start, .-_start


/*
    Check if first string starts with second
    Input: 
        x0, x1 - strings
    Output: 
        1 if it's true, else 0
 */
    .type   startsw, %function
    .text
    .align  2

startsw:
    mov x2, #-1

startsw_lp:
    add x2, x2, #1
    ldrsb   w3, [x0, x2]
    ldrsb   w4, [x1, x2]
    cbz w4, startsw_eq
    cbz w3, startsw_ne
    cmp w3, w4
    beq startsw_lp

startsw_ne:
    mov x0, #0
    ret

startsw_eq:
    mov x0, #1
    ret

    .size   startsw, .-startsw


/*
    Main function - setup and manage
    Input:
        x0 - filename
    Output:
        x0 - 0 if ok (1 on error)
 */
    .type   main, %function

    .data
    .align  2

    .equ    s, 16           // file mapped as string
    .equ    slen, 24        // file length
    .equ    mlen, 32        // mapped memory size
    .equ    i, 40
    .equ    main_stack, 48

    .text
    .align  2

main:
    sub sp, sp, main_stack
    stp x29, x30, [sp]
    mov x29, sp

    // Open file for work
    bl  gfile
    cbz x0, main_err
    
    str x0, [x29, s]
    str x1, [x29, slen]
    str x2, [x29, mlen]

    mov x1, #0

main_lp:
    // process one line
    ldr x0, [x29, s]
    bl  line
    cmp x0, #0
    blt main_munmap

    str x0, [x29, i]
    
    // print "\n"
    mov x0, '\n'
    bl  putc
    cbnz    x0, main_munmap

    // check for EOF
    ldr x0, [x29, flen]
    ldr x1, [x29, i]
    add x1, x1, #1
    cmp x0, x1
    bne main_lp

    mov x0, #0

main_munmap:
    // munmap (ret code saved)
    str x0, [x29, i]

    ldr x0, [x29, s]
    ldr x1, [x29, mlen]
    bl  munmap
    
    cmp x0, #0
    bne main_munmap_err

    ldr x0, [x29, i]
    b   main_end

main_munmap_err:
    bl error

main_end:
    ldp x29, x30, [sp]
    add sp, sp, main_stack
    ret

main_err:
    // file setup error
    mov x0, #1
    b   main_end

    .size   main, .-main


/*
    Process one line (string) ending with "\n"
    Errors handled
    Input:
        x0 - string
        x1 - line start
    Output:
        x0 - line end (-1 on error)
 */
    .type   line, %function

    .equ    s, 16
    .equ    i, 24
    .equ    wlen, 32
/**/.equ    wlen2, 40
    .equ    line_stack, 48

    .text
    .align  2

line:
    sub sp, sp, line_stack
    stp x29, x30, [sp]
    mov x29, sp
    str x0, [x29, s]

    // get first word
    bl  gword
    cbz x1, line_end // 0 words = empty string

    str x0, [x29, i]
    str x1, [x29, wlen]

    // print first word
    mov x2, x1
    mov x1, x0
    ldr x0, [x29, s]
    bl  putw

    // start loop with second word
    ldr x0, [x29, i]
    ldr x1, [x29, wlen]
    add x1, x0, x1

line_lp:
    ldr x0, [x29, s]
    bl  gword
    cbz x1, line_end    // loop end
    
    ldr x2, [x29, wlen]
    cmp x1, x2
    beq line_lp_eq

    str x0, [x29, i]
    str x1, [x29, wlen2]

    // print space
    mov x0, ' '
    bl  putc

    // print word
    ldr x0, [x29, s]
    ldr x1, [x29, i]
    ldr x2, [x29, wlen2]
    bl  putw
    cbnz    x0, line_err

    ldr x1, [x29, wlen2]
    ldr x0, [x29, i]

line_lp_eq:
    add x1, x0, x1
    b   line_lp
/* Доп задание (сделать вывод всех неравных первому)
    bne line_lp_ne

    str x0, [x29, i]

    // print space
    mov x0, ' '
    bl  putc

    // print word
    ldr x0, [x29, s]
    ldr x1, [x29, i]
    ldr x2, [x29, wlen]
    bl  putw
    cbnz    x0, line_err

    ldr x1, [x29, wlen]
    ldr x0, [x29, i]

line_lp_ne:
    add x1, x0, x1
    b   line_lp
*/

line_end:
    ldp x29, x30, [sp]
    add sp, sp, line_stack
    ret

line_err:
    mov x0, #-1
    b   line_end

    .size   line, .-line


/*
    Get next word - skip spaces and find word len
    With error handling
    Input:
        x0 - string
        x1 - starting position
    Output:
        x0 - word starting position
        x1 - word length (0 if no word found)
 */
    .type   gword, %function
    .text
    .align  2

gword:
    sub x1, x1, #1

gword_s:
    // skip spaces
    add x1, x1, #1
    ldrsb   w2, [x0, x1]

    cmp w2, ' '
    beq gword_s
    
    cmp w2, '\t'
    beq gword_s

    // save word start
    mov x3, x1
    sub x1, x1, #1

gword_w:
    // skip word
    add x1, x1, #1
    ldrsb   w2, [x0, x1]

    cmp w2, ' '
    beq gword_end

    cmp w2, '\t'
    beq gword_end

    cmp w2, '\n'
    beq gword_end

    b   gword_w

gword_end:    
    mov x0, x3
    sub x1, x1, x0
    ret


/*
    Print word on the screen and handle errors
    Input:
        x0 - string
        x1 - offset (word start)
        x2 - length
    Output:
        x0 - 0 if ok (1 on error)
 */
    .type   putw, %function
    .text
    .align  2

putw:
    add x1, x0, x1
    mov x0, #1
    mov x8, #64
    svc #0

    cmp x0, #0
    blt putw_err
    
    mov x0, #0
    ret

putw_err:
    bl  error
    mov x0, #1
    ret

    .size   putw, .-putw

/*
    Print one character on the screen and handle errors
    Input:
        x0 - character code
    Output:
        x0 - 0 if ok (1 on error)
 */
    .type   putc, %function
    .text
    .align  2

putc:
    // put char on stack
    sub sp, sp, #8
    str x0, [sp]

    // print it
    mov x0, #1
    mov x1, sp
    mov x2, #1
    mov x8, #64
    svc #0

    // restore stack & check for errors
    add sp, sp, #8
    cmp x0, #0
    blt putc_err

    mov x0, #0
    ret

putc_err:
    bl  error
    mov x0, #1
    ret

    .size   putc, .-putc


/*
    Setup file for work (open - mmap - close) with error handling
    Input:
        x0 - filename
    Output:
        x0 - mapped file address (0 on error)
        x1 - file length
        x2 - mapped memory size
 */
    .type   gfile, %function

    .equ    fd, 16          // file descriptor
    .equ    flen, 24        // file length
    .equ    fmp, 32         // mapped file
    .equ    mlen, 40        // mapped memory size
    .equ    gfile_stack, 48

    .text
    .align  2

gfile:
    sub sp, sp, gfile_stack
    stp x29, x30, [sp]
    mov x29, sp

    // open file
    bl  openr
    cmp x0, #0
    blt gfile_e0
    str x0, [x29, fd]

    // get file length
    bl  filelen
    cmp x0, #0
    beq gfile_e1 // empty file
    blt gfile_e2
    str x0, [x29, flen]

    // mmap file
    mov x1, x0
    ldr x0, [x29, fd]
    bl  mmap
    cmp x0, #0
    blt gfile_e2
    str x0, [x29, fmp]
    str x1, [x29, mlen]

    // close file
    ldr x0, [x29, fd]
    bl  close
    cmp x0, #0
    blt gfile_e3

    // All ok - set up return vals
    ldr x0, [x29, fmp]
    ldr x1, [x29, flen]
    ldr x2, [x29, mlen]

gfile_end:
    ldp x29, x30, [sp]
    add sp, sp, gfile_stack
    ret

gfile_e0:
    // open error
    bl  error

gfile_err:
    mov x0, #0
    b   gfile_end

gfile_e1:
    // file empty
    mov x0, #1
    bl  error
    b   gfile_err

gfile_e2:
    // file operations error (flen)
    // mmap error
    bl  error
    ldr x0, [x29, fd]
    bl  close
    b   gfile_err

gfile_e3:
    // file close error
    bl  error
    ldr x0, [x29, fmp]
    ldr x1, [x29, mlen]
    bl  munmap
    b   gfile_err

    .size   gfile, .-gfile


/*
    Open file for reading
    Input:
        x0 - filename
    Output:
        x0 - fd if ok (negative on error)
 */
    .type   openr, %function
    .text
    .align  2

openr:
    mov x1, x0
    mov x0, #-100
    mov x2, #0
    mov x8, #56
    svc #0
    ret

    .size   openr, .-openr


/*
    Close file
    Input:
        x0 - file descriptor
    Output:
        x0 - 0 if ok (negative on error)
 */
    .type   close, %function
    .text
    .align  2

close:
    mov x8, #57
    svc #0
    ret

    .size   close, .-close


/*
    Get file length & reset it's pointer to the start
    Input:
        x0 - fd
    Output:
        x0 - file length (negative on error)
 */
   .type   filelen, %function
    
    .equ    fd, 16
    .equ    flen, 24
    .equ    filelen_stack, 32

    .text
    .align  2

filelen:
    // saving fd and len on stack
    sub sp, sp, filelen_stack
    stp x29, x30, [sp]
    mov x29, sp
    str x0, [x29, fd]

    // get len
    mov x1, #0
    mov x2, #2
    mov x8, #62
    svc #0

    cmp x0, #0
    blt filelen_end
    str x0, [x29, flen]

    // move to start
    ldr x0, [x29, fd]
    mov x1, #0
    mov x2, #0
    mov x8, #62
    svc #0

    cmp x0, #0
    blt filelen_end
    ldr x0, [x29, flen]

filelen_end:
    ldp x29, x30, [sp]
    add sp, sp, filelen_stack
    ret

    .size   filelen, .-filelen


/*
    Mmap file
    Input:
        x0 - file descriptor
        x1 - file length
    Output:
        x0 - mapped file address
        x1 - mapped memory size 
 */
    .type   mmap, %function

    .equ    mlen, 16
    .equ    mmap_stack, 24

    .text
    .align  2

mmap:
    sub sp, sp, mmap_stack
    stp x29, x30, [sp]
    mov x29, sp

    mov x4, x0

    // count size
    mov x0, x1
    mov x2, #4096
    udiv    x1, x0, x2
    add x1, x1, #1
    mul x1, x1, x2
    str x1, [x29, mlen]

    // call mmap
    mov x0, #0
    mov x2, #1
    mov x3, #1
    mov x5, #0
    mov x8, #222
    svc #0

    cmp x0, #0
    blt mmap_end
    ldr x1, [x29, mlen]

mmap_end:
    ldp x29, x30, [sp]
    add sp, sp, mmap_stack
    ret

    .size   mmap, .-mmap


/*
    Munmap (aka anti mmap)
    Input:
        x0 - mapped file address
        x1 - mapped memory size
    Output:
        x0 - 0 if ok (negative on error)
 */
    .type   munmap, %function
    .text
    .align  2

munmap:
    mov x8, #215
    svc #0
    ret

    .size   munmap, .-munmap


/*
    Print errors by their code
    Syscall errors included
    Input: 
        x0 - error code
    Output: x0 = 1
 */
    .type   error, %function
    .data
    .align  3

    e_env:
        .string "Please specify input filename through INPUTFN env variable\n"
        .equ    e_env_len, .-e_env
    
    e_empty:
        .string "File is empty\n"
        .equ    e_empty_len, .-e_empty
    
    e_404:
        .string "No such file or directiory\n"
        .equ    e_404_len, .-e_404
    
    e_ndef:
        .string "Undefined error\n"
        .equ    e_ndef_len, .-e_ndef

    .text
    .align  2

error:
    cmp x0, #0
    bne 0f
    adr x1, e_env
    mov x2, e_env_len
    b   error_write
0:
    cmp x0, #1
    bne 0f
    adr x1, e_empty
    mov x2, e_empty_len
    b   error_write
0:
    cmp x0, #-2
    bne 0f
    adr x1, e_404
    mov x2, e_404_len
    b   error_write
0:
    adr x1, e_ndef
    mov x2, e_ndef_len
    b   error_write

error_write:
    mov x0, #2
    mov x8, #64
    svc #0
    mov x0, #1
    ret

    .size   error, .-error
