dseg segment
	mas dw 1, 2, 4, 5, 8, 12, 1, 4, 55
	masSize dw 9
	mes db ', $'
dseg ends

sseg segment stack
	n dw 256 dup (?)
sseg ends

cseg segment

	assume ds: dseg, cs: cseg, ss: sseg
include IsFib.inc
include OutInt.inc
start: 
	mov ax, dseg
	mov ds, ax
	mov si, 0
	mov cx, masSize
    
cycle1:
	jcxz endprog
	push mas[si]
	
	add si, 2
	dec cx
	
	call IsFib
	jz cycle1
	
	call OutInt

cycle2:
	jcxz endprog
	push mas[si]
	
	add si, 2
	dec cx
	
	call IsFib
	jz cycle2
	
	
	mov dx, offset mes
	mov ah,09h
	int 21h
	call OutInt
	
	jmp cycle2
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start