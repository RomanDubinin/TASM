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

start: 
	mov ax, dseg
	mov ds, ax
	mov si, 0
	mov cx, masSize
	
	push 1
	mov bp, sp

cycle:
	cmp mas[si], -5
	jl section1
	cmp mas[si], 3
	jl section2
	jmp section3
	
	section1:
		mov dword ptr [bp], -2
		fild dword ptr [bp]
		fild mas[si]
		
		fmul st(1), st(0)
		fstp dword ptr [bp]
		
		mov dword ptr [bp], -14
		fild dword ptr [bp]
		fadd st(1), st(0)
		fstp dword ptr [bp]
		
		jmp endIteration
	section2:
		mov dword ptr [bp], 3
		fild dword ptr [bp]
		mov dword ptr [bp], 4
		fild dword ptr [bp]
		fdiv st(1), st(0); 3/4
		fstp dword ptr [bp]
		
		fild mas[si]
		fmul st(1), st(0)
		fstp dword ptr [bp]
		;x coef
		
		mov dword ptr [bp], -1
		fild dword ptr [bp]
		mov dword ptr [bp], 4
		fild dword ptr [bp]
		fdiv st(1), st(0); 1/4
		fstp dword ptr [bp]
		
		fadd st(1), st(0)
		fstp dword ptr [bp]
		
		jmp endIteration
		
	section3:
		mov dword ptr [bp], 14
		fild dword ptr [bp]
		fild mas[si]
		
		fmul st(1), st(0)
		fstp dword ptr [bp]
		
		mov dword ptr [bp], -40
		fild dword ptr [bp]
		fadd st(1), st(0)
		fstp dword ptr [bp]
		
		jmp endIteration
		
	endIteration:
		fstp dword ptr [bp]
		add si, 2
		dec cx
		jcxz endprog
		jmp cycle
	
endprog:
	mov ah,04Ch
	int 21h
cseg ends
end start