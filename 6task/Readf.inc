Readf proc
	pusha
	mov bp, sp
	
	mov ah, 3dh
	mov al, 0 ; read
	mov dx, [bp+20]
	int 21h    
	mov bx, ax; hendler
	
	mov ah, 3fh ; read
	mov cx, 64   ; size
	mov dx, [bp+18]
	int 21h
	add dx, -2 ;real size
	mov di, dx
	mov [di], ax

	mov ah, 3eh ; close file
	int 21h
	
	popa
	ret
Readf endp