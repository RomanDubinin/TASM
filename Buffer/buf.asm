.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  
@entry: jmp @start

	buf	dw	5 dup (2)
	bufSize dw $ - offset buf
	head dw offset buf
	tail dw offset buf
	
isEmpty proc
	pusha
	mov ax, head
	mov dx, tail
	cmp ax, dx
	popa
	ret
isEmpty endp

closedInc proc ; di
	push ax
	push bx
	add di, 2
	mov ax, di
	mov bx, offset buf
	add bx, bufSize
	cmp ax, bx
	jne @endInc
	
	mov di, offset buf
	
	@endInc:
	
	pop bx
	pop ax
	ret
closedInc endp

insert proc ; ax - val
	pusha
	
	mov di, cs:[head] ; address 
	mov cs:[di], ax
	call closedInc
	mov head, di
	call isEmpty
	je @dataMiss
	popa 
	ret
	
	@dataMiss:
	add tail, 2
	popa
	ret
insert endp
	
erase proc
	push di
	
	call isEmpty
	je @endErase
	
	mov di, cs:[tail]
	mov ax, cs:[di]
	
	call closedInc
	mov tail, di
	
	@endErase:
	
	pop di
	ret
erase endp
	
@start:
	mov ax, 3
	call insert
	mov ax, 3
	call insert
	mov ax, 4
	call insert
	mov ax, 5
	call insert
	mov ax, 6
	call insert
	
	call erase
	mov ah, 02h
	mov dx, ax
	int 21h
	mov ax, 10
	call erase
	mov ah, 02h
	mov dx, ax
	int 21h
	mov ax, 10
	call erase
	mov ah, 02h
	mov dx, ax
	int 21h
	mov ax, 10
	call erase
	mov ah, 02h
	mov dx, ax
	int 21h
	mov ax, 10
	call erase
	mov ah, 02h
	mov dx, ax
	int 21h
	mov ax, 10
	
	
	
	
	mov ah, 02h
	mov dx, '-'
	int 21h
	
	mov cx, bufSize
	shr cx, 1
	mov di, offset buf
	@loop1:
	mov ah, 02h
	mov dx, [di]
	add di, 2
	int 21h
	mov ah, 02h
	mov dx, '_'
	int 21h
	loop @loop1
	
	;mov ax, bufSize
	;call isEmpty
	;je @e
	;
	;mov ah, 02h
	;mov dx, '-'
	;int 21h
	;ret
	;
	;@e:
	;mov ah, 02h
	;mov dx, '+'
	;int 21h
	
	ret
end @entry 
cseg ends