.global _main
.align 4

.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_EXIT, 1
.equ FD_STDIN, 0
.equ FD_STDOUT, 1

.text
_main:
    // Print prompt for first number
    adrp X1, prompt1@page
    add X1, X1, prompt1@pageoff
    mov X2, prompt1_len
    bl print

    // Read first number from StdIn
    adrp    X1, number1@page        // Load the page address of the first number
    add X1, X1, number1@pageoff     // Store the address to x1
    mov X19, X1                     // Store the address in temp register as it'll be used later
    mov X2, 20                      // Set up the length of the number
    bl read_input

    // Convert first number to integer
    mov X1, X19                     // Use the address stored in temp register
    bl atoi
    mov X19, X0                     // Store the integer result in X19

    // Print prompt for second number
    adrp X1, prompt2@page
    add X1, X1, prompt2@pageoff
    mov X2, prompt2_len
    bl print

    // Read second number from StdIn
    adrp    X1, number2@page        // Load the page address of the second number
    add X1, X1, number2@pageoff     // Store the address to x1
    mov X20, X1                     // Store the address in temp register as it'll be used later
    mov X2, 20                      // Set up the length of the number
    bl read_input

    // Convert second number to integer
    mov X1, X20                     // Use the address stored in temp register
    bl atoi
    mov X20, X0                     // Store the integer result in X20

    // Convert the sum to string
    adrp    X1, result@page
    add X1, X1, result@pageoff
    add X0, X19, X20
    mov X19, X1
    bl itoa

    // Print the result
    mov X1, X19
    mov X2, 20
    bl print
    adrp X1, newline@page
    add X1, X1, newline@pageoff
    mov X2, 1
    bl print

    // Exit the program
    mov X0, 0                   // Return 0
    mov X16, 1                  // System call to terminate this program
    svc 0                       // Call kernel to perform the action


// Subroutine: ASCII to Integer Conversion
// Input: X1 = address of null-terminated ASCII string
// Output: X0 = integer value
atoi:
    mov X0, 0            // Initialize result to 0
    mov X2, 10           // Base (10)
atoi_loop:
    ldrb W3, [X1], #1    // Load byte and increment pointer
    cmp W3, #'0'         // Check if character is a digit
    blt atoi_end         // Exit loop if less than '0'
    cmp W3, #'9'         // Check if character is a digit
    bgt atoi_end         // Exit loop if greater than '9'
    sub W3, W3, #'0'     // Convert ASCII to numeric digit
    mul X0, X0, X2       // Multiply current result by 10
    add X0, X0, X3       // Add digit to result
    b atoi_loop
atoi_end:
    ret

// Subroutine: Integer to ASCII Conversion
// Input: X0 = integer value, X1 = buffer address
// Output: null-terminated ASCII string in buffer
itoa:
    add X2, X1, 20      // Set pointer to the end of the buffer
    mov W3, 0           // Null-terminator ASCII value
    strb W3, [X2], -1   // Place null terminator at the end and move pointer backward
    mov X3, 10           // Base (10)
itoa_loop:
    udiv X4, X0, X3      // Divide X0 by 10 (integer division)
    msub X5, X4, X3, X0  // Remainder = X0 - (X4 * X3)
    add X5, X5, #'0'     // Convert remainder to ASCII
    strb W5, [X2], -1   // Store ASCII character and move pointer backward
    mov X0, X4           // Update X0 to the quotient
    cbz X0, itoa_done    // If X0 is 0, we’re done
    b itoa_loop
itoa_done:
    add X1, X2, 1       // Move X1 to the start of the result
    ret

print:
  mov X16, SYS_WRITE
  mov X0, FD_STDOUT
  svc 0
  ret

read_input:
  mov X16, SYS_READ
  mov X0, FD_STDIN
  svc 0
  ret

.data
prompt1:
  .ascii "Enter first number:\n"
prompt1_len = . - prompt1

prompt2:
  .ascii "Enter second number:\n"
prompt2_len = . - prompt2

newline:
  .ascii "\n"

.bss
result:
  .space 20

number1:
  .space 20

number2:
  .space 20
