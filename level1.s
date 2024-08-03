.intel_syntax noprefix
.global _start

.section .text

_start:
    mov rdi, 0x0
    mov rax, 0x3c # 0x3c or 60 is the syscall value for exit()
    syscall

.section .data
