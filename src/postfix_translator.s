.section .bss
input_buffer: .space 256                    # Allocate 256 bytes for input buffer
mid_buffer: .space 16                      # Allocate 256 bytes for mid buffer
output_buffer: .space 256                   # Allocate 256 bytes for output buffer
input_num: .space 4                         # Allocate 4 bytes for the number

.section .data
operators: .asciz "+-*^&|"                  # String of operators
funct3: .asciz " 000"                       # Funct3
opcode_op: .asciz " 0110011\n"              # Opcode for R-type instructions
opcode_imm: .asciz " 0010011\n"             # Opcode for I-type instructions
funct7_add: .asciz "0000000"                # Funct7 for addition
funct7_sub: .asciz "0100000"                # Funct7 for subtraction
funct7_mul: .asciz "0000001"                # Funct7 for multiplication
funct7_xor: .asciz "0000100"                # Funct7 for logical XOR
funct7_and: .asciz "0000111"                # Funct7 for logical AND
funct7_or: .asciz "0000110"                 # Funct7 for logical OR
register_x0: .asciz " 00000"                # Register x0
register_x1: .asciz " 00001"                # Register x1
register_x2: .asciz " 00010"                # Register x2


.section .text
.global _start

_start:
    # Read input from standard input
    mov $0, %eax                            # syscall number for sys_read
    mov $0, %edi                            # file descriptor 0 (stdin)
    lea input_buffer(%rip), %rsi            # pointer to the input buffer
    mov $256, %edx                          # maximum number of bytes to read
    syscall                                 # perform the syscall

    # Handle the input buffer
    lea input_buffer(%rip), %r15            # pointer to the input buffer

handle_loop:
    movzx (%r15), %r8                   # load the character

    cmp $0, %r8                         # check for null terminator
    jz handle_done                      # if null terminator, we're done

    cmp $10, %r8                        # check for end of line character
    jz handle_done                      # if end of line character, we're done

    cmp $32, %r8                        # check for space character
    jz space_found                      # if space character, we found it

    # Check if the character is an operator
    lea operators(%rip), %r9            # pointer to the operators string
    operator_loop:
        movzx (%r9), %r10               # load the operator
        cmp %r10, %r8                   # check if the character is an operator
        jz operator_found               # if the character is an operator, we found it
        inc %r9                         # move to the next operator
        cmp $0, %r10                    # check for null terminator
        jnz operator_loop               # repeat

    jmp number_found                    # if none of the above, it's a number

operator_found:
    # Handle the operator
    pop %rax                            # pop the second number 
    mov %rax, %r14                      # store the second number for printing
    lea output_buffer(%rip), %r13       # pointer to the output buffer
    call convert_binary                 # convert the number to binary and store it in the output buffer

    lea output_buffer(%rip), %rsi       # pointer to the output buffer
    mov $12, %edx                       # size of the buffer
    call print_func                     # print the second number

    call print_num_constants2            # print the constants for the second number

    pop %rbx                            # pop the first number
    mov %rbx, %r14                      # store the first number for printing
    lea output_buffer(%rip), %r13       # pointer to the output buffer
    call convert_binary                 # convert the number to binary and store it in the output buffer

    lea output_buffer(%rip), %rsi       # pointer to the output buffer
    mov $12, %edx                       # size of the buffer
    call print_func                     # print the first number

    call print_num_constants1            # print the constants for the first number

    inc %r15                            # move to the next character
    inc %r15                            # move to the next character

    cmp $43, %r8                        # check for the + operator
    jz handle_add                       # if the + operator, handle addition

    cmp $45, %r8                        # check for the - operator
    jz handle_sub                       # if the - operator, handle subtraction

    cmp $42, %r8                        # check for the * operator
    jz handle_mul                       # if the * operator, handle multiplication

    cmp $94, %r8                        # check for the ^ operator
    jz handle_xor                       # if the ^ operator, handle bitwise XOR

    cmp $38, %r8                        # check for the & operator
    jz handle_and                       # if the & operator, handle bitwise AND

    cmp $124, %r8                       # check for the | operator
    jz handle_or                        # if the | operator, handle bitwise OR

number_found:
    # Handle the number
    lea input_num(%rip), %r11           # pointer to the input number
    mov %r8, (%r11, %r12, 1)            # store the number character
    inc %r12                            # move to the next number character
    inc %r15                            # move to the next character
    jmp handle_loop                     # repeat

space_found:
    # Handle the space
    call convert_decimal                # call convert_decimal
    pushq %rax                          # push the number to the stack
    movl $0x00, input_num(%rip)         # clear the input num
    inc %r15                            # move to the next character
    mov $0, %r12                        # clear r12
    jmp handle_loop                     # continue handling the next character

handle_done:
    jmp exit_program                    # exit the program

handle_add:
    # Handle addition
    lea funct7_add(%rip), %rsi              # pointer to the second register
    mov $7, %edx                            # size of the buffer
    call print_func                         # print the second register

    call print_op_constants                 # print the constants

    add %rax, %rbx                          # add the numbers
    push %rbx                               # push the result
    jmp handle_loop                         # continue handling the next character

handle_sub:
    # Handle subtraction
    lea funct7_sub(%rip), %rsi              # pointer to the second register
    mov $7, %edx                            # size of the buffer
    call print_func                         # print the second register

    call print_op_constants                 # print the constants

    sub %rax, %rbx                          # subtract the numbers
    push %rbx                               # push the result
    jmp handle_loop                         # continue handling the next character

