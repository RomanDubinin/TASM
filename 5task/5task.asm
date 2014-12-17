.386
dseg segment use16
	mas dw -10, -6, -5, 0, 3, 10
	masSize dw 6
dseg ends

sseg segment stack  use16
	n dw 256 dup (?)
sseg ends

cseg segment  use16

	assume ds: dseg, cs: cseg, ss: sseg
	include Func.inc
start: 
	mov ax, dseg
	mov ds, ax
	mov si, 0
	mov cx, masSize
	
	push 1
	mov bp, sp

cycle:
	jcxz endprog
	
	push mas[si]
	call Func
		
	add si, 2
	dec cx
	
	jmp cycle
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start