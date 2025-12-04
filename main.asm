INCLUDE Irvine32.inc

.data
intGrid byte 16 dup(0)
tempGrid byte 16 dup(0)
strRep byte "|       ",0,
			"|   2   ",0,
			"|   4   ",0,
			"|   8   ",0,
			"|   16  ",0,
			"|   32  ",0,
			"|   64  ",0,
			"|  128  ",0,
			"|  256  ",0,
			"|  512  ",0,
			"|  1024 ",0,
			"|  2048 ",0,
			"|  4096 ",0

horLine byte "+-------+-------+-------+-------+",0
verLine byte "|",0
startRow byte 5
startCol byte 40
rot90CW byte 12,8,4,0,13,9,5,1,14,10,6,2,15,11,7,3
rot180 byte 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
rot90CCW byte 3,7,11,15,2,6,10,14,1,5,9,13,0,4,8,12
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
	call Randomize
	gameLoop:
	call newTile
	call printGrid
	xor ebx, ebx
	call checkGameOver
	cmp ebx, 1
	je gameLost
	call getMove
	jmp gameLoop

	gameLost:
	inc dh
	inc dh
	call gotoxy
	push edx
	mov edx, offset lostMsg
	call writestring
	pop edx

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
	movzx edi, byte ptr [intGrid + ebx]
	imul edi, 9
	push edx
	lea edx, [strRep + edi]
	call writestring
	pop edx
	inc ebx
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
printGrid endp


checkGameOver proc
	pushad

	mov esi, offset intGrid
	mov ecx, 16
	xor edi, edi

	;checks if the grid has any open cells
	checkEmpty:
	mov al, [esi + edi]
	cmp al, 0
	je gameNotOver
	inc edi
	loop checkEmpty

	;checks if horizontal merges can be made
	mov edx, 0
	rowLoopH:
	mov ecx, 3
	mov edi, edx
	colLoopH:
	mov al, [esi + edi]
	mov bl, [esi + edi + 1]
	cmp al, bl
	je gameNotOver
	inc edi
	loop ColLoopH
	add edx, 4
	cmp edx, 16
	jne rowLoopH


	gameOver:
	popad
	mov ebx, 1
	jmp back

	gameNotOver:
	popad 
	mov ebx, 0
	jmp back

	back:
	ret
checkGameOver endp


getMove proc
	pushad

	getInput:  ;loops until the input is wasd or arrowkeys
	xor eax, eax
	call readchar
	cmp al, 119
	je applyUp
	cmp al, 97
	je applyLeft
	cmp al, 115
	je applyRight
	cmp al, 100
	je applyDown
	jmp getInput

	applyUp:
	mov edx, 3
	call rotate
	call moveLeft
	mov edx, 1
	call rotate
	jmp doneMove

	applyLeft:
	call moveLeft
	jmp doneMove

	applyRight:
	mov edx, 1
	call rotate
	call moveLeft
	mov edx, 3
	call rotate
	jmp doneMove

	applyDown:
	mov edx, 2
	call rotate
	call moveLeft
	call rotate
	jmp doneMove

	doneMove:
	popad
	ret
getMove endp


moveLeft proc
	pushad

	mov ecx, 0

	rowLoop:
	xor edx, edx
	mov ebx, ecx
	shl ebx, 2
	mov esi, offset intGrid
	mov edi, esi
	add edi, ebx

	xor eax, eax
	mov ebx, 0

	firstShift:
	cmp ebx, 4
	jge shiftDOne
	mov al, [edi + ebx]
	cmp al, 0
	je skipShift
	mov [edi + edx], al
	inc edx
	skipShift:
	inc ebx
	jmp firstShift
	shiftDone:
	mov ebx, edx
	fillZero:
	cmp ebx, 4
	jge doneZero
	mov byte ptr [edi + ebx], 0
	inc ebx
	jmp fillZero
	doneZero:
	mov ebx, 0

	mergeLoop:
	cmp ebx, 3
	jge mergeDone
	mov al, [edi + ebx]
	cmp al, 0
	je skipMerge
	mov ah, [edi + ebx + 1]
	cmp al, ah
	jne skipMerge
	inc al
	mov [edi + ebx], al
	mov byte ptr [edi + ebx + 1], 0
	inc ebx
	skipMerge:
	inc ebx
	jmp mergeLoop
	mergeDone:
	xor edx, edx
	mov ebx, 0

	secondShift:
	cmp ebx, 4
	jge doneShift2
	mov al, [edi + ebx]
	cmp al, 0
	je skipShift2
	mov [edi + edx], al
	inc edx
	skipShift2:
	inc ebx
	jmp secondShift
	doneShift2:
	mov ebx, edx
	fillZero2:
	cmp ebx, 4
	jge doneRow
	mov byte ptr [edi + ebx], 0
	inc ebx
	jmp fillZero2

	doneRow:
	inc ecx
	cmp ecx, 4
	jl rowLoop

	popad
	ret
moveLeft endp


rotate proc
	pushad
	;edx will contain the number to indicate which rotation
	;1 is 90 CW, 2 is 180, and 3 is 90 CWW

	mov esi, offset intGrid
	mov edi, offset tempGrid
	mov ecx, 0

	rotateLoop:
	cmp ecx, 16
	jge doneRotate

	cmp edx, 1
	je rot1
	cmp edx, 2
	je rot2
	cmp edx, 3
	je rot3
	jmp doneCopy

	rot1:
	movzx ebx, byte ptr [rot90CW + ecx]
	jmp cont

	rot2:
	movzx ebx, byte ptr [rot180 +ecx]
	jmp cont

	rot3:
	movzx ebx, byte ptr [rot90CCW + ecx]
	
	cont:
	mov al, [esi + ebx]
	mov [edi + ecx], al
	skipMap:
	inc ecx
	jmp rotateLoop
	doneRotate:

	mov ecx, 0
	copyBack:
	cmp ecx, 16
	jge doneCopy
	mov al, [edi + ecx]
	mov [esi + ecx], al
	inc ecx
	jmp copyBack

	doneCopy:
	popad
	ret
rotate endp


END main
