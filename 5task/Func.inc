Func proc
	
	push ax
	push cx
	push bp
    mov bp, sp
	
	mov ax, [bp+8]
	push 4
	pop cx
	fild cx
	
	pop bp
	pop cx
	pop ax
	ret

Func endp