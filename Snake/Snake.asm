.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  
@entry: jmp @start

	include KeyBuf.inc
	include SnakeBuf.inc
	
	oldInt9 dd ?
	oldInt1 dd ?
constant dw 8405h ;multiplier value
seed1 dw ?
seed2 dw ? ;random number seeds
	
randgen proc
	or ax, ax ;range value <> 0?
	jz abort
	push bx
	push cx
	push dx
	push ds
	push ax
	push cs
	pop ds
	mov ax, seed1
	mov bx, seed2 ;load seeds
	mov cx, ax ;save seed
	mul constant
	shl cx, 1
	shl cx, 1
	shl cx, 1
	add ch, cl
	add dx, cx
	add dx, bx
	shl bx, 1 ;begin scramble algorithm
	shl bx, 1
	add dx, bx
	add dh, bl
	mov cl, 5
	shl bx, cl
	add ax, 1
	adc dx, 0
	mov seed1, ax
	mov seed2, dx ;save results as the new seeds
	pop bx ;get back range value
	xor ax, ax
	xchg ax, dx ;adjust ordering
	div bx ;ax = trunc((dx,ax) / bx), dx = (r)
	xchg ax, dx ;return remainder as the random number
	pop ds
	pop dx
	pop cx
	pop bx
	abort: 
	ret ;return to caller
randgen endp
	
printBX proc
	pusha
	mov cx, 4
	@k:
	rol bx, 4 ; bx = 0001000000010000
	mov al, bl ; al = 00010000
	and al, 0fh ; al = 00000000
	cmp al, 10
	sbb al, 69h
	das
	mov dh, 02h
	xchg ax, dx
	int 21h
	loop @k
	popa
	ret
printBX endp
	
OutIntVga proc
	push bp
	mov bp, sp
	
	push ax
	push bx
	push cx
	push dx
	mov ax, [bp+4]
	test    ax, ax
	jns     oi1
	
	
	neg ax
oi1:
	xor cx, cx
	mov bx, 10
oi2:
	xor dx,dx
	div bx
	
	push dx
	inc cx
	
	test ax, ax
	jnz oi2
	
oi3:
	pop ax
	
	add al, '0'
	call put
	
	loop oi3
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret 2
OutIntVga endp
 
put proc
	pusha
	
	mov ah, 0Eh
	mov bh, 0h
	mov bl, fruitColour
	int 10h
	
	popa
	ret
put endp

clear proc
	pusha
	
	mov ah, 02h
	mov bh, 0h
	mov dx, 07h
	int 10h
	
	mov ah, 09h
	mov al, ' '
	mov bx, 0002h
	mov cx, 8
	int 10h
	
	popa
	ret
clear endp

int1c proc
	push ds
	push cs
	pop ds
	
	inc currentTime
	pop ds
	db 0eah
	l1c dw 0, 0
int1c endp

checkColour proc ;dx - row; cx - column - checking block; bl - colour
	pusha
	
	mov ax, dx
	mul sqareSize
	mov dx, ax
	push dx
	
	mov ax, cx
	mul sqareSize
	mov cx, ax
	pop dx
	
	mov bh, 0
	mov ah, 0Dh
	int 10h
	
	cmp al, bl
	popa
	ret
checkColour endp

int9:
	; in - read from port
	; out - write into port
	in al, 60h
	
	call KeysBufInsert
	
	in al, 61h
	or al, 80h ; выставить старший бит 1
	out 61h, al
	and al, 07fh
	out 61h, al
	
	mov al, 20h
	out 20h, al
	iret

	
drawSqare proc ; dx - row; cx - column; bl - colour
	pusha
	
	mov ax, dx
	mul sqareSize
	mov dx, ax
	push dx
	
	mov ax, cx
	mul sqareSize
	mov cx, ax
	pop dx
	
	mov di, dx
	mov si, cx
	add di, sqareSize
	add si, sqareSize
	
	@drawSqareLoop1:
	@drawSqareLoop2:
	mov bh, 0h; page
	mov ah, 0Ch; func
	mov al, bl; colour
	int 10h
	
	inc dx
	cmp dx, di 
	jne @drawSqareLoop2
	sub dx, sqareSize
	inc cx
	cmp cx, si
	jne @drawSqareLoop1
	
	
	popa
	ret
drawSqare endp
	
drawContour proc 
	pusha
	mov bl, redColour
	
	mov dx, startRow
	mov cx, startColumn
	@loo1:
	call drawSqare
	inc dx
	cmp dx, endRow
	jne @loo1
	@loo2:
	call drawSqare
	inc cx
	cmp cx, endColumn
	jne @loo2
	@loo3:
	call drawSqare
	dec dx
	cmp dx, startRow
	jne @loo3
	@loo4:
	call drawSqare
	dec cx
	cmp cx, startColumn
	jne @loo4
	popa
	ret
drawContour endp
	
drawRandomFruit proc
	pusha
	@againRandom:
	mov ax, endRow
	call randgen
	mov dx, ax
	
	mov ax, endColumn
	call randgen
	mov cx, ax
	
	add dx, startRow
	inc dx

	add cx, startColumn
	inc cx

	mov bl, blueColour
	call checkColour
	je @againRandom
	mov bl, fruitColour
	call drawSqare
	popa
	ret
drawRandomFruit endp
	
Resize proc 
	pusha
	xor dx, dx
	mov ax, sizeX
	div sqareSize
	mov endColumn, ax
	cmp dx, 0
	jne @NotXdec
	dec endColumn
	@NotXdec:
	
	xor dx, dx
	mov ax, sizeY
	div sqareSize
	mov endRow, ax
	cmp dx, 0
	jne @NotYdec
	dec endRow
	@NotYdec:
	popa
	ret
