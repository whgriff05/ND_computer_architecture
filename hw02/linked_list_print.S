//CSE 30321 Spring 2026
//Linked List Print Code


#pragma qtrvsim show registers
#pragma qtrvsim show memory


.globl _start
.option norelax


//for printing
.equ __NR_write,       64  // ssize_t write(int fd, const void *buf, size_t count)


.text
_start:
    //***linked list "main" goes here for each assignment***

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

    

    //***DUMMY LINKED LIST CODE, DELETE THIS***

//  
//  CODE TO PRINT LIST STARTS HERE
//
    #pragma qtrvsim show terminal


    addi x31, x0, 10        //constant 10
    addi x27, x0, 32        //ascii space


    //REPLACE x8 WITH REG CONTAINING LIST HEAD POINTER
    mv x5, x11              //print code expects head in x5


    //memory space for ASCII text representation of linked list 
    li x18, 0x700
    
    //outer loop iterates num_elements times
    la x29, num_elements
    lw x29, 0x0(x29)
    li x15, 0


    //for traversing the linked list
    mv x6, x5


list_loop:  
    bge x15, x29, print_it  //we are done generating ASCII, go to print it
    li x26, 4               //1 address + 3 fields in each element
    li x14, 4               
field_loop:
    bne x26, x14, field     //first time through, print the address of the element
    mv x19, x6              //copy address into x19
    j not_field
field:
    lw x19, 0x0(x6)         //load the current field of the element
not_field:
    li x30, 3               //will count 4 digits (each a nibble) of field for conversion
nbl_loop:   
    blt x30, x0, next_field //go on to next element if counter < 0
    andi x20, x19, 0xF      //mask the least significant nibble of field
    bge x20, x31, add_hex   //need to compute ASCII for letter ('A' is decimal 55)
    addi x20, x20, 48       //compute ASCII for number ('0' is decimal 48)
    j skip_ah
add_hex:    
    addi x20, x20, 55       //compute ASCII for letter
skip_ah:    
    add x28, x18, x30       //compute address to store ASCII byte (entire word for 1 field)
                            // note we need to do it backwards, e.g., 0x0604 --> '4' '0' '6' '0'
    sb x20, 0x0(x28)        //store the byte
    srli x19, x19, 4        //shift to get the next nibble
    addi x30, x30, -1       //update loop counter
    j nbl_loop


next_field: 
    addi x18, x18, 4        //we just stored 4 characters (4 bytes), advance to next word of ASCII storage
    sb x27, 0x0(x18)        //fill the next word with 4 spaces
    sb x27, 0x1(x18)        //fill the next word with 4 spaces
    sb x27, 0x2(x18)        //fill the next word with 4 spaces
    sb x27, 0x3(x18)        //fill the next word with 4 spaces


    addi x18, x18, 4        //we just stored 4 characters (4 bytes), advance to next word of ASCII storage


    beq x26, x14, skip_fa   //first time through, do not update address
    addi x6, x6, 0x4        //get addr of next field
skip_fa:
    addi x26, x26, -1
    bne x26, x0, field_loop
    addi x6, x6, 0x34       //get addr of next linked list element
    sb x31, 0(x18)          //fill the LSB of the word with a newline
    sb x0, 0x1(x18)         //fill the next byte with null character
    sb x0, 0x2(x18)         //fill the next byte with null character
    sb x0, 0x3(x18)         //fill the next byte with null character
    addi x18, x18, 4        //we just stored a full element, store a newline (10)
    addi x15, x15, 1
    j list_loop
    
    //based on QtRVSim template-os.S
print_it:   
    addi  x17, x0, __NR_write       // load syscall number
    addi  x10, x0, 1                // load file descriptor
    li  x11, 0x700                  // load text address
    addi  x12, x0, 280              // load text length
    ecall                           // print the text
    
    ebreak


//  
//  CODE TO PRINT LIST ENDS HERE
//


//***Linked List functions go here***

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


//***HARD CODED LIST MATCHING HW02 LIST AS AN EXAMPLE ***
//*** DELETE EVERYTHING BELOW THIS LINE, REPLACE WITH YOUR .data***
.data

# From Problem 2 statement
.org 0x3000
num_elements:
    .word 0x8
array_data:
    .word 0x596F, 0x7520, 0x6172, 0x6520, 0x6120, 0x626F, 0x6C64, 0x2031

// Specify location to show in memory window
#pragma qtrvsim focus memory 0x700
