.global _main
.align 4

_main:
    mov X0, 1                  // File descriptor 1 (stdout)
    adr X1, msg                // Address of the message
    mov X2, 13                 // Length of the message
    mov X16, 4                 // Syscall number for write
    svc 0                      // Make the syscall

    mov X0, 0                  // Exit status 0
    mov X16, 1                 // Syscall number for exit
    svc 0                      // Make the syscall

msg:
    .ascii "Hello World!\n"

