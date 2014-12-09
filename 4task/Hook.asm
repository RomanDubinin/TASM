; запомнить старый обработчик, запилить свой, показать, восстановить старый
.386
assume CS:cseg, DS:dseg, SS:sseg

sseg segment stack use16
	db 256 dup (?)
sseg ends

dseg segment use16
	test_s db 'tsm msg$'
	hack_s db 'you are trapped$'
dseg ends

cseg segment use16
include victim.inc

defaultHandler dd ?

replace proc
	mov ah, 25h   ; save
	mov al, 21h
	mov dx, seg myHook
	mov ds, dx
	mov dx, offset myHook
	int 21h
	
	ret
replace endp

conversely proc
	lds dx, defaultHandler ; defaultHandler -> dx; defaultHandler+2 -> ds
	mov ah, 25h         ; save
	mov al, 21h
	int 21h
	
	ret
conversely endp

myHook proc
	cmp ah, 9h
	jnz original
	
	;push dx
	lea dx, hack_s
	;jmp ds:dword ptr defaultHandler
	;pop dx
	
	original:
	jmp cs:dword ptr defaultHandler
myHook endp

main:
	; backup old handler of 21h
	mov ah, 35h   ; load
	mov al, 21h
	int 21h
	mov word ptr cs:[defaultHandler], bx   ; offset
	mov word ptr cs:[defaultHandler+2], es ; segment

	; put our handler
	call replace
	
	mov ax, dseg
	mov ds, ax
	
	call victim
	
	call conversely
	
	mov ax, dseg
	mov ds, ax

	call victim
	
	return:
		mov	ax, 4c00h
		int 21h

cseg ends
end main