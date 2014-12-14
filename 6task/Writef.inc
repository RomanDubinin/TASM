Writef proc
	pusha
	mov bp, sp
	
    mov ah, 3ch
    mov dx, [bp+18]
	mov cx, 0
    int 21h
	mov hFile, ax
    
    mov ah, 40h ;write
    mov bx, hFile
    mov dx, [bp+20]
	mov di, dx
	add di, -2
	mov cx, [di]
    int 21h
	
   
    mov ah, 3eh ; close
    mov bx, hFile
    int 21h
	
	popa
	ret
Writef endp	