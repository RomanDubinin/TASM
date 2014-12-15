Writef proc
	pusha
	mov bp, sp
	
	mov ah, 3ch ; descriptor
	mov dx, [bp+18]
	mov cx, 0
	int 21h
	mov bx, ax ; descriptor
	
	mov ah, 40h ;write
	mov dx, [bp+26]
	mov cx, [bp+24]
	int 21h
	
	mov ah, 40h ;write
	mov dx, [bp+22]
	mov cx, [bp+20]
	int 21h
	

	mov ah, 3eh ; close
	int 21h
	
	popa
	ret
Writef endp	