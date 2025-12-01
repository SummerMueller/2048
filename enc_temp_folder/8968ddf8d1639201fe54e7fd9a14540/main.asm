INCLUDE Irvine32.inc

.data
intGrid word 16 dup(0)
strGrid byte 16 dup("|       ",0)
strRep byte "|       ", "|   2   ", "|   4   ", "|   8   ", "|   16  ", "|   32  ", "|   64  ", "|  128  ", "|  256  ", "|  512  ", "|  1024 ", "|  2048 "

horLine byte "+-------+-------+-------+-------+",0
verLine byte "|",0
startRow byte 5
startCol byte 40
lostMsg byte "Sorry, you ran out of moves. You lost."

;    +-------+-------+-------+-------+
;    |   0   |   0   |  2048 |   0   |
;    +-------+-------+-------+-------+
;    |   0   |   16  |   0   |   0   |
;    +-------+-------+-------+-------+
;    |   0   |   0   |   0   |   0   |
;    +-------+-------+-------+-------+
;    |   0   |   0   |   0   |   0   |
;    +-------+-------+-------+-------+


.code
main PROC
	gameLoop:
	call printGrid
	call newTile
	call printGrid
	cmp ebx, 1
	je gameLost
	jmp gameLoop

	gameLost:


	endprogram:
	exit
main ENDP


newTile proc
	pushad
	
	mov esi, offset intGrid
	mov ecx, 16
	xor ebx, ebx
	xor edi, edi

	countEmpty:
	mov al, [esi + edi]
	cmp al, 0
	jne notEmpty
	inc ebx
	notEmpty:
	inc edi
	loop countEmpty

	cmp ebx, 0
	je boardFull

	mov eax, ebx
	dec eax
	call randomrange
	mov ebp, eax

	xor edi, edi
	xor eax, eax
	findEmpty:
	mov dl, [esi + edi]
	cmp dl, 0
	jne skipCell
	cmp eax, ebp
	je placeTile
	inc eax
	skipCell:
	inc edi
	jmp findEmpty

	placeTile:
	mov eax, 4
	call randomrange
	cmp eax, 3
	je makeFour
	mov al, 1
	jmp storeTile
	makeFour:
	mov al, 2

	storeTile:
	mov [esi + edi], al
	popad
	jmp done

	boardFull:
	popad
	mov ebx, 1

	done:
	ret
newTile ENDP


printGrid proc
	pushad
	
	call clrscr
	mov dh, [startRow]
	mov dl, [startCol]
	mov eax, 4   ;keeps track of the outer loop
	xor ebx, ebx   ;keeps track of the array index
	
	printRow:
	call gotoxy
	push edx
	mov edx, offset horLine
	call writestring
	pop edx
	inc dh
	mov ecx, 4  ;keeps track of the inner loop
	call gotoxy

	printCell:
	push edx
	lea edx, [intGrid + ebx]
	call writestring
	pop edx
	add ebx, 9
	dec ecx
	cmp ecx, 0
	jne printCell

	push edx
	mov edx, offset verLine
	call writestring
	pop edx
	inc dh
	mov dl, [startCol]
	dec eax
	cmp eax, 0
	jne printRow

	call gotoxy
	mov edx, offset horLine
	call writestring

	popad
	ret
printGrid ENDP


END main
