#pragma qtrvsim show registers
#pragma qtrvsim show memory

.globl _start
.option norelax


.text

_start:
	li x20, 1000
	li x4, 0x600
	li x5, 0x700
	
loop:
	bge x3, x20, out
	slli x10, x3, 2
	add x11, x4, x10
	lw x6, 0(x11)
	add x11, x5, x10
	lw x7, 4(x11)
	bge x6, x7, else
	sw x6, 4(x11)
	j end
else:
	sw x0, 4(x11)
end:
	addi x3, x3, 1
	j loop
	
out:
	ebreak



.data