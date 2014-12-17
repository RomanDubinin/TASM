Func proc
	
	push ax
	push cx
	push bp
	push 1
	mov bp, sp
	
	mov ax, [bp+10]
	;________________________________________________________________________
	
	cmp word ptr [bp+10], -5
	jl section1
	cmp word ptr [bp+10], 3
	jl section2
	jmp section3
	
	section1:
		mov word ptr [bp], -2
		fild word ptr [bp]
		fild word ptr [bp+10]
		
		fmul st(1), st(0)
		fstp dword ptr [bp]
		
		mov word ptr [bp], -14
		fild word ptr [bp]
		fadd st(1), st(0)
		fstp dword ptr [bp]
		
		jmp endF
	section2:
		mov word ptr [bp], 3
		fild word ptr [bp]
		mov word ptr [bp], 4
		fild word ptr [bp]
		fdiv st(1), st(0); 3/4
		fstp dword ptr [bp]
		
		fild word ptr [bp+10]
		fmul st(1), st(0)
		fstp dword ptr [bp]
		;x coef
		
		mov word ptr [bp], -1
		fild word ptr [bp]
		mov word ptr [bp], 4
		fild word ptr [bp]
		fdiv st(1), st(0); 1/4
		fstp dword ptr [bp]
		
		fadd st(1), st(0)
		fstp dword ptr [bp]
		
		jmp endF
		
	section3:
		mov word ptr [bp], 14
		fild word ptr [bp]
		fild word ptr [bp+10]
		
		fmul st(1), st(0)
		fstp dword ptr [bp]
		
		mov word ptr [bp], -40
		fild word ptr [bp]
		fadd st(1), st(0)
		fstp dword ptr [bp]
	
		jmp endF
		
	endF:
		fstp dword ptr [bp]

		pop bp
		pop bp
		pop cx
		pop ax
		ret

Func endp