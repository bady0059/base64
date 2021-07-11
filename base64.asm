.386
IDEAL
MODEL small
STACK 100h
DATASEG
	
	;the user massage
	text DB 20
			DB 0
			DB 20 DUP('$')
	
	
	fileName db '          .txt',0  ;the file name
	helper db '0000000000',0     ;input the file name
	
	fileName1 db 'a.txt',0  
	helper1 db '0000000000',0     
	filehandle1 dw 0
	boolLoad db 0
	
	;final
	finalLength db 0
	final db 20 dup(32),'$'
	
	;the massage converted to binary
	binary db 160 dup(0)
	
	;binary converted to char
	char db 0
	
	;just counters
	count db 0 
	count2 db 0
	count3 db 0
	
	;use for loops witout using cx
	loopTimes db 0
	loopTimes1 db 0
	
	;the chars that base64 use
	chars db 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','-' 
	
	last db 0
	length1 db 0 ; length of text
	
	;massages
	msg1 db "choose one of the options below",10,13,"$"
	msg2 db "1 - encrypt massage",10,13,"$"
	msg3 db "2 - decrypt massage",10,13,"$"
	msg4 db "u entered wrong input",10,13,"$"
	msg5 db "enter your massage: ",10,13,"$"
	msg6 db "enter your file name with txt: ",10,13,"$"
	msg7 db "you are out",10,13,"$"
	msg8 db "again? (y/n)","$"
	msg9 db "3 - load file",10,13,"$"
	msg10 db "the file vul is ","$"
	n_line DB 0AH,0DH,"$"   ;for new line
	
	;file staff
	filehandle dw 0
	ErrorMsg db "error",10,13,"$"
	
	
	;place of cursor
	place dw 4aah
	
	endReset db 0
	
	allVar db 1000 dup(0),'$'
CODESEG
proc newLine
;go to new line
push dx
	lea dx,[n_line]
	mov ah,9
	int 21h
pop dx
ret
endp newLine
;////////////////////////
;print msg7 using bp
printMessage equ [bp+4]
proc exitProgram
push bp
mov bp,sp

	mov dx,offset msg7
	mov ah,9h
    int 21h
	
pop bp	
ret 
endp exitProgram

;/////////////////////
proc inputString
;input a string
;put the string in array text
	call newLine
		call lineDown
	mov ah, 0Ah 
    mov dx, offset text
    int 21h
ret
endp inputString
;/////////////////////
proc outputString
;output the string
;move offset of array to dx
	call newLine
		call lineDown
	mov ah,9h
    int 21h
	
ret
endp outputString
;///////////////////////////
proc graphic
;the graphic
	mov ah,6 ;interrupt
	MOV Al,0 ;clear the window
    MOV BH,71H ;font size
    MOV CX,0000H ;(0,0)
    MOV DX,184FH ;(18h,4fh)
    INT 10H
ret
endp graphic
;//////////////////////////
proc lineDown
;move line down
push dx
        MOV AH,02H  ;interrupt
        MOV BH,00   ;graphic mode
        MOV DX,[place]  ;place to move cursor
        INT 10H
		
		add [place],100h  ;go line down
pop dx
ret
endp lineDown
;//////////////////////////
proc reset
;save all the varibales 
push ax
push cx
push si
push di

	mov ax, offset text
	mov cx, offset endReset
	
	sub cx,ax
	
	mov si, offset text
	mov di, offset allVar
	
	makeCopy:
		mov dl,[si]
		mov [di],dl
		
		inc di
		inc si
	loop makeCopy

pop di	
pop si
pop cx
pop ax

ret
endp reset
;/////////////////////////
proc reset2
;return vul to all the varibales 
push ax
push cx
push si
push di

	mov ax, offset text
	mov cx, offset endReset
	
	sub cx,ax
	
	mov si, offset text
	mov di, offset allVar
	
	makePaste:
		mov dl,[di]
		mov [si],dl
		
		inc di
		inc si
	loop makePaste
		
pop di	
pop si
pop cx
pop ax

ret
endp reset2
;/////////////////////////
proc pow
;mov al base
;mov bl pow

	cmp bl,0 ;if pow 0 so the result is 1
	je Z
	
	cmp bl,1 ; if pow 1 the result is the base
	je O
	
	mov cl,bl
	sub cx,1
	
	mov bl,al
	loopPow:
		mul bl
	loop loopPow
	ret
	
	z:
	mov al,1
    ret
     
    O:  
       
ret
;result al
endp pow
;////////////////////////////
proc binToDec
;convert binary nember to decimal
;move to binary array the number
	
    mov [count],0
	mov [char],0
	mov si, offset binary  
	loopGoOverArr: 
	    mov si, offset binary
        mov al,[loopTimes]
	    mov ah,0  
	    add si,ax
	    
		mov dl,[si]
		cmp dl,1
		je one
		jmp zero
		
		one:
		mov bl,[count]
		mov al,2
		call pow
		add [char],al
		
		
		zero:
		dec [loopTimes]
		add [count],1
	mov al,[last]
	cmp [loopTimes],al
	jne loopGoOverArr
