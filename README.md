# Building A Web Server in Assembly

*** NEEDS REFINING, NOT PERFECT YET *** 

I'm trying to build a web server completely written in Assembly shellcode.<br>
This project is not entirely done. The final code in x64 Assembly is supposed to be a multi-processed program that can communicate and respond with multiple HTTP GET and POST requests accordingly. Well that was the goal though.
I'm writing the code in levels just like in the modules of [pwn.college](https://pwn.college) so as to get a step by step process that makes it easier to achieve and actually make it feasible.

It consists of 11 levels. All the levels together finally build up to creating a web server in shellcode.

Currently, I finished the code to deal with multiple HTTP GET requests. The POST requests part is still pending, which I plan on doing later.

## Level 1
The shellcode exits a program.

## Level 2
The shellcode creates a socket.

## Level 3
The shellcode binds the socket to an address.

## Level 4
The shellcode listens to a connection on the socket.

## Level 5
The shellcode accepts a connection.

## Level 6
The shellcode statically responds to an HTTP request.

## Level 7
The shellcode dynamically responds to an HTTP GET request based on the requested file to be read.

## Level 8
The shellcode dynamically responds to multiple HTTP GET requests.

## Level 9
The shellcode is a multi-processed program that dynamically responds to multiple HTTP GET requests.


------
------
The syscalls used in the code have been with reference to a [Syscall Index](https://x64.syscall.sh/) available free online.
