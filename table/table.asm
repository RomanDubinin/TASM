;00h - установить видео режим
;05h - set active display page
;0Fh - get info: AL - video mode
;				 AH - characters per line
;				 BH - active display page num

;сегмент окружения в инвайронмент

.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  
@entry: jmp @start

printBX proc
	pusha
	mov cx, 4 
@k:
	rol bx, 4 ; bx = 0001000000010000 ; cyсle rotate left
	mov al, bl ; al = 00010000
	and al, 0fh ; al = 00000000
	cmp al, 10 
	sbb al, 69h ; op1 - (op2 + cf)
	das
	mov dh, 02h
	xchg ax, dx
	int 21h
	loop @k
	popa
	ret
printBX endp

printVideoMode proc
	pusha
	
	mov ah, 0Fh
	int 10h
	
	mov bl, 0
	call printBX
	mov bx, ax
	call printBX
	
	popa
	ret
printVideoMode endp


IsHexChar proc
	cmp al, 'A'
	jl @int
	
	cmp al, 'F'
	jg @int
	
	sub al, 'A' - 10
	clc; clear carry flag
	ret
	
	@int:
	cmp al, '0'
	jl @fail
	
	cmp al, '9'
	jg @fail
	
	sub al, '0'
	clc; clear carry flag
	ret
	
	@fail:
	stc; set  carry flag
	ret
IsHexChar endp

HorizontLine proc;рисую оттуда, куда поставлен курсор
	pusha
	
	;понадеюсь на bh
	mov cx, 18
	mov al, 205
	mov ah, 09h
	;mov bl, 12h
	int 10h
	
	popa
	ret
HorizontLine endp

VerticalLine proc
	pusha
	
	mov cx, 1
	;mov bl, 12h
	
	@verticalCycle:
	mov ah, 02h
	int 10h
	mov al, 186
	mov ah, 09h
	int 10h
	inc dh
	cmp dh ,20
	jne @verticalCycle
	
	popa
	ret
VerticalLine endp

ViewTableItems proc
	pusha
	
	call ViewSpeciallRollAndCollumn
	
	mov bl, 12h
	;horizontal lines
	mov dl, cs:[left]
	sub dl, 2
	mov dh, cs:[up]
	sub dh, 3
	mov ah, 02h
	int 10h
	call HorizontLine
	
	add dh, 2
	int 10h
	call HorizontLine
	
	add dh, 17
	int 10h
	call HorizontLine
	
	;vertical lines
	mov dl, cs:[left]
	sub dl, 3
	mov dh, cs:[up]
	sub dh, 2
	mov ah, 02h
	int 10h
	call VerticalLine
	
	add dl, 2
	int 10h
	call VerticalLine
	
	add dl, 17
	int 10h
	call VerticalLine
	
	;angles
	mov cx, 1
	
	mov dl, cs:[left]
	sub dl, 3
	mov dh, cs:[up]
	sub dh, 3
	mov ah, 02h
	int 10h
	
	mov al, 201
	mov ah, 09h
	int 10h
	
	add dl, 2
	mov ah, 02h
	int 10h
	mov al, 203
	mov ah, 09h
	int 10h
	
	add dl, 17
	mov ah, 02h
	int 10h
	mov al, 187
	mov ah, 09h
	int 10h
	
	mov dl, cs:[left]
	sub dl, 3
	mov dh, cs:[up]
	sub dh, 1
	mov ah, 02h
	int 10h
	
	mov al, 204
	mov ah, 09h
	int 10h
	
	add dl, 2
	mov ah, 02h
	int 10h
	mov al, 206
	mov ah, 09h
	int 10h
	
	add dl, 17
	mov ah, 02h
	int 10h
	mov al, 185
	mov ah, 09h
	int 10h
	
	mov dl, cs:[left]
	sub dl, 3
	mov dh, cs:[up]
	add dh, 16
	mov ah, 02h
	int 10h
	
	mov al, 200
	mov ah, 09h
	int 10h
	
	add dl, 2
	mov ah, 02h
	int 10h
	
	mov al, 202
	mov ah, 09h
	int 10h
	
	add dl, 17
	mov ah, 02h
	int 10h
	
	mov al, 188
	mov ah, 09h
	int 10h
	
	popa
	ret
