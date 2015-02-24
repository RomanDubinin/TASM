.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  

ENTRY:
	jmp main
	
	
;==================================================================
uninstallResident proc
	pusha
	mov ax, 1
	call checkHook
	cmp ax, 0
	jne uninstallFail 
	
	call killResident
	
	uninstallFail:
	popa
	ret
uninstallResident endp
	
	
killResident proc
	pusha
	push ds
	cli
	lds dx, cs:[default00Vector]
	mov ax, 2500h ; 
	int 21h
	
	lds dx, cs:default2FVector
	mov ax, 252Fh ; 
	int 21h
	sti
	
	pop ds
	popa
	ret
killResident endp

checkHook proc
	pusha
	mov	ax,3500h
	int	21h
	
	
	push offset interruptHook
	pop ax
	
	cmp ax, bx
	jne exit
	
	push es
	pop ax
	push ds
	pop dx
	
	cmp dx, ax
	jne exit
	
	popa
	mov ax, 0
	ret
	exit:
	popa
	ret
checkHook endp


	;mov ah, 49h ; освобождаем память 
    ;int 21h
	


hookManager proc
	cmp ah, 88h
	jne not88
	
	push ds ; сохраняю ds вызвавшей программы
	
	push cs
	pop ds ; в ds кладу сегмент, в котором лежит моё прерывание

	cmp al, 81h
	jne _killResident
	call uninstallResident
	jmp managerExit
	
	_killResident:
	cmp al, 82h
	jne _chek
	call killResident
	jmp managerExit
	
	_chek:
	cmp al, 83h
	call checkHook
	
	jmp managerExit
	
	not88:
	call dword ptr cs:[default2FVector] 
	
	managerExit:
	pop ds;восстановил ds вызывающей программы
	iret

hookManager endp

interruptHook proc

	push ds ; сохраняю ds вызвавшей программы
	
	push cs
	pop ds ; в ds кладу сегмент, в котором лежит моё прерывание

	pushf
	mov ah, 9h
	mov dx, offset mes
	int 21h
	
	call dword ptr cs:[default00Vector]  ; Зовем стандартный обработчик

	pop ds;восстановил ds вызывающей программы
	
	iret ; восстановит cs


interruptHook endp

default00Vector	dd ?
default2FVector dd ?
mes db 'hook$'

residentEnd:

delMes db 'hookDeleted$'
helpMes db 'help$'
cannotUninstall db 'cannot uninstall resident$'

help proc
	pusha
	lea dx, helpMes
	mov ah, 09h
	int 21h
	popa
	ret
help endp

install proc
	pusha
	
	mov ax, 8883h
	int 2fh
	cmp ax, 0
	je endInstall
	
	mov	ax,352Fh
	int	21h
	mov	word ptr [default2FVector], bx 
	mov	word ptr [default2FVector+2], es
	cli
	mov	ax,252Fh 
	mov	dx,offset hookManager
	int	21h
	sti
	
	mov	ax,3500h
	int	21h
	mov	word ptr [default00Vector], bx 
	mov	word ptr [default00Vector+2], es
	cli
	mov	ax,2500h 
	mov	dx,offset interruptHook
	int	21h
	sti
	
	mov	dx,offset residentEnd
	int	27h
	
	endInstall:
	popa
	ret

install endp
	
uninstall proc
	pusha
	
	mov ax, 8881h
	int 2Fh
	
	mov ax, 8883h
	int 2fh
	cmp ax, 0
	jne successUninstall; 
	
	unSuccessUninstall:; всё плохо
	mov ah, 9h
	mov dx, offset cannotUninstall
	int 21h
	jmp endUninstall
	
	successUninstall:
	mov ah, 9h
	mov dx, offset delMes
	int 21h
	
	endUninstall:
	popa
	ret
uninstall endp

kill proc

kill endp


main:
	
	mov al, es:[82h]
	
	_help:
	cmp al, 'h'
	jnz _install
	call help
	jmp exitMain
	
	_install:
	cmp al, 'i'
	jnz _uninstall
	call install
	jmp exitMain
	
	_uninstall:
	cmp al, 'u'
	jnz _kill
	call uninstall
	jmp exitMain
	
	_kill:
	cmp al, 'u'
	jnz _unknown
	call kill
	jmp exitMain
	
	_unknown:
	call help
	jmp exitMain
	
	exitMain:
	mov ah,04Ch
    int 21h
	
cseg ends	
end ENTRY
