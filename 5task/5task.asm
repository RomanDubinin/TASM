dseg segment
	mas dw 1, 2, 4, 5, 8, 12, 1, 4, 55
	masSize dw 9
dseg ends

sseg segment stack
	n dw 256 dup (?)
sseg ends

cseg segment

	assume ds: dseg, cs: cseg, ss: sseg
include Func.inc
start: 
	mov ax, dseg
	mov ds, ax
	mov si, 0
	mov cx, masSize

cycle:
	jcxz endprog
	push mas[si]
	
	add si, 2
	dec cx
	
	call Func
	
	jmp cycle
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start