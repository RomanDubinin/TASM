.model tiny
.code
org  100h
@entry: jmp @start

defaultVector dd ?

hook proc
	jmp cs:[defaultVector]
hook endp

@start:
	mov es, cs:[2ch]
	mov cx, len;кол-во раз
	mov si, offset data
	xor di, di
	rep movsb ;ds:si -> es:di
	
	;mov es, word ptr cs:[2ch]
	mov bx, 1
	mov ah, 4Ah
	int 21h
	
	mov ax,3500h
	int 21h
	mov word ptr [defaultVector], bx 
	mov word ptr [defaultVector+2], es
	cli
	mov ah,25h 
	lea dx, hook
	int 21h
	sti
	
	lea dx, @start
	int 27h
	
	data db 20h, 00h, 00h, 01h, 00h, 'name2', 00h
	len dw $-data
end @entry 