handle_mul:
    # Handle multiplication
    lea funct7_mul(%rip), %rsi              # pointer to the second register
    mov $7, %edx                            # size of the buffer
    call print_func                         # print the second register

    call print_op_constants                 # print the constants

    imul %rax, %rbx                         # multiply the numbers
    push %rbx                               # push the result
    jmp handle_loop                         # continue handling the next character

handle_xor:
    # Handle bitwise XOR
    lea funct7_xor(%rip), %rsi              # pointer to the second register
    mov $7, %edx                            # size of the buffer
    call print_func                         # print the second register

    call print_op_constants                 # print the constants

    xor %rax, %rbx                          # XOR the numbers
    push %rbx                               # push the result
    jmp handle_loop                         # continue handling the next character

handle_and:
    # Handle bitwise AND
    lea funct7_and(%rip), %rsi              # pointer to the second register
    mov $7, %edx                            # size of the buffer
    call print_func                         # print the second register

    call print_op_constants                 # print the constants

    and %rax, %rbx                          # AND the numbers
    push %rbx                               # push the result
    jmp handle_loop                         # continue handling the next character

handle_or:
    # Handle bitwise OR
    lea funct7_or(%rip), %rsi               # pointer to the second register
    mov $7, %edx                            # size of the buffer
    call print_func                         # print the second register

    call print_op_constants                 # print the constants

    or %rax, %rbx                           # OR the numbers
    push %rbx                               # push the result
    jmp handle_loop                         # continue handling the next character

convert_decimal:
    # Convert the number to a decimal and store it in the %rax register
    mov $0, %rax                            # clear rax
    lea input_num(%rip), %r13               # pointer to the input 
    
    convert_loop:
        movzx (%r13), %r14                  # load the next character
        cmp $0, %r14                        # check for null terminator
        jz convert_done                     # if null terminator, we're done
        sub $48, %r14                       # convert the character to a number
        imul $10, %rax                      # multiply the current number by 10
        add %r14, %rax                      # add the new number
        inc %r13                            # move to the next character
        jmp convert_loop                    # repeat

    convert_done:
        ret                                

convert_binary:
    # Convert the number to binary and store it in the output buffer
    add $11, %r13                           # set the number of bits
    mov $12, %rcx                           # set the counter
    mov $0, %rdx                            # clear rax

    .loop:
        mov %r14, %rdx                      # store the number
        and $1, %rdx                        # get the least significant bit
        add $48, %rdx                       # convert the bit to a character
        movb %dl, (%r13)                    # store the character
        shr $1, %r14                        # shift the number to the right
        dec %r13                            # move to the next character
        dec %rcx                            # decrement the counter
        cmp $0, %rcx                        # check if the number is zero
        jne .loop                           # repeat

    ret

print_func:
    # Assumes edx has size and rsi has address (popped from stack)
    push %rdi
    push %rax

    mov $1, %eax                            # syscall number for sys_write
    mov $1, %edi                            # file descriptor 1 (stdout)
    syscall

    pop %rax
    pop %rdi

    ret

print_num_constants1:
    # Print constant values associated with the number
    push %rdx

    lea register_x0(%rip), %rsi             # pointer to the first register
    mov $6, %edx                            # size of the buffer
    call print_func                         # print the first register

    lea funct3(%rip), %rsi                  # pointer to the funct3
    mov $4, %edx                            # size of the buffer
    call print_func                         # print the funct3

    lea register_x1(%rip), %rsi             # pointer to the second register
    mov $6, %edx                            # size of the buffer
    call print_func                         # print the second register

    lea opcode_imm(%rip), %rsi              # pointer to the opcode
    mov $9, %edx                            # size of the buffer
    call print_func                         # print the opcode

    pop %rdx

    ret

print_num_constants2:
    # Print constant values associated with the number
    push %rdx

    lea register_x0(%rip), %rsi             # pointer to the first register
    mov $6, %edx                            # size of the buffer
    call print_func                         # print the first register

    lea funct3(%rip), %rsi                  # pointer to the funct3
    mov $4, %edx                            # size of the buffer
    call print_func                         # print the funct3

    lea register_x2(%rip), %rsi             # pointer to the second register
    mov $6, %edx                            # size of the buffer
    call print_func                         # print the second register

    lea opcode_imm(%rip), %rsi              # pointer to the opcode
    mov $9, %edx                            # size of the buffer
    call print_func                         # print the opcode

    pop %rdx

    ret

print_op_constants:
    # Print constant values associated with the operation
    push %rdx

    lea register_x2(%rip), %rsi             # pointer to the second register
    mov $6, %edx                            # size of the buffer
    call print_func                         # print the second register

    lea register_x1(%rip), %rsi             # pointer to the first register
    mov $6, %edx                            # size of the buffer
    call print_func                         # print the first register

    lea funct3(%rip), %rsi                  # pointer to the second register
    mov $4, %edx                            # size of the buffer
    call print_func                         # print the second register

    lea register_x1(%rip), %rsi             # pointer to the second register
    mov $6, %edx                            # size of the buffer
    call print_func                         # print the second register

    lea opcode_op(%rip), %rsi               # pointer to the second register
    mov $9, %edx                            # size of the buffer
    call print_func                         # print the second register

    pop %rdx

    ret

exit_program:
    # Exit the program
    mov $60, %eax                           # syscall number for sys_exits
    xor %edi, %edi                          # exit code 0
    syscall

