include NextFib.inc
IsFib proc
	
	push ax
	push bp
	push 1
	push 1
	mov bp, sp
	mov ax, [bp+10]
	
	
	next:
		cmp ax, [bp]
		je yes
		js no
		call NextFib
		jns next
		
		
	yes:
		test ax, ax
		jmp return
		
	no:
		test ax, 0
		jmp return
	
	return:
		pop ax
		pop ax
		pop bx
		pop ax
		ret
	
IsFib endp