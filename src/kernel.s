%define ENDL 0x0D, 0x0A


bits 16


global _start
global _puts

extern _kmain


boot_drive:	db 0x0


_start:

	; store boot drive number
	mov [boot_drive], dl
	
	mov si, boot_drive_msg
	push si
	call _puts
	add sp, 2		; clean up stack from _puts

	; printing boot drive
	mov ax, [boot_drive]
	mov cx, 2
	call _puthex
	mov si, endl
	push si
	call _puts
	add sp, 2		; clean up stack from _puts

	mov si, kmain_msg
	push si
	call _puts
	add sp, 2		; clean up stack from _puts
	
	; call kernel main
	call _kmain


error_halt:

	mov si, error_halt_msg
	call _puts

	cli
	hlt

;
;; itostr: converts an integer to a string
;; 	Arguments: ax: unsigned hexadecimal int; cx: number of bytes to convert (excluding null terminator); di: pointer to output buffer
;;	Returns: di points to to 1st byte of string
;
hextostr:
    push ax
    push bx
    push cx
    push dx

    mov bx, ax
	
	.loop:
    	mov dl, bl
    	and dl, 0xF
    	cmp dl, 9
    	jbe .skip
    	add dl, 7

	.skip:
    	add dl, '0'
    	mov [di], dl
    	inc di
    	shr bx, 4
    	loop .loop

    	mov byte [di], 0
    	pop dx
    	pop cx
    	pop bx
    	pop ax
    	ret



;
;; puts: puts a string too the screen
;; Arguments: str* on stack
;
_puts:
	
	push bp
	mov bp, sp
	push si
	push ax
	push bx

	mov si, [bp+4]	; get string pointer from stack
	
	.loop:
		lodsb		; load next char in al
		or al, al
		jz .done
		
		cmp al, 0xA	; is it newline?
		jne .putc
		mov al, 0xD	; convert to carriage return + line feed
		mov ah, 0xE
		mov bh, 0x0
		int 0x10

		mov al, 0xA
		mov ah, 0xE
		mov bh, 0x0
		int 0x10

		jmp .loop

		.putc:
			mov ah, 0xE
			mov bh, 0x0
			int 0x10
	
			jmp .loop
	
	.done:
		pop bx
		pop ax
		pop si
		pop bp
		ret

;
;; puthex: prints hexadecimal value in ax to screen
;; Arguments: ax: value to print; cx: number of bytes to print (excluding null terminator)
;
_puthex:
	push ax
	push cx
	
	mov di, buf
	call hextostr
	
	mov si, buf
	push si
	call _puts
	add sp, 2		; clean up stack from _puts

	mov si, space
	push si
	call _puts
	add sp, 2		; clean up stack from _puts

	pop cx
	pop ax
	ret


;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Information					-	offset				-	size 		;
;; Bytes per sector				-	0xB					- 	uint16_t	;
;; Sectors per cluster			-	0xD					-	uint8_t		;
;; Number of Reserved sectors 	-	0xE					-	uint16_t	;
;; Number of FATs				-	0x10				-	uint8_t		;
;; Sectors per FAT				-	0x16				-	uint16_t	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; why read them from bootsector if we know their values in advance?
;bytes_per_sector:       dw 512
;sectors_per_cluster:    db 1
;reserved_sectors:       dw 1
;fat_count:              db 2
;sectors_per_fat:        dw 9

endl:					db ENDL, 0
space:					db " ", 0

error_halt_msg:			db "A fatal error occurred. Halting.", ENDL, 0

boot_drive_msg:			db "Boot drive is: ", 0

kmain_msg:				db "Entering kernel main...", 0

buf:					resb 9		; buffer for hextostr (8 digits + null terminator)