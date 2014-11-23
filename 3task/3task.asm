dseg segment
	num dw 5
	res dw 0
	mes db '! == $'
dseg ends

sseg segment stack
	n dw 256 dup (?)
sseg ends

cseg segment
assume ds: dseg, cs: cseg, ss: sseg
include Fact.inc
include OutInt.inc

start: 
	mov ax, dseg
	mov ds, ax

	push num
	push offset res
	call Fact
	
	pop ax
	pop ax
	push res
	call OutInt
	pop res
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start