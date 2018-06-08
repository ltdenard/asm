; assemble: nasm -f elf64 -o cat.o cat.asm
; link:     ld cat.o -o cat
; run:          ./cat
; output is:    <whatever is in the file>

; define system calls for readability
%define SYS_EXIT 60
%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define STDOUT 1
%define BUFFER_SIZE 2048

section .text

global  _start

_start:
  ; Get the first argument
  ; On entry to _start, argc is in (%rsp)
  ; argv[0] in 8(%rsp),
  ; argv[1] in 16(%rsp)
  ;|  2 | [ebp + 16] (3rd function argument)
  ;|  5 | [ebp + 12] (2nd argument)
  ;| 10 | [ebp + 8]  (1st argument)
  ;| RA | [ebp + 4]  (return address)
  ;| FP | [ebp]      (old ebp value)
  add rsp, byte 10h ; add 10 hex to move the pointer to the file descriptor
  pop rdi ; clear stack

  ; Open the file
  mov rax, SYS_OPEN ; setup rax to open a file
  mov rsi, 0 ; 
  syscall
  mov [fd], rax


_read_write:
  ; Read the file in a buffer
  mov rax, SYS_READ
  mov rdi, [fd]
  mov rsi, file_buffer
  mov rdx, BUFFER_SIZE
  syscall

  ; If we reach the end of the file, we leave
  cmp rax, 0
  je _exit

  ; Displays the contents of the buffer
  mov rdx, rax
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, file_buffer
  syscall

  jp _read_write


_exit:
  ; Closes the file
  mov rax, SYS_CLOSE
  mov rdi, fd
  syscall

  ; Adds a line break
  mov [file_buffer], dword 10
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, file_buffer
  mov rdx, 1
  syscall

  ; Quit
  mov rax, 60
  mov rdi, 0
  syscall


section .data

  fd dw 0 ; define word with 2 bytes and set it to 0

section .bss

  file_buffer resb BUFFER_SIZE ; defines file read buffer size