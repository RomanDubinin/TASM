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
    mov dx, [bp+22]
	mov cx, [bp+20]
    int 21h
	
   
    mov ah, 3eh ; close
    mov bx, hFile
    int 21h
	
	popa
	ret
Writef endp	