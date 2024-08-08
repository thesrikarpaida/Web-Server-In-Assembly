.intel_syntax noprefix
.global _start

.section .text

_start:
    mov rdi, 0x2 # AF_INET - Internet IP Protocol
    mov rsi, 0x1 # SOCK_STREAM - stream (connection) socket
    xor rdx, rdx # 0
    mov rax, 0x29 # 0x29 or 41 is the syscall value for socket()
    syscall # socket(AF_INET, SOCK_STREAM, 0)
    mov r15, rax # storing the socket file descriptor in a separate register for later use.

    # struct sockaddr_in {
    #        sa_family_t     sin_family;     /* AF_INET */
    #        in_port_t       sin_port;       /* Port 80 */
    #        struct in_addr  sin_addr;       /* IPv4 address - 0.0.0.0 */
    #    };

    mov rdi, r15 # socket file descriptor to rdi, the first parameter of bind()
    xor rax, rax
    push rax
    mov rbx, 0x0 # equivalent to 0.0.0.0
    push rbx
    movw [rsp-2], 0x5000 # Little endian for 0x0050, or 80
    movw [rsp-4], 0x2 # AF_INET = 0x2
    sub rsp, 4
    lea rsi, [rsp]
    mov rdx, 0x10 # address length
    mov rax, 0x31 # 0x31 or 49 is the syscall value for bind()
    syscall # bind(sockfd, (struct sockaddr*)&sockaddr_in, 16)

    mov rdi, r15 # socket file descriptor
    xor rsi, rsi # 0
    mov rax, 0x32 # 0x32 or 50 is the syscall value for listen()
    syscall # listen(sockfd, 0)

    mov rdi, r15 # socket file descriptor
    xor rsi, rsi # NULL
    xor rdx, rdx # NULL
    mov rax, 0x2b # 0x2b or 43 is the syscall value for accept()
    syscall # accept(sockfd, NULL, NULL)
    mov r14, rax # file descriptor for accepted connection is stored in a register for later use

    mov rdi, r14 # we read from the accepted connection, so we use that file descriptor
    sub rsp, 0x400 # setting up the stack as the buffer variable
    mov rsi, rsp
    mov rdx, 0x400 # providing an appropriate size
    xor rax, rax # 0x0 or 0 is the syscall value for read()
    syscall # read(conn, *buf, 1024)

    # Response string: "HTTP/1.0 200 OK\r\n\r\n"
    # 0x48 0x54 0x54 0x50 | 0x2f 0x31 0x2e 0x30 0x20 0x32 0x30 0x30 | 0x20 0x4f 0x4b 0x0d 0x0a 0x0d 0x0a 0x00
    # rdi already has required file descriptor, so we won't be changing that
    mov rax, 0x000a0d0a0d4b4f20
    push rax
    mov rax, 0x30303220302e312f
    push rax
    mov eax, 0x50545448
    mov [rsp-4], eax
    sub rsp, 4
    lea rsi, [rsp]
    mov rdx, 0x13
    mov rax, 0x1 # write()
    syscall

    # rdi already has required file descriptor, so we won't be changing that
    mov rax, 0x3 # close()
    syscall # close(sockfd)

    xor rdi, rdi # 0
    mov rax, 0x3c # 0x3c or 60 is the syscall value for exit()
    syscall # exit(0)

.section .data
