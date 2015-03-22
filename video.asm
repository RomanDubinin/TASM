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
	
	mov bx, dx; bx - first param : second param
	
	mov cx, 0
	
	cmp ds:[80h], byte ptr 9
	jl @doThings ; нет ключа возврата
	
	cmp ds:[8Ah], byte ptr '/'
	jne @paramError
	
	cmp ds:[8Bh], byte ptr '-'
	jne @paramError

	mov cx, 1
	
	@doThings:
	call printBX
	
	cmp cx, 0
	je @exit
	
	mov ah, 02h
	mov dx, '*'
	int 21h
	
	@exit:
	ret
	
	@paramError:
	mov ah, 9h
	mov dx, offset paramErrorMsg
	int 21h
	
	mov ah, 4ch
	int 21h
	
	paramErrorMsg db 'param error$'
end @entry 