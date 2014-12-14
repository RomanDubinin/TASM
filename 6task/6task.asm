.386
dseg segment use16
	max_key  db 128
	key_len db 0
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

readkey proc
	pusha

	lea  dx, key-2
	mov  ah, 0Ah
	int  21h

	lea di, key
	movzx ax, BYTE PTR [key_len]
	add di, ax
	mov BYTE PTR [di], '$'

	popa
	ret
readkey endp	

start: 
	mov ax, dseg
	mov ds, ax
	
	push offset fin
	push offset buf
    call Readf
	pop ax
	pop ax
	
	push offset buf
	push offset fout
	call Writef
	
    
	
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start