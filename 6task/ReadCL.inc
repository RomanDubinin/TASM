ReadCL proc
	pusha
	mov bp, sp
	
	mov dx, [bp+18]
	add dx, -2 ; max size
	mov  ah, 0Ah
	int 21h

	mov di, [bp+18]
	add di, -1 ; real size
	movzx ax, byte ptr [di]
	add di, ax
	add di, 1
	mov byte ptr [di], 0

	popa
	ret
ReadCL endp