;char have the 6 bit number
ret
endp binToDec
;/////////////////////
proc textToBin
; take the user input from text
; convert it to binary 

	mov SI,offset binary
    mov di,offset text
	
	cmp [boolLoad],1
	je aaaa
	
    add di,2

    aaaa:
        mov [count2],0 
        add si,8
        MOV ax,[di]
        MOV BH,00
        MOV BL,2
	
        bbbb:  
        MOV AH,0
		    DIV BL
            MOV [SI],AH 
            MOV AH,00
            dec SI
            INC BH
            inc [count2] 
            
        CMP AL,00
        JNE bbbb 
    
    mov al,[count2]  
    mov ah,0
    add si,ax
    add di,1
    
	mov ax,[di]
    cmp al,'$'
    jne aaaa

ret
endp textToBin

;////////////////////
;///////////////////
proc encrypt
	
	mov dx, offset text ;print the massage
	cmp [boolLoad],1
	je not1
	
	add dx,2 
	
	not1:
	call outputString
	
	call newLine
	call textToBin ;convert to binary
	
	;count letters of massage
	MOV si,offset text
	cmp [boolLoad],1
	je letters
	
	add si,2 
	
	letters:
	    
	    add [length1],1
	    inc si
	    mov dl,[si]
	cmp dl,'$'
	jne letters
	
	cmp [boolLoad],1
	je not3
	
	dec [length1]
	not3:
	
	mov al,[length1] ;mov length to al
	mov bl,8 ;mov 8 to bl
	mul bl ; multiply them to get the legth of the massage in binary
	
	mov bx,6
	mov ah,0  
	mov bh,0
	mov cx,0
	mov dx,0
	div bx ;read 6 bits every time
	mov [length1],al
	
	cmp dx,0
	je l6
	
	inc [length1]
	
	l6:
	
	mov [loopTimes1],6 ;6 bit
	mov [last],0
	
	L5: 
	
	mov al,[loopTimes1]
	mov [loopTimes],al
	call binToDec
	
    	mov si,offset chars
    	mov al,[char]
    	mov ah,0
    	add si,ax
    	mov dl,[si] 
	    call addCharToFinal
		
	    add  [loopTimes1],6 
	    add  [last],6
	    
	dec [length1]
	cmp [length1],0
	jne L5
	; 
	
	
	
	
ret
endp encrypt
;/////////////////////////////////
proc findNum
; convert the char in the chars to his index
;mov dl char
push si
push di	
    
    mov [count3],0
	mov si,offset chars
	dec si
	loopiLoop:
	
		add si,1
		mov bl,[si]
		add [count3],1
		
	cmp dl,bl
	jne loopiLoop
	
	dec [count3]
;num on count 3	

pop di
pop si

ret 
endp findNum
;/////////////////////////////////
proc to6
;convert the encrypted text to binary

	mov SI,offset binary
    mov di,offset text
	
	cmp [boolLoad],1
	je aa
    add di,2
   
    aa:
        mov [count2],0 
        add si,6
		
		mov dl,[di] ;the char
		call findNum
		mov ah,0
        MOV al,[count3]  ;al have the number of the char
		
		;convert to binary
        MOV BH,00
        MOV BL,2
	
        bb:  
			MOV AH,0
		    DIV BL
            MOV [SI],AH 
            MOV AH,00
            dec SI
            INC BH
            inc [count2] 
            
        CMP AL,00
        JNE bb 
    
    mov al,[count2]  
    mov ah,0
    add si,ax
    add di,1
    
	cmp [boolLoad],1
	je not4
	
	mov ax,[di+1]
	not4:
	
	mov ax,[di]
    cmp al,'$'
    jne aa
	
ret
endp to6
;/////////////////////////////////
;/////////////////////////////////
proc decrypt
	
	mov dx, offset text
	cmp [boolLoad],1
	je not5
	
	add dx,2 
	
	not5:
	call outputString
	
	call to6 ;convert to binary
	call newLine
	
	;count letters 
	MOV si,offset text
	cmp [boolLoad],1
	je letters1
	
	add si,2 
	
	letters1:
	    
	    add [length1],1
	    inc si
	    mov dl,[si]
	cmp dl,'$'
	jne letters1
	
	cmp [boolLoad],1
	je not2
	
	dec [length1]
	not2:
	
	mov al,[length1]
	mov bl,8
	mul bl
	
	mov bx,6
	mov ah,0  
	mov bh,0
	mov cx,0
	mov dx,0
	div bx
	mov [length1],al
	
	cmp dx,0
	je l9
	
	inc [length1]
	
	l9:
	
	mov [loopTimes1],8
	mov [last],0
	L8: 
	
	mov al,[loopTimes1]
	mov [loopTimes],al
	call binToDec
        
    	mov dl,[char] 
	    call addCharToFinal
	    
	    add  [loopTimes1],8 
	    add  [last],8
	    
	dec [length1]
	cmp [length1],0
	jne L8
	; 
	
	
