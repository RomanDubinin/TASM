
dseg segment
	mas dw -1, -6, -3, 0, 2, 3, 5, 10
	masSize dw 8
dseg ends

sseg segment stack
	n dw 256 dup (?)
sseg ends

cseg segment

	assume ds: dseg, cs: cseg, ss: sseg

start: 
	mov ax, dseg
	mov ds, ax
	mov si, 0
	mov cx, masSize

cycle:
	jcxz endprog

	cmp mas[si], -5
	jl section1
	cmp mas[si], 3
	jl section2
	jmp section3
	
	section1:
		fild mas[si]
		
		jmp endCycle
	section2:
		
		jmp endCycle
		
	section3:
		
		jmp endCycle
		
	endCycle:
		add si, 2
		dec cx
		jmp cycle
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start