ViewTableItems endp

ViewSpeciallRollAndCollumn proc
	pusha
	
	mov bl, 5h
	
	mov dl, cs:[left]
	sub dl, 2
	mov dh, cs:[up]
	
	mov al, '0'
	@speciallColumnCycle1:
	mov ah, 02h
	int 10h
	mov ah, 09h
	int 10h
	inc al
	inc dh
	cmp al, '9'
	jng @speciallColumnCycle1
	
	mov al, 'A'
	@speciallColumnCycle2:
	mov ah, 02h
	int 10h
	mov ah, 09h
	int 10h
	inc al
	inc dh
	cmp al, 'F'
	jng @speciallColumnCycle2
	
	mov dl, cs:[left]
	mov dh, cs:[up]
	sub dh, 2
	
	mov al, '0'
	@speciallRowCycle1:
	mov ah, 02h
	int 10h
	mov ah, 09h
	int 10h
	inc al
	inc dl
	cmp al, '9'
	jng @speciallRowCycle1
	
	mov al, 'A'
	@speciallRowCycle2:
	mov ah, 02h
	int 10h
	mov ah, 09h
	int 10h
	inc al
	inc dl
	cmp al, 'F'
	jng @speciallRowCycle2
	
	mov dl, cs:[left]
	mov dh, cs:[up]
	sub dh, 2
	sub dl, 2
	
	mov ah, 02h
	int 10h
	
	mov al, '\'
	mov ah, 09h
	int 10h
	
	popa
	ret
ViewSpeciallRollAndCollumn endp

@start:
	
	cmp ds:[80h], byte ptr 4
	jl @paramError
	cmp ds:[82h], byte ptr '/'
	jne @paramError
	
	mov si, 83h
	mov cx, 2
	@loop1:
	lodsb; ds:si -> al
	call IsHexChar
	jc @paramError
	shl dx, 4
	or dl, al
	loop @loop1
	
	cmp ds:[80h], byte ptr 8
	jl @paramError
	cmp ds:[86h], byte ptr '/'
	jne @paramError
	
	mov si, 87h
	mov cx, 2
	@loop2:
	lodsb; ds:si -> al
	call IsHexChar
	jc @paramError
	shl dx, 4
	or dl, al
	loop @loop2
	
	mov di, dx; di - first param : second param
	
	@doThings:
	; set v mode
	mov ah, 00h
	mov al, dh
	int 10h
	
	;set page
	mov ah, 05h
	mov al, dl
	int 10h
	
	;left treshold
	mov ah, 0Fh
	int 10h 
	mov cs:[left], ah
	shr cs:[left], 1
	sub cs:[left], byte ptr 8
	
	mov bx, dx; page & mode in bx
	mov bh, bl
	mov cx, 1
	xor ax, ax
	xor dx, dx
	@sycle:
    
	;output
	add dl, cs:[left]
	add dh, cs:[up]
	mov ah, 02h
	int 10h
	
	mov ah, 09h
	mov bl, 12h
	int 10h
	
	sub dl,  cs:[left]
	sub dh, [up]
	inc dx
	inc ax
	
	test dl, 0fh
	jnz @sycle
	
	;new line
	
	add dx, 0100h
	xor dl, dl
	
	test dh, 0fh
	jne @sycle
	
	call ViewTableItems
	
	@exit:
	ret
	
	@paramError:
	mov ah, 9h
	mov dx, offset paramErrorMsg
	int 21h
	
	mov ah, 4ch
	int 21h
	
	paramErrorMsg db 'param error$'
	left db 0
	up db 4
end @entry 
cs ends