.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  
@entry: jmp @start

	buf	dw	5 dup (2)
	bufSize dw $ - offset buf
	head dw offset buf
	tail dw offset buf
	oldInt9 dd ?
	oldInt1 dd ?
	
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

sound proc
    pusha
    mov bx, ax
	mov ax, 34ddh
	mov dx, 12h
	div bx
	mov bx, ax 
	in al, 61h
	or al, 3
	out 61h, al
	mov al, 10000110b
	mov dx, 43h
	out dx, al
	dec dx
	mov al, bl
	out dx, al
	mov al, bh
	out dx, al
    popa
    ret
sound endp

no_sound proc
	pusha
	in		al, 61h
	and		al, not 3
	out 	61h, al
	popa
	ret
no_sound endp

int1c proc
	push ds
	push cs
	pop ds
	
	inc currentTime
	pop ds
	db 0eah
	l1c dw 0, 0
int1c endp

findIndex proc
	push cx
	push di
	push bx
	
	mov cx, masLen
	shl cx, 1
	lea di, keys
	
	@loop:
	dec cx
	dec cx
	mov di, cx
	mov bx, keys[di]
	cmp ax, bx
	je @loopEnd
	cmp cx, 0
	jne @loop
	
	@loopEnd:
	mov ax, cx
	
	pop bx
	pop di
	pop cx
	
	ret
findIndex endp

	
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
	mov ah, 02h
	mov dx, 'm'
	int 21h
	
	mov di, cs:[tail]
	call closedInc
	mov tail, di
	
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

int9:
	; in - read from port
	; out - write into port
	in al, 60h
	
	call Insert
	
	in al, 61h
	or al, 80h ; выставить старший бит 1
	out 61h, al
	and al, 07fh
	out 61h, al
	
	mov al, 20h
	out 20h, al
	iret

; скан-коды клавиш
space db 039h
escCode db 81h
spaceMsg db 'space', 13, 10, '$'
notSpaceMsg db 'not space', 13, 10, '$'

@start:
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
	
	mov ah, 02h
	mov dx, 's'
	int 21h
	spaceWriter:
	call isEmpty
	je spaceWriter
	
	call erase
	cmp al, escCode
	je terminate
	cmp al, space
	je stopSound
	mov ah, 0h
	call findIndex
	mov di, ax
	cmp di, 0
	je spaceWriter
	mov bx, keys[di]
	;call printBX
	mov ax, lbs[di]
	
	call sound
	
	mov bx, currentTime
	add bx, 5h
	call printBX
	@wait:
	mov ax, currentTime
	;call printBX
	cmp bx, ax
	ja @wait
	call no_sound
	
	
	mov ah, 02h
	mov dl, 10
	int 21h
	jne spaceWriter
	
	stopSound:
	call no_sound
	jmp spaceWriter
	
	terminate:
	call no_sound
	cli
	mov ax, 2509h
	mov dx, word ptr cs:[oldInt9]
	mov ds, word ptr cs:[oldInt9+2]
	int 21h
	
	mov ax, 251ch
	mov dx, word ptr cs:[oldInt1]
	mov ds, word ptr cs:[oldInt1+2]
	int 21h
	
	ret
	
	currentTime dw 0
	nextTime dw 0
	
	keys dw 01,  02, 03, 04, 05, 06, 07, 08,	 10h, 11h, 12h, 13h, 14h, 15h, 16h, 	1Eh, 1Fh, 20h, 21h, 22h, 23h, 24h
	masLen dw $ - keys - 1
	lbs dw 0h, 261, 293, 329, 349, 392, 440, 493,	 523, 587, 659, 698, 784, 880, 987, 	1046, 1174, 1318, 1396, 1568, 1720, 1975
	
end @entry 
cseg ends