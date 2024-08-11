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

.request_loop:
    mov rdi, r15 # socket file descriptor
    xor rsi, rsi # NULL
    xor rdx, rdx # NULL
    mov rax, 0x2b # 0x2b or 43 is the syscall value for accept()
    syscall # accept(sockfd, NULL, NULL)
    mov r14, rax # file descriptor for accepted connection is stored in a register for later use

    # We will fork the process since we need multiple handlers that deal with multiple requests
    mov rax, 0x39 # 0x39 or 57 is the syscall value for fork()
    syscall # fork()
    # the result of running fork() leads to 2 outputs: 0 for child process and >0 for parent process
    cmp rax, 0x0
    je .child_process

    mov rdi, r14 # we close the connection in the parent process for every program run
    mov rax, 0x3 # syscall value for close()
    syscall # close(conn)
    jmp .request_loop # jump to the request loop to accept a new connection

.child_process:
    mov rdi, r15 # socket descriptor
    mov rax, 0x3 # syscall value for close()
    syscall # close(sockfd)
    
    mov rdi, r14 # we read from the accepted connection, so we use that file descriptor
    sub rsp, 0x400 # setting up the stack as the buffer variable
    mov rsi, rsp
    mov rdx, 0x400 # upto how many bytes can be read
    xor rax, rax # 0 is the syscall value for read()
    syscall # read(conn, *buf, 1024)

    lea rdi, [rsi+4] # rsi has the address of the stack, where the response started.
    # rsi+4 is where we skip "GET " in the response, where the file name starts.
    # the file name should end with a NULL terminator, so we loop through till we find a space " ", and add a NULL at that location in rdi
    xor rax, rax # using rax as a counter
    # mov rdx, 0x400
.file_name_loop:
    cmpb [rdi+rax], 0x20 # 0x20 is the hex value for " " (space)
    je .end_file_name_loop
    inc rax
    loop .file_name_loop
.end_file_name_loop:
    movb [rdi+rax], 0x0 # we add the NULL terminator where we find a space
    xor rsi, rsi # 0
    # xor rdx, rdx # 0
    mov rax, 0x2 # 0x2 or 2 is the syscall value for open()
    syscall # open(file_name, O_RDONLY)

    mov rdi, rax # we read from the file descriptor that is opened
    sub rsp, 0x1000 # clearing 4096 bytes on the stack buffer, which is how much we allow to read from the file.
    mov rsi, rsp # we read on to the stack
    mov rdx, 0x1000 # we give a buffer to read up to 4096 bytes
    xor rax, rax # syscall value for read()
    syscall # read(file_fd, *stack, 4096)
    mov r13, rax # we will save the number of bytes read to the r13 register

    # rdi already has the file descriptor, since we're closing it immediately after reading from the file.
    mov rax, 0x3 # 0x3 or 3 is the syscall value for close()
    syscall # close(file_fd)

    # Response string: "HTTP/1.0 200 OK\r\n\r\n" followed by NULL terminator "\0"
    # 0x48 0x54 0x54 0x50 | 0x2f 0x31 0x2e 0x30 0x20 0x32 0x30 0x30 | 0x20 0x4f 0x4b 0x0d 0x0a 0x0d 0x0a 0x00
    mov rdi, r14 # we write to the accepted connection, so we use that file descriptor
    mov rax, 0x000a0d0a0d4b4f20
    push rax
    mov rax, 0x30303220302e312f
    push rax
    mov eax, 0x50545448
    mov [rsp-4], eax
    sub rsp, 4
    lea rsi, [rsp] # pushed the response string on to the stack and set the address of the stack for the response parameter
    mov rdx, 0x13 # the response string is 19 (0x13) bytes
    mov rax, 0x1 # 0x1 or 1 is the syscall value for write()
    syscall # write(conn, "HTTP/1.0 200 OK\r\n\r\n", 19)

    mov rdi, r14 # we write to the accepted connection, so we use that file descriptor
    lea rsi, [rsp+0x14] # the size of response written is 0x13 bytes, and the extra 1 byte is the ending NULL byte we added into the response
    # the response was on the stack after the file contents were added on to it. We just got the address from where the file contents started, so we skip writing the response part
    mov rdx, r13 # number of bytes read from the file
    mov rax, 0x1 # syscall value for write()
    syscall # write(conn, file_content, file_content_size)

    xor rdi, rdi # 0
    mov rax, 0x3c # 0x3c or 60 is the syscall value for exit()
    syscall # exit(0)

.section .data
