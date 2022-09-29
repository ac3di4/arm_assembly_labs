	.arch armv8-a
//	res=a*(-b)*(c/(e+d))-(d+b)/e
//	all signed 16 bits
	.data
	.align	3
res:
	.skip	8
a:
	.2byte	-2
b:
	.2byte	1
c:
	.2byte	2
d:
	.2byte	1
e:
	.2byte	-1
	.text
	.align	2
	.global _start
	.type	_start, %function
_start:
// load everything
	adr	x0, a
	ldrsh	w1, [x0]
	adr	x0, b
	ldrsh	w2, [x0]
	adr	x0, c
	ldrsh	x3, [x0]
	adr	x0, d
	ldrsh	w4, [x0]
	adr	x0, e
	ldrsh	w5, [x0]
// calculations
// for errors:
	mov	x0, #1
// first sub arg
	add	w6, w4, w5 // (e + d)
	cbz	w6, exit_err
	mneg	w7, w1, w2 // a * (-b)
	sdiv	w6, w3, w6 // c / _
	smull	x6, w6, w7 // a * (-b) * c / (d + e)
// second sub arg
	add	w7, w2, w4
	cbz	w7, exit_err
	sdiv	w7, w7, w5
// result
	sub	x6, x6, w7, sxtw
	adr	x0, res
	str	x6, [x0]
// exit
	mov	x0, #0
exit_err:
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
