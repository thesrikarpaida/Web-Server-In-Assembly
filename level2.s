.intel_syntax noprefix
.global _start

.section .text

_start:
    mov rdi, 0x2 # AF_INET - Internet IP Protocol
    mov rsi, 0x1 # SOCK_STREAM - stream (connection) socket
    xor rdx, rdx # NULL
    mov rax, 0x29 # 0x29 or 41 is the syscall value for socket()
    syscall
    mov rax, 0x3c # 0x3c or 60 is the syscall value for exit()
    xor rdi, rdi
    syscall

.section .data
