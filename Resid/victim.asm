.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h 

entry:
    jmp start

	mes db 'hi$'
start:
    
    mov ah, 9h
	lea dx, mes
	int 21h
    
    mov ah,04Ch
    int 21h
cseg ends
end entry