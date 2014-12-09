victim proc
	mov ah, 9h
    lea dx, test_s
	int 21h
	
	mov ah, 2h
	mov dl, 0Ah
	int 21h
	
	ret
victim endp