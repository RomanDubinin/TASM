.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  
@entry: jmp @start

Readf proc
	pusha
	mov bp, sp
	
	mov ah, 3dh
	mov al, 0 ; read
	mov dx, [bp+20]
	int 21h    
	mov bx, ax; hendler
	
	mov ah, 3fh ; read
	mov cx, 64   ; size
	mov dx, [bp+18]
	int 21h
	add dx, -2 ;real size
	mov di, dx
	mov [di], ax

	mov ah, 3eh ; close file
	int 21h
	
	popa
	ret
Readf endp
	
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
	cmp ax, 0h
	je @doNotSound
	
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
	
	@doNotSound:
	call no_sound
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

findIndex proc ; ax - index, dx mas pointer
	push cx
	push di
	push bx
	
	mov cx, notesLen
	shl cx, 1
	
	@loop:
	dec cx
	dec cx
	mov di, cx
	add di, dx
	mov bx, [di]
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



key1 db "1.txt"
buf1 db 60 dup(0)



@start:

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
	;/////////////////////////////////////

	push offset key1
	push offset buf1
	call Readf
	pop ax
	pop ax
	
	mov cx, 0
	@cycle:
	mov ah, 02h
	mov di, cx
	mov al, buf1[di]
	inc cx
	mov ah, 0h
	
	cmp al, '`'
	je @playerExit
	
	sub ax, '0'
	shl ax, 4
	mov di, cx
	add al, buf1[di]
	sub al, '0'
	inc cx
	; key in ax
	lea dx, noteKodes
	call findIndex
	mov di, ax
	
	cmp di, 0
	je @unknownSymbol
	mov ax, noteFrequencies[di]
	
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
	
	inc cx
	jmp @cycle
	
	@unknownSymbol:
	mov ah, 09h
	lea dx, unknownSymbolStr
	int 21h
	
	@playerExit:
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
	
	unknownSymbolStr db 'unknown', 10, 13, '$'
	
	currentTime dw 0
	nextTime dw 0
	
	oldInt9 dd ?
	oldInt1 dd ?
	
	noteKodes dw 00h, 99h,	 01h, 02h, 03h, 04h, 05h, 06h, 07h,	 11h, 12h, 13h, 14h, 15h, 16h, 17h,	 21h, 22h, 23h, 24h, 25h, 26h, 27h, 	31h, 32h, 33h, 34h, 35h, 36h, 37h
	notesLen dw $ - noteKodes - 1
	noteFrequencies dw 0h, 0h,	130, 147, 164, 174, 196, 220, 246,	 261, 293, 329, 349, 392, 440, 493,	 523, 587, 659, 698, 784, 880, 987, 	1046, 1174, 1318, 1396, 1568, 1720, 1975
	
	pausesKodes dw 00h, 02h, 03h
	pausesLen dw $ - pausesKodes - 1
	pausesLens dw 00h, 05h, 0Ah
	
end @entry 
cseg ends