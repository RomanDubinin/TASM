victim proc
	mov ah, 9h
	lea dx, testMes
	int 21h
	
	mov ah, 2h
	mov dl, 0Ah
	int 21h
	
	ret
victim endp