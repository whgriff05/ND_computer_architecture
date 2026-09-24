#pragma qtrvsim show registers
#pragma qtrvsim show memory

.globl _start
.option norelax


.text

_start:
    # Initialize stack pointer
    li x2, 0x2000

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

callGnomeSort:
    mv x12, x11
    jal x1, gnomeSort

callDeleteDupes:
    jal x1, deleteDupes

exit:
    # Stop
    ebreak

# Gnome Sort function (x12 is head)
gnomeSort:
    # Store head pointer
    mv x14, x12
    # Position node
    mv x13, x12

gnomeSortWhile:
    beqz x13, gnomeSortEnd

    beq x13, x12, gnomeSortAdvance # pos == 0

    lw x28, 0x0(x13) # Get previous node
    lw x29, 0x4(x13) # Current node value
    lw x30, 0x4(x28) # Previous node value
    bge x29, x30, gnomeSortAdvance # a[pos] >= a[pos-1]

    # Otherwise, call swap
    mv x10, x28
    addi x2, x2, -8
    sw x1, 0x0(x2)
    sw x13, 0x4(x2)
    jal x1, swap
    
    # Reload stack variables
    lw x13, 0x4(x2)
    lw x1, 0x0(x2)
    addi x2, x2, 8

    # See swap changed head pointer
    lw x28, 0x0(x13) 
    beqz x28, gnomeSortHead # If current's previous pointer is 0, head updated

    j gnomeSortWhile

gnomeSortHead:
    mv x14, x13
    j gnomeSortWhile

gnomeSortAdvance:
    lw x13, 0x8(x13)
    j gnomeSortWhile

gnomeSortEnd:
    mv x12, x14
    jr x1

# Delete Dupes function (x12 is head)
deleteDupes:
    mv x13, x12 # Position pointer
    mv x29, x0 # Set previous first byte to 0


    # While position pointer is valid
        # If there exists a next pointer
            # If current first byte and next first byte are equal OR if current first byte and previous first byte are equal
                # Delete current node
            # Previous first byte = current first byte 
            # Traverse list
        # If this is the last node in the list
            # If current first byte and previous first byte are equal
                # Delete current node
            # End

    # While position pointer is valid
        # If current FB == previous FB or current FB == next FB
            # Delete current node
        # previous FB = current FB
        # traverse list

deleteDupesWhile:
    beqz x13, deleteDupesEnd # If position pointer is 0, end

    lw x30, 0x4(x13) # Get current value
    srli x30, x30, 8 # Get byte

    beq x30, x29, deleteDupesDelete # If current byte == prev byte, delete

    lw x28, 0x8(x13) # Get next pointer
    lw x28, 0x4(x28) # Get next value
    srli x28, x28, 8 # Get next first byte

    beq x30, x28, deleteDupesDelete # If current byte == next byte, delete

deleteDupesPostDelete:
    mv x29, x30 # Set prev byte to current byte
    lw x13, 0x8(x13) # Traverse list
    j deleteDupesWhile

deleteDupesDelete:    
    addi x2, x2, -12
    sw x13, 0x0(x2)
    sw x29, 0x4(x2)
    sw x1, 0x8(x2)

    mv x10, x13 # Move current pointer into function argument
    jal x1, delete # Delete

    lw x1, 0x8(x2)
    lw x29, 0x4(x2)
    lw x13, 0x0(x2)
    addi x2, x2, 12

    j deleteDupesPostDelete

deleteDupesEnd:
    jr x1


    
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

# Swap function (x10 is address of first element to swap)
swap:
    # Edge case: x10 is null
    beq x10, x0, swap_end

    # x28 is prev, x29 is second element, x30 is next
    lw x28, 0x0(x10)
    lw x29, 0x8(x10)
    # Edge case: 2nd is 0x0 (tail)
    beq x0, x29, swap_end
    lw x30, 0x8(x29)

    # 1st.prev = 2nd
    sw x29, 0x0(x10)
    # 2nd.next = 1st
    sw x10, 0x8(x29)
    # 2nd.prev = prev
    sw x28, 0x0(x29)
    # 1st.next = next
    sw x30, 0x8(x10)
    # Edge case: prev is null
    beq x28, x0, swap_skip_prev
    # prev.next = 2nd
    sw x29, 0x8(x28)
swap_skip_prev:
    # Edge case: next is null
    beq x30, x0, swap_skip_next
    # next.prev = 1st
    sw x10, 0x0(x30)
swap_skip_next:
    bne x10, x11, swap_end

# Edge case: reassign head
swap_head:
    add x11, x29, x0

# Exit function
swap_end:
    jr x1

# Delete function (x10 is address of element to delete)
delete:
    # x28 is prev, x29 is next
    lw x28, 0x0(x10)
    lw x29, 0x8(x10)

    # Edge cases: x10 is head or tail
    beq x28, x0, delete_head
    beq x29, x0, delete_tail

    j delete_normal

delete_head:
    # x30 = next.next
    lw x30, 0x8(x29)
    beq x30, x0, delete_deallocate
    # Update global head to head.next
    add x11, x29, x0
    # Next.prev = null
    sw x0, 0x0(x29)
    j delete_end

delete_tail:
    # x30 = prev.prev
    lw x30, 0x0(x28)
    beq x30, x0, delete_deallocate
    # prev.next = null
    sw x0, 0x8(x28)
    j delete_end

delete_normal:
    # prev.next = next
    sw x29, 0x8(x28)
    # next.prev = prev
    sw x28, 0x0(x29)
    j delete_end

delete_deallocate:
    # Clear head pointer
    add x11, x0, x0

delete_end:
    jr x1

.data

# From HW02 Problem 2 statement
.org 0x3000
num_elements:
    .word 0x8
array_data:
    .word 0x596F, 0x7520, 0x6172, 0x6520, 0x6120, 0x626F, 0x6C64, 0x2031

