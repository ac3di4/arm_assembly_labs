/*
    Assembly realization of matrix convolution function;
    Due to my skills it actually might be slower than optimized C version :(
 */
    .global applym
    .type   applym, %function

    // Offset in BMPImage structure
    .equ    data, 0
    .equ    width, 8
    .equ    height, 12
    .equ    channels, 16

    .text
    .align  2

/*
    void applym(BMPImage *src, BMPImage *dst, const double m[3][3])
    x0 - src
    x1 - dst
    x2 - m
 */
applym:
    sub sp, sp, #16
    stp x29, x30, [sp]
    mov x29, sp

    // i = 0
    // mov x3, #0

    mov x4, #0
    ldrh    w4, [x0, height]
    sub x4, x4, #1

    mov x3, #2
    udiv    x3, x4, x3

applym_i:
    add x3, x3, #1
    cmp x3, x4
    bhs applym_end

    // j = 0
    mov x5, #0

    mov x6, #0
    ldr w6, [x0, width]
    sub x6, x6, #1

applym_j:
    add x5, x5, #1
    cmp x5, x6
    bhs applym_i

    // c = 0
    mov x7, #-1

    mov x8, #0
    ldr w8, [x0, channels]

applym_c:
    add x7, x7, #1
    cmp x7, x8
    bhs applym_j

    // check for alpha
    cmp x7, #3
    bhi applym_c

////////////////////////////////////////// CYCLE START ////////////////////////////////////////// 
    // work with x9-x19

    // px = 0
    mov x9, #0

///////////////////////////////// TOP

    // base = (i - 1) * src->width + (j - 1)
    sub x10, x3, #1
    mov x11, #0
    ldr w11, [x0, width]
    sub x12, x5, #1
    madd    x10, x10, x11, x12

    // base * channels + c
    madd    x11, x10, x8, x7

    // src->data[_]
    ldr x12, [x0, data]
    ldrb    w11, [x12, x11]
    ucvtf   d0, w11

    // _ * m[0][0]
    ldr d1, [x2, #0]
    fmul    d0, d0, d1

    // px += int(_)
    fcvtmu  x11, d0
    add x9, x9, x11

////////////////////

    // base += 1
    add x10, x10, #1

    // base * channels + c
    madd    x11, x10, x8, x7

    // src->data[_]
    ldr x12, [x0, data]
    ldrb    w11, [x12, x11]
    ucvtf   d0, w11

    // _ * m[0][1]
    ldr d1, [x2, #8]
    fmul    d0, d0, d1

    // px += int(_)
    fcvtmu  x11, d0
    add x9, x9, x11

////////////////////

    // base += 1
    add x10, x10, #1

    // base * channels + c
    madd    x11, x10, x8, x7

    // src->data[_]
    ldr x12, [x0, data]
    ldrb    w11, [x12, x11]
    ucvtf   d0, w11

    // _ * m[0][2]
    ldr d1, [x2, #16]
    fmul    d0, d0, d1

    // px += int(_)
    fcvtmu  x11, d0
    add x9, x9, x11

///////////////////////////////// MIDDLE

    // base - 2 + src->width
    // or: base - 1 + (src->width - 1)
    sub x10, x10, #1
    add x10, x10, x6

    // base * channels + c
    madd    x11, x10, x8, x7

    // src->data[_]
    ldr x12, [x0, data]
    ldrb    w11, [x12, x11]
    ucvtf   d0, w11

    // _ * m[1][0]
    ldr d1, [x2, #24]
    fmul    d0, d0, d1

    // px += int(_)
    fcvtmu  x11, d0
    add x9, x9, x11

////////////////////

    // base += 1
    add x10, x10, #1

    // base * channels + c
    madd    x11, x10, x8, x7

    // src->data[_]
    ldr x12, [x0, data]
    ldrb    w11, [x12, x11]
    ucvtf   d0, w11

    // _ * m[1][1]
    ldr d1, [x2, #32]
    fmul    d0, d0, d1

    // px += int(_)
    fcvtmu  x11, d0
    add x9, x9, x11

////////////////////

    // base += 1
    add x10, x10, #1

    // base * channels + c
    madd    x11, x10, x8, x7

    // src->data[_]
    ldr x12, [x0, data]
    ldrb    w11, [x12, x11]
    ucvtf   d0, w11

    // _ * m[1][2]
    ldr d1, [x2, #40]
    fmul    d0, d0, d1

    // px += int(_)
    fcvtmu  x11, d0
    add x9, x9, x11

///////////////////////////////// BOTTOM

    // base - 2 + src->width
    // or: base - 1 + (src->width - 1)
    sub x10, x10, #1
    add x10, x10, x6

    // base * channels + c
    madd    x11, x10, x8, x7

    // src->data[_]
    ldr x12, [x0, data]
    ldrb    w11, [x12, x11]
    ucvtf   d0, w11

    // _ * m[2][0]
    ldr d1, [x2, #48]
    fmul    d0, d0, d1

    // px += int(_)
    fcvtmu  x11, d0
    add x9, x9, x11

////////////////////

    // base += 1
    add x10, x10, #1

    // base * channels + c
    madd    x11, x10, x8, x7

    // src->data[_]
    ldr x12, [x0, data]
    ldrb    w11, [x12, x11]
    ucvtf   d0, w11

    // _ * m[2][1]
    ldr d1, [x2, #56]
    fmul    d0, d0, d1

    // px += int(_)
    fcvtmu  x11, d0
    add x9, x9, x11

////////////////////

    // base += 1
    add x10, x10, #1

    // base * channels + c
    madd    x11, x10, x8, x7

    // src->data[_]
    ldr x12, [x0, data]
    ldrb    w11, [x12, x11]
    ucvtf   d0, w11

    // _ * m[2][2]
    ldr d1, [x2, #64]
    fmul    d0, d0, d1

    // px += int(_)
    fcvtmu  x11, d0
    add x9, x9, x11


///////////////////////////////// SET PX

    // base = (i - 1) * dst->width + (j - 1)
    sub x10, x3, #1
    mov x11, #0
    ldr w11, [x1, width]
    sub x12, x5, #1
    madd    x10, x10, x11, x12

    // base * dst->channels + c
    mov x11, #0
    ldr w11, [x1, channels]
    madd    x10, x10, x11, x7

    // dst->data[_] = px
    ldr x11, [x1, data]
    strb    w9, [x11, x10]

////////////////////////////////////////// CYCLE END ////////////////////////////////////////// 

    b   applym_c

applym_end:
    ldp x29, x30, [sp]
    add sp, sp, #16
    ret

    .size   applym, .-applym
