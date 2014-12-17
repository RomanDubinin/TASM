Fact proc

	push bx
	push ax
	push bp

	mov bp, sp
	mov ax, [bp+10]; n
	mov bx, [bp+8]; addr

	dec ax
	push ax
	push bx
	inc ax
	
	cmp ax, 1
	jz return; recurtion base

	call Fact
	mul [bx]

	return:
		mov [bx], ax
		pop bx
		pop ax
		pop bp
		pop ax
		pop bx
		ret

Fact endp