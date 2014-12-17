.386
assume CS:cseg, DS:dseg, SS:sseg

sseg segment stack use16
	db 256 dup (?)
sseg ends

dseg segment use16
	testMes db 'tsm msg$'
	hookMes db 'you are trapped$'
dseg ends

cseg segment use16
include victim.inc

defaultHandler dd ?

replace proc
	cli
	mov ah, 25h   ; save
	mov al, 21h
	mov dx, seg myHook
	mov ds, dx
	mov dx, offset myHook
	int 21h
	sti
	
	ret
replace endp

conversely proc
	cli
	lds dx, defaultHandler ; defaultHandler -> dx; defaultHandler+2 -> ds
	mov ah, 25h         ; save
	mov al, 21h
	int 21h
	sti

	ret
conversely endp

myHook proc
	cmp ah, 9h
	jnz original

	lea dx, hookMes

	original:
	jmp cs:dword ptr defaultHandler
myHook endp

main:
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