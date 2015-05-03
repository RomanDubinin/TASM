keysBuf	dw	5 dup (2)
keysBufSize dw $ - offset keysBuf
keysHead dw offset keysBuf
keysTail dw offset keysBuf

KeysBufIsEmpty proc
	pusha
	mov ax, keysHead
	mov dx, keysTail
	cmp ax, dx
	popa
	ret
KeysBufIsEmpty endp

KeysBufClosedInc proc ; di
	push ax
	push bx
	add di, 2
	mov ax, di
	mov bx, offset keysBuf
	add bx, keysBufSize
	cmp ax, bx
	jne @keysEndInc
	
	mov di, offset keysBuf
	
	@keysEndInc:
	
	pop bx
	pop ax
	ret
KeysBufClosedInc endp

KeysBufInsert proc ; ax - val
	pusha
	
	mov di, cs:[keysHead] ; address 
	mov cs:[di], ax
	
	call KeysBufClosedInc
	mov keysHead, di
	call KeysBufIsEmpty
	je @keysDataMiss
	popa 
	ret
	
	@keysDataMiss:
	mov ah, 02h
	mov dx, 'm'
	int 21h
	
	mov di, cs:[keysTail]
	call KeysBufClosedInc
	mov keysTail, di
	
	popa
	ret
KeysBufInsert endp
	
KeysBufErase proc
	push di
	
	call KeysBufIsEmpty
	je @endKeysErase
	
	mov di, cs:[keysTail]
	mov ax, cs:[di]
	
	call KeysBufClosedInc
	mov keysTail, di
	
	@endKeysErase:
	
	pop di
	ret
KeysBufErase endp