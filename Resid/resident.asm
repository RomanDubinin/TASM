.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  

ENTRY:
	jmp main

check proc
	mov ax, 0
	jmp endCheck
check endp

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
	jmp endCheckook
	exit:
	popa
	jmp endCheckook
checkHook endp

removeHook proc
	pusha

	push ds ; сохраняю ds вызвавшей программы
	
	mov dx, word ptr cs:[default00Vector]
	mov ds, word ptr cs:[default00Vector+2]
	mov ax, 2500h ; 
	int 21h
	
	pop ds ; в ds кладу сегмент, в котором лежит моё прерывание
	
	mov ah, 9h
	mov dx, offset delMes
	int 21h
	
	;mov ah, 49h ; освобождаем память 
    ;int 21h
	
	popa
	jmp endRemoveHook
removeHook endp

createHook proc

	mov	ax,3500h
	int	21h
	
	mov	word ptr default00Vector, bx 
	mov	word ptr default00Vector+2, es
	cli
	mov	ax,2500h 
	mov	dx,offset interruptHook
	int	21h
	sti
	jmp endCreateHook
createHook endp

hookManager proc

	cmp ah, 88h
	jne not88
	
	push ds ; сохраняю ds вызвавшей программы
	
	push cs
	pop ds ; в ds кладу сегмент, в котором лежит моё прерывание
	
	cmp al, 81h
	je createHook
	endCreateHook:

	cmp al, 82h
	je removeHook
	endRemoveHook:
	
	cmp al, 83h
	je checkHook
	endCheckook:
	
	cmp al, 84h
	je check
	endCheck:
	
	pop ds;восстановил ds вызывающей программы
	jmp managerExit
	
	not88:
	call dword ptr cs:[default2FVector] 
	
	managerExit:
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

default00Vector	dd ?
default2FVector dd ?
mes db 'hook$'
delMes db 'hookDeleted$'
interruptHook endp

main:
	
	mov	ax,352Fh
	int	21h
	
	mov	word ptr default2FVector, bx 
	mov	word ptr default2FVector+2, es
	cli
	mov	ax,252Fh 
	mov	dx,offset hookManager
	int	21h
	sti
	
	mov	dx,offset main
	int	27h
	
cseg ends	
end ENTRY
