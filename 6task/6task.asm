.386
dseg segment use16
	maxKey1Len  db 128
	key1Len db 0
	key1 db 16 dup('?')
	
	maxKey2Len  db 128
	key2Len db 0
	key2 db 16 dup('?')
	
	;fin db 33 dup(0)
	fin db "in.txt", 0h
	fout db "out.txt", 0h
	
	buf1Len dw ?
	buf1 db 65 dup(0)
	
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
	
	push offset key1 ; write input file name, plz
	call ReadCL
	
	push offset key1
	push offset buf1
	call Readf
	pop ax
	pop ax
	
	push offset key1 ; write output file, plz
	call ReadCL
	
	push offset key2 ; write your str, plz
	call ReadCL
	
	mov di, offset key2Len
	movzx dx, byte ptr [di]
	
	push offset key2
	push dx ; str size
	
	mov dx, buf1Len
	
	push offset buf1
	push dx; file len
	
	push offset key1
	call Writef
	

	
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start