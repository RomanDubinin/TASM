.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  

ENTRY:
	jmp main
	
	
;==================================================================
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

printIntVector proc
	;al - num of interrupt
	pusha
	mov	ah,35h
	int	21h
	push bx; offset
	mov bx, es
	call printBX
	mov ah, 02h
	mov dl, ':'
	int 21h
	pop bx
	call printBX
	popa
	ret
printIntVector endp

printNewString proc
	pusha
	lea dx, newString
	mov ah, 09h
	int 21h
	popa
	ret
printNewString endp

printCurrentSeg proc
	pusha
	lea dx, curSegString
	mov ah, 09h
	int 21h
	
	mov bx, cs
	call printBX
	
	lea dx, newString
	mov ah, 09h
	int 21h
	popa
	ret
printCurrentSeg endp

printInfo proc
	pusha
	;00h
	lea dx, int00AdrStr
	mov ah, 09h
	int 21h
	
	mov al, 00h
	call printIntVector
	call printNewString
	;2fh
	lea dx, int2FAdrStr
	mov ah, 09h
	int 21h
	
	mov al, 2Fh
	call printIntVector
	call printNewString
	popa
	ret
printInfo endp

uninstallResident proc
	pusha
	
	call printCurrentSeg
	
	mov ax, 1
	call checkHook
	cmp ax, 0
	jne uninstallFail 
	
	call killResident
	
	lea dx, uninstallMess
	mov ah, 09h
	int 21h
	
	uninstallFail:
	
	popa
	ret
uninstallResident endp
	
	
killResident proc
	pusha
	
	call printCurrentSeg
	
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
	
	lea dx, killMes
	mov ah, 09h
	int 21h
	
	mov ax, cs:[2ch]
	push ax
	pop es
	mov ah, 49h
	int 21h
	
	push cs
	pop es

	mov ah, 49h ; освобождаем память 
    int 21h
	
	
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
	
	mov ax, es
	mov dx, ds
	
	cmp dx, ax
	jne exit
	
	
	mov	ax,352Fh
	int	21h
	
	push offset hookManager
	pop ax
	
	cmp ax, bx
	jne exit
	
	mov ax, es
	mov dx, ds
	
	cmp dx, ax
	jne exit
	
	popa
	mov ax, 0
	ret
	exit:
	popa
	ret
checkHook endp


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
	
	;jmp managerExit
	
	not88:
	pop ds;восстановил ds вызывающей программы
	jmp dword ptr cs:[default2FVector] 
	
	managerExit:
	pop ds;восстановил ds вызывающей программы
	iret

hookManager endp

interruptHook proc
	push ds ; сохраняю ds вызвавшей программы
	
	push cs
	pop ds ; в ds кладу сегмент, в котором лежит моё прерывание

	
	mov ah, 9h
	mov dx, offset mes
	int 21h
	
	pop ds;восстановил ds вызывающей программы
	jmp dword ptr cs:[default00Vector]  ; Зовем стандартный обработчик

	iret ; не нужен
interruptHook endp

default00Vector	dd ?
default2FVector dd ?

mes db 'hook$'
installMess db 'install', 10, 13, '$'
uninstallMess db 'uninstall', 10, 13, '$'
killMes db 'kill', 10, 13, '$'
newString db 10, 13, '$'
int00AdrStr db '00 vector: $'
int2FAdrStr db '2F vector: $'
curSegString db 'current segment: $'

residentEnd:


helpMes db 'help:',10,13
db 'h - help',10,13
db 'i - install',10,13
db 'u - uninstall',10,13
db 'k - kill$',10,13
db '$',10,13

cannotUninstall db 'cannot uninstall resident$'
cannotInstallMess db 'resident alrady in table$'
cannotKill db 'cannot kill$'
exists db 'resident exests$'
absent db 'resident is absent$'

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
	
	call printInfo
	
	mov ax, 8883h; check
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
	
	lea dx, installMess
	mov ah, 09h
	int 21h
	
	call printInfo
	call printNewString
	
	mov	dx,offset residentEnd
	int	27h
	
	endInstall:
	
	lea dx, cannotInstallMess
	mov ah, 09h
	int 21h
	
	popa
	ret

install endp
	
uninstall proc
	pusha
	
	call printInfo
	
	mov ax, 8881h; uninstall
	int 2Fh
	
	call printInfo
	call printNewString
	
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
	
	
	endUninstall:
	popa
	ret
uninstall endp

kill proc
	pusha
	
	call printInfo
	
	mov ax, 8882h
	int 2Fh
	
	call printInfo
	call printNewString
	
	mov ax, 8883h
	int 2fh
	cmp ax, 0
	jne successKill; 
	
	unSuccessKill:; всё плохо
	mov ah, 9h
	mov dx, offset cannotKill
	int 21h
	jmp endKill
	
	successKill:
	
	endKill:
	popa
	ret

kill endp

status proc
	popa
	
	mov ax, 8883h
	int 2fh
	cmp ax, 0
	jne @absent
	
	mov ah, 9h
	mov dx, offset exists
	int 21h
	call printNewString
	call printInfo
	jmp @statusEnd
	
	@absent:
	mov ah, 9h
	mov dx, offset absent
	int 21h
	call printNewString
	call printInfo
	
	@statusEnd:
	pusha
	ret
status endp


main:
	
	mov cl, 6
	
	mov al, cs:[82h]
	lea di, keys
	
	repne scasb ; es:di - ax
	shl cx, 1 ; *2
	mov di, cx
	call lbs[di]
	
	mov ah,04Ch
    int 21h
	
	keys db 'suikh'
	lbs dw help, help, kill, install, uninstall, status
cseg ends	
end ENTRY