Resize endp
	
; скан-коды клавиш
space db 039h
escCode db 81h

@start:
	
	mov ah, 00h
	mov al, 10h
	int 10h
	
	xor dx, dx
	mov ax, 3509h
	int 21h
	mov word ptr oldInt9,   bx
	mov word ptr oldInt9+2, es
	
	cli
	mov ax, 2509h
	mov dx, offset int9
	int 21h
	sti
	
	mov ax, 351ch
	int 21h
	mov l1c, bx
	mov l1c + 2, es
	mov word ptr oldInt1,   bx
	mov word ptr oldInt1+2, es
	
	
	cli
	mov ax, 251ch
	mov dx, offset int1c
	int 21h
	sti
	;/////////////////////////////////
	
	call Resize
	
	mov ah, 09h
	mov dx, offset scopeString
	int 21h
	
	call drawContour
	;/////////////////////////////////////
	
	mov ax, snakePosition; start position
	call SnakeBufInsert
	call SnakeBufInsert
	
	mov dx, ax
	xor dh, dh
	xor cx, cx
	mov cl, ah
	mov bl, blueColour
	call drawSqare
	
	call drawRandomFruit
	
	@GameSycle:
	
	cmp IsPause, 01h
	je @doOnPause
	
	mov ax, snakePosition
	mov dl, snakeDirection
	
	cmp dl, Left
	jne @mayBeRight
	dec ah
	jmp @Move
	
	@mayBeRight:
	cmp dl, Right
	jne @mayBeUp
	inc ah
	jmp @Move
	
	@mayBeUp:
	cmp dl, Up
	jne @mayBeDown
	dec al
	jmp @Move
	
	@mayBeDown:
	cmp dl, Up
	inc al
	
	
	
	@Move:
	
	call SnakeBufInsert
	mov snakePosition, ax
	xor cx, cx
	xor dx,dx
	mov dl, al
	mov cl, ah
	mov bl, blueColour
	call checkColour
	je @gameOver
	
	mov bl, redColour
	call checkColour
	je @gameOver
	
	push cx
	push dx
	mov bl, fruitColour
	call checkColour
	je @eaten
	
	call SnakeBufErase
	
	xor cx, cx
	xor dx,dx
	mov dl, al
	mov cl, ah
	mov bl, 00h; colour
	call drawSqare
	jmp @notEaten
	
	@eaten:
	inc scope
	push scope
	call clear
	call OutIntVga
	call drawRandomFruit
	
	
	@notEaten:
	pop dx
	pop cx
	mov bl, blueColour; colour
	call drawSqare
	
	mov bx, currentTime
	add bx, speedCoef
	
	
	
	@wait:
	
	
	@readFromBuf:
	mov ax, 0
	call KeysBufErase
	cmp al, escCode
	je terminate
	cmp al, space
	je @doPause
	
	;cmp al, 224
	;je @GameSycle	
	
	cmp al, Up
	je @newDirection
	cmp al, Left
	je @newDirection
	cmp al, Down
	je @newDirection
	cmp al, Right
	je @newDirection
	

	mov dx, currentTime
	cmp bx, dx
	ja @wait
	jmp @GameSycle
	
	@newDirection:
	mov bl, al
	sub bl, snakeDirection
	cmp bl, 2h
	je @GameSycle
	cmp bl, 8h
	je @GameSycle
	cmp bl, 2h
	je @GameSycle
	neg bl
	cmp bl, 2h
	je @GameSycle
	cmp bl, 8h
	je @GameSycle
	mov snakeDirection, al
	
	jmp @GameSycle
	
	@doOnPause:
	mov al, 0
	call KeysBufErase
	cmp al, space
	je @doPause
	cmp al, escCode
	je terminate
	jmp @GameSycle
	
	@doPause:
	xor IsPause, 01h
	jmp @GameSycle
	
	@gameOver:
	mov ah, 02h
	mov bh, pageNum
	mov dh, 0Ah
	mov dl, 24h
	int 10h
	
	mov di, 0h
	mov cx, 1h
	@nextChar:
	mov ah, 0Ah
	mov al, gameOverString[di]
	cmp al, 0h
	je @waiAnyKey
	mov bh, pageNum
	int 10h
	inc di
	
	inc dl
	mov ah, 02h
	int 10h
	jmp @nextChar
	
	
	@waiAnyKey:
	xor ax, ax
	call KeysBufErase
	cmp al, escCode
	jne @waiAnyKey
	
	terminate:

	cli
	mov ax, 2509h
	mov dx, word ptr cs:[oldInt9]
	mov ds, word ptr cs:[oldInt9+2]
	int 21h
	
	mov ax, 251ch
	mov dx, word ptr cs:[oldInt1]
	mov ds, word ptr cs:[oldInt1+2]
	int 21h
	
	;video
	mov ah, 00h
	mov al, 3h
	int 10h
	
	ret
	
	pageNum db, 00h
	
	startRow dw 3h
	startColumn dw 0h
	sqareSize dw 7
	
	
	sizeX dw 640
	sizeY dw 350
	
	endRow dw ?
	endColumn dw ?
	
	Up db 48h
	Down db 50h
	Left db 4Bh
	Right db 4Dh
	
	IsPause db 0h
	gameOverString db "GAME OVER", 0
	scopeString db 'score:  $'
	scope dw 0h
	
	snakePosition dw 0104h
	snakeDirection db 4Dh
	
	currentTime dw 0
	nextTime dw 0
	
	speedCoef dw 01h
	
	redColour db 04h
	blueColour db 03h
	fruitColour db 05h
	
end @entry 
cseg ends