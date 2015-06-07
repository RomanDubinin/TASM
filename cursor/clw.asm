;int 33h
.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  
@entry: jmp @start

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
 
        
        neg     ax
oi1:
        xor     cx, cx
        mov     bx, 10
oi2:
        xor     dx,dx
        div     bx
 
        push    dx
        inc     cx
 
        test    ax, ax
        jnz     oi2
 
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
        mov bx, 0002h
        int 10h
       
        popa
        ret
put endp

clear proc
        pusha
       
        mov ah, 09h
        mov al, ' '
        mov bx, 0002h
		mov cx, 8
        int 10h
       
        popa
        ret
clear endp

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

findIndex proc ; ax - index, dx mas pointer, bx - masLen
	push cx
	push di
	push bx
	
	mov cx, bx
	;shl cx, 1
	dec cx
	mov di, cx
	add di, dx
	mov bx, [di]
	call printBX
	
	@loop:
	mov di, cx
	add di, dx
	mov bx, [di]
	cmp ax, bx
	je @loopEnd
	dec cx
	dec cx
	cmp cx, 0
	jg @loop
	
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
	;call printBX
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

	
int33 proc
	pusha
	
	
	mov [x], cx; cx - x
	mov [y], dx; dx - y
	
	cmp bx, 2h
	jne @NotR33
	
	mov ax, 81h
	call insert
	
	@NotR33:
	
	cmp bx, 1h
	jne @Exit33
	
	mov [leftDown], 1h
	
	@Exit33:
	popa
	retf
int33 endp


@start:	
	mov ah, 00h
	mov al, 4h
	int 10h
	
	mov ax, 00h
	int 33h
	mov ax, 0001h
	int 33h
	
	mov cx, 11
	mov ax, 000ch
	lea dx, int33
	int 33h
	
	mov ax, 3509h
	int 21h
	mov word ptr oldInt9,   bx
	mov word ptr oldInt9+2, es
	
	cli
	mov ax, 2509h
	mov dx, offset int9
	int 21h
	sti
	
	;/////////////////////////////////////
    
	@cycle:
	
	
	xor ax, ax
	call erase
	
	cmp al, 81h
	je @Exit
	
	
	mov ah, 0fh
	int 10h
	
	mov ah, 02h
	mov dx, 0h
	int 10h
	
	cmp [leftDown], 1h
	jne @cycle
	
	
	call clear	
	push [x]
	call OutIntVga
	
	mov al, ';'
	call put
	
	push [y]
	call OutIntVga
	
	mov [leftDown], 0h
	
	jmp @cycle
	
	@Exit:
	cli
	mov ax, 2509h
	mov dx, word ptr cs:[oldInt9]
	mov ds, word ptr cs:[oldInt9+2]
	int 21h
	sti
	
	mov cx, 0
	mov ax, 000ch
	lea dx, int33
	int 33h
	
	mov ah, 00h
	mov al, 3h
	int 10h
	
	ret
    
	oldInt9 dd ?
	oldInt1 dd ?
	
	x dw ?
	y dw ?
	leftDown db 0h
	
end @entry 
cseg ends