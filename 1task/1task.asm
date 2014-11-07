dseg segment
	; определение данных
	mas dw 0, -20, 13, 14, -88
	masSize dw 5
	mes db ', $'
dseg ends

sseg segment stack
	n dw 256 dup (?)
sseg ends

cseg segment
	
	assume ds: dseg, cs: cseg, ss: sseg
	include OutInt.inc
start: 
	mov ax, dseg
	mov ds, ax
	mov si, 0
	mov cx, masSize
cycle:
	dec cx
	mov ax, mas[si]
	add si, 2
	call OutInt
	mov dx, offset mes
	mov ah,09h
	int 21h
	jcxz endprog
	jmp cycle
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start