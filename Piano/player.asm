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

key1 db "1.txt"
buf1 db 60 dup(0)

@start:

	push offset key1
	push offset buf1
	call Readf
	pop ax
	pop ax
	
	mov cx, 0
	@cycle:
	mov ah, 02h
	mov di, cx
	mov dl, buf1[di]
	cmp dl, '#'
	je @playerExit
	int 21h
	
	inc cx
	jmp @cycle
	
	@playerExit:
	ret
end @entry 
cseg ends