ret
endp decrypt
;/////////////////////////////////////////////////
proc addCharToFinal
; add char to dl
push dx
push si
push ax

	mov si,offset final
	mov al,[finalLength]
	mov ah,0
	add si,ax
	
	mov [si],dl
	add [finalLength],1
	add si,1
	;mov dl,'$'
	;mov [si],dl

pop ax	
pop si
pop dx	

ret
endp addCharToFinal
;/////////////////////////////////////////////////
proc createFile

 mov dx, offset fileName
 mov cx, 0
 mov ah, 3Ch
 int 21h

ret 
endp createFile
;///////////////////////////////////
proc openFile
	; Open file
	mov ah, 3Dh
	mov al, 1
	lea dx, [fileName]
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
	
	openerror:
		mov dx, offset ErrorMsg
		mov ah, 9h
		int 21h
		ret
endp openFile
;///////////////////////////////////
proc writeToFile
	mov ah,40h
	mov bx, [filehandle]
	mov cx,18;length of string to write
	mov dx,offset final
	int 21h
ret
endp writeToFile
;//////////////////////////////////
proc loadFile

	;open file
	mov ah, 3Dh
	mov al, 0
	lea dx, [fileName1]
	int 21h
	jc openerror1
	mov [filehandle1], ax
	
	openerror1:
		mov dx, offset ErrorMsg
		mov ah, 9h
		;int 21h
	
	;read file
	mov ah,3Fh
	mov bx, [filehandle1]
	mov cx,12
	mov dx,offset text
	int 21h
	
	;close file
	mov ah,3Eh
	mov bx, [filehandle1]
	int 21h
	
	;print the file value
	call lineDown
	mov dx, offset msg10
	mov ah, 9h
	int 21h
	
	mov dx, offset text
	mov ah, 9h
	int 21h

ret
endp loadFile
;/////////////////////////////
proc closeFile
mov ah,3Eh
mov bx, [filehandle]
int 21h
ret
endp closeFile
;//////////////////////////////////
start:
	mov ax,@data
	mov ds,ax
	
	
	call graphic
	call reset
	
	;print massage6
	call lineDown
	mov ah,09          
	mov dx,offset msg6        
	int 21h
	
	;file
	call lineDown
	mov ah, 0ah 
    mov dx, offset helper
    int 21h
	call newLine

	mov si,offset helper
	mov di,offset fileName
	add si,2
	

	gogo:	
		mov al,[si]
		mov [di],al
		add si,1
		add di,1
		
		mov al,[si]	
		cmp al,0DH
		jne gogo
	
	
	;print massage1
	call lineDown
	mov ah,09          
	mov dx,offset msg1        
	int 21h

	;print massage2
	call lineDown
	mov ah,09          
	mov dx,offset msg2        
	int 21h

	;print massage3
	call lineDown
	mov ah,09          
	mov dx,offset msg3        
	int 21h
	
	;print massage9
	call lineDown
	mov ah,09          
	mov dx,offset msg9
	int 21h

	;input
	call lineDown
	mov ah,1
	int 21h
	
	;call
	sub al,30h

	cmp al,1
		je callEncrypt
	cmp al,2
		je callDecrypt
	cmp al,3
		je callLoadFile

		
	jmp wrongInput

	callEncrypt:
		call inputString ;imput massage
		call encrypt
	jmp overCall

	callDecrypt:
		call inputString ;imput massage
		call decrypt
	jmp overCall
	
	callLoadFile:
		call loadFile
		
		mov [boolLoad],1
		
		;print massage1
		call lineDown
		mov ah,09          
		mov dx,offset msg1        
		int 21h
	
		;print massage2
		call lineDown
		mov ah,09          
		mov dx,offset msg2        
		int 21h
		
		;print massage3
		call lineDown
		mov ah,09          
		mov dx,offset msg3        
		int 21h
		
		;input
		call lineDown
		mov ah,1
		int 21h
	
		;call
		sub al,30h

		cmp al,1
			je callEncrypt1
		cmp al,2
			je callDecrypt1
		
		callEncrypt1:
			call encrypt
		jmp overCall

		callDecrypt1:
			call decrypt
		jmp overCall
	
		
	jmp overCall

	wrongInput:
		call lineDown
		mov ah,09          
		mov dx,offset msg4        
		int 21h

	overCall:
	;print massage6
	call lineDown
	mov ah,09          
	mov dx,offset final       
	int 21h
	
		call createFile
		call openFile
		call writeToFile
		call closeFile
	call lineDown
	
	;print massage8
	call lineDown
	mov ah,09          
	mov dx,offset msg8        
	int 21h
	
	;get yes or no
	call lineDown
	mov ah,1
	int 21h
	
	cmp al,'y'
	je reset3
	cmp al,'n'
	je exit
	
	reset3:
	call reset2
	jmp start
	
exit:
;bp
call lineDown
push 1
call exitProgram

;out
call lineDown
mov  ax, 4c00h
int 21h

END start






