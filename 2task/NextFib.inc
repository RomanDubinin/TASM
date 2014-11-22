NextFib proc
	
	push ax
	push cx
	push bp
    mov bp, sp
	
	mov ax, [bp+8]
	add ax, [bp+10]
	mov cx, [bp+8]
	mov [bp+10], cx
	mov [bp+8], ax
	
	pop bp
	pop cx
	pop ax
	ret

NextFib endp