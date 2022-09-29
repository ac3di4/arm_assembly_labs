/* lab2: gnome sort all || secondary diagonal */
    .arch armv8-a
    .data
    .align  3
n:
    .byte   5
    .skip   3
data:
    .4byte  1, 2, 3, 4, 1
    .4byte  3, 8, 1, 5, 2
    .4byte  0, 1, 3, 8, 3
    .4byte  5, 5, 5, 5, -5
    .4byte  10, 20, 30, 40, 50
    .text
    .align  2
    .global _start
    .type   _start, %function
_start:
    adr x1, n
    ldrb    w0, [x1]
    adr x1, data
    // if (n <= 2) then done
    cmp w0, #2
    bls exit
    // N = n - 2
    sub w2, w0, #2
    // i = 1
    mov w3, #1
    // j = 0
    mov w4, #0
sort_setup:
    // copy i j
    mov w5, w3 // i1
    mov w6, w4 // j1
    // next element
    add w7, w5, #1 // i2
    sub w8, w6, #1 // j2
sort:
    // if (i1 >= n or j1 >= n)
    cmp w5, w0
    bhs sort_end
    cmp w6, w0
    bhs sort_end
    // w9 = i1 + j1 * n
    mul w9, w6, w0
    add w9, w9, w5
    // w10 = data[w9]
    lsl w9, w9, #2
    ldr w10, [x1, w9, uxtw]
    // w11 = i1 - 1 + (j1 + 1) * n
    add w11, w6, #1
    mul w11, w11, w0
    add w11, w11, w5
    sub w11, w11, #1
    // w12 = data[w11]
    lsl w11, w11, #2
    ldr w12, [x1, w11, uxtw]
    // sort check: cur vs prev
    cmp w10, w12
    .IFNDEF LTOH
    bgt sort_swap
    .ELSE
    blt sort_swap
    .ENDIF
sort_next:
    // move i1 j1
    mov w5, w7
    mov w6, w8
    // set next
    add w7, w7, #1
    sub w8, w8, #1
    b   sort 
sort_swap:
    // swap cur and prev
    str w10, [x1, w11, uxtw]
    str w12, [x1, w9, uxtw]
    // if (i1 == 0 or j1 == n - 1) then back
    sub w5, w5, #1
    add w6, w6, #1
    cbz w5, sort_next
    cmp w6, w2 // j1 == n - 1 <=> h1 > n - 2
    bhi sort_next
    // else go further
    b   sort
sort_end:
    // if (j == n - 2) go right
    cmp w4, w2
    beq go_right
    add w4, w4, #1
    b   sort_setup
go_right:
    add w3, w3, #1
    cmp w3, w0
    bne sort_setup
exit:
    mov x0, #0
    mov x8, #93
    svc #0
    .size   _start, .-_start
