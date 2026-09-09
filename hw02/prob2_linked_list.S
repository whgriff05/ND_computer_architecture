#pragma qtrvsim show registers
#pragma qtrvsim show memory

.globl _start
.option norelax


.text

_start:
    # Get number of elements
    la x5, num_elements
    lw x10, 0x0(x5)

    # Get head pointer
    la x5, array_data
    addi x11, x5, 0x500

    # Inter-list spacing
    addi x16, x0, 0x40
    # Spacing between array and list
    addi x17, x0, 0x500


    # Ideas
    # x12: Address of array element
    # x13: Address of list element
    # x14: Address of previous list element (keep track)

    # Initial values for converting array -> list
    la x12, array_data
    add x13, x0, x11
    add x14, x0, x0

    # Counter
    add x15, x0, x0

    # Loop to add array elements to list
insertLoop:
    # Insert function
    jal x1, insert

    # Increment counter, move array element pointer to next element
    addi x15, x15, 1    
    addi x12, x12, 0x4

    # Set new previous list element to current's address
    mv x14, x13

    # Add offset to current list element's address to get new list element's address
    add x13, x13, x16

    # If counter is not the number of array elements, keep looping
    bne x15, x10, insertLoop

exit:
    # Stop
    ebreak

    
# Insert function
insert:
    # Store previous list element address
    sw x14, 0x0(x13)

    # Get and store array element data
    lw x6, 0x0(x12)
    sw x6, 0x4(x13)
    
    # Set previous list element's next address to current (if a previous list element exists)
    beq x0, x14, insert_end
insert_has_prev_element:
    sw x13, 0x8(x14)

insert_end:
	# Exit function
    jr x1

.data

# From Problem 2 statement
.org 0x3000
num_elements:
    .word 0x8
array_data:
    .word 0x596F, 0x7520, 0x6172, 0x6520, 0x6120, 0x626F, 0x6C64, 0x2031

