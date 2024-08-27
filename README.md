# Building A Web Server

This repository is based on a module in the dojo [Intro to Cybersecurity](https://pwn.college/intro-to-cybersecurity/) in [pwn.college](pwn.college). I'm trying to build a web server completely written in Assembly shellcode.<br>
This project is still a work in progress. The final code in x64 Assembly will be a multi-processed program that can communicate and respond with multiple HTTP GET and POST requests accordingly.
I'm writing the code in levels just like in the module so as to get through it easily.

It consists of 11 levels. All the levels together finally build up to creating a web server in shellcode.

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
