snakeBuf dw 8960 dup (2)
snakeBufSize dw $ - offset snakeBuf
snakeHead dw offset snakeBuf
snakeTail dw offset snakeBuf


snakeBufIsEmpty proc
	pusha
	mov ax, snakeHead
	mov dx, snakeTail
	cmp ax, dx
	popa
	ret
snakeBufIsEmpty endp

SnakeBufClosedInc proc ; di
	push ax
	push bx
	add di, 2
	mov ax, di
	mov bx, offset snakeBuf
	add bx, snakeBufSize
	cmp ax, bx
	jne @endInc
	
	mov di, offset snakeBuf
	
	@endInc:
	
	pop bx
	pop ax
	ret
SnakeBufClosedInc endp

SnakeBufInsert proc ; ax - val
	pusha
	
	mov di, cs:[snakeHead] ; address 
	mov cs:[di], ax
	
	call SnakeBufClosedInc
	mov snakeHead, di
	call snakeBufIsEmpty
	je @dataMiss
	popa 
	ret
	
	@dataMiss:
	mov ah, 02h
	mov dx, 'm'
	int 21h
	
	mov di, cs:[snakeTail]
	call SnakeBufClosedInc
	mov snakeTail, di
	
	popa
	ret
SnakeBufInsert endp
	
SnakeBufErase proc
	push di
	
	call snakeBufIsEmpty
	je @endErase
	
	mov di, cs:[snakeTail]
	mov ax, cs:[di]
	
	call SnakeBufClosedInc
	mov snakeTail, di
	
	@endErase:
	
	pop di
	ret
SnakeBufErase endp