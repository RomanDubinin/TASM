.386
dseg segment use16
	maxKeyLen  db 128
	keyLen db 0
	key db 16 dup('?')
	
	hFile dw ?
	;fin db 33 dup(0)
	fin db "in.txt", 0h
	fout db "out.txt", 0h
	
	bufLen dw ?
	buf db 65 dup(0)
dseg ends

sseg segment stack  use16
	n dw 256 dup (?)
sseg ends

cseg segment  use16

assume ds: dseg, cs: cseg, ss: sseg
include Readf.inc
include Writef.inc
include ReadCL.inc

start: 
	mov ax, dseg
	mov ds, ax
	
	push offset key
	call ReadCL
	
	;push offset fin
	;push offset buf
    ;call Readf
	;pop ax
	;pop ax
	
	mov di, offset key
	add di, -1
	movzx dx, byte ptr [di]
	
	push offset key
	push dx ; buf size
	push offset fout
	call Writef
	
    
	
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start