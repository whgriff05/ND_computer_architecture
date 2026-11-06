//  hw07_class.S 
//  Populate array of incoming student class of 1024 students.
//  Array elements are spaced to allow for future data entry for students,
//  this program initially only fills id number and a course section (for first year seminar)

//  Created by @adingler for CSE30321,
//  based on simple-lw-sw-ia.S, (C) 2021 by Pavel Pisa
//      e-mail:   pisa@cmp.felk.cvut.cz
//      homepage: http://cmp.felk.cvut.cz/~pisa
//      work:     http://www.pikron.com/
//      license:  public domain


#pragma qtrvsim show registers
#pragma qtrvsim show memory

.globl _start
.option norelax

.text

_start:

	la x5, arr		//starting address of array
	la x6, arr_max	
	lw x6, 0(x6)    // gets arr_max value

	li x7, 0		//loop index, i = 0

	li x8, 10		//we will first fill a large array with student ID numbers, starting at 10
	li x11, 0		//section number

fill_loop:
	bge x7, x6, done_fill
	slli x9, x7, 2	//i * 4
	add x9, x9, x5	//&(arr + i * 4)
	sw x8, 0(x9)	//arr[i] = student id number
	
	rem x10, x11, x8 // Remainder is section number
	sw x10, 4(x9)
	
	addi x7, x7, 32
	addi x8, x8, 1
	addi x11, x11, 1
	j fill_loop
done_fill:
	ebreak

.data
.org 0x500
arr_max:
	.word 32768
	
.org 0x700
arr:
	.word  1
#pragma qtrvsim focus memory arr
