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


@start:
	mov ah, 0Fh
	int 10h
	
	mov bl, 0
	call printBX
	mov bx, ax
	call printBX

end @entry 
cseg ends