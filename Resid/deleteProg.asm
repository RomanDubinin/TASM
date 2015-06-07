;сегмент окружения в инвайронмент

.model tiny
.code
org  100h
@entry: jmp @start

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

	;cmp ds:[80h], byte ptr 5
	;jne @paramError
	
	mov si, 82h
	mov cx, 4
@loop:
	lodsb; ds:si -> al
	call IsHexChar
	jc @paramError
	shl dx, 4
	or dl, al
	loop @loop
	
	ret
	;mov ax, 132Ah
	;push es
	;push ax
	;pop es
	;
	;mov ah, 49h
	;int 21h
	;
	;pop es
	
	@paramError:
	mov ah, 9h
	mov dx, offset paramErrorMsg
	int 21h
	
	mov ah, 4ch
	int 21h
	
	paramErrorMsg db 'pram error$'
end @entry 