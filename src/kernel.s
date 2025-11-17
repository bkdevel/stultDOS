%define ENDL 0x0D, 0x0A


bits 16


org 0x0


_start:

	mov si, hello
	call puts
	
	mov [boot_drive_int], dl
	
	; printing boot drive
	mov si, boot_drive_msg
	call puts
	mov ax, [boot_drive_int]
	mov cx, 2
	mov di, boot_drive_str
	call hextostr
	mov si, boot_drive_str
	call puts

	mov si, endl
	call puts

	jmp get_fat_params


;
;; get FAT12-Params from bootsector
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

;
;; get_fat_params: get the above params from bootsector
;
;; int 0x13,2: https://www.stanislavs.org/helppc/int_13-2.html
;
get_fat_params:
	
	mov si, fat_params_msg_loading
	call puts

	mov ah, 0x2
	mov al, 1
	mov ch, 0
	mov cl, 0
	mov dh, 0 
	mov dl, [boot_drive]
	mov bx, buf
	mov ax, buf		; can't set es directly
	mov es, ax
	int 0x13		; error => CF set
	jc read_err

	mov si, buf

	mov ax, [si + 0xB]
	mov [bytes_per_sector], ax

	mov ax, [si + 0xE]
	mov [reserved_sector_count], ax
	
	mov ax, [si + 0x16]
	mov [sectors_per_fat], ax

	mov al, [si + 0xD]
	mov [bytes_per_sector], al
	
	mov al, [si + 0x10]
	mov [sectors_per_fat], al

	mov si, fat_params_msg_done
	call puts 


halt:

	mov si, halt_msg
	call puts

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
	
	.hextostr_loop:		
		mov dl, bl
		and dl, 0xF
		
		cmp dl, 9
		jbe .hextostr_end	
		add dl, 7	

	.hextostr_end:
		add dl, "0"

		mov [di], dl
		inc di
		loop .hextostr_loop
		
		mov byte [di], 0	; null terminator
		
		pop dx
		pop cx
		pop bx
		pop ax

		ret


;
;; puts: puts a string too the screen
;; Arguments: ds:si str*
;
puts:
	
	push si
	push ax
	push bx
	
	.loop:
		lodsb		; load next char in al
		or al, al
		jz .done
		
		mov ah, 0xE
		mov bh, 0x0
		int 0x10
	
		jmp .loop
	
	.done:
		pop bx
		pop ax
		pop si
		ret


read_err:

	mov di, read_err_msg
	call puts

	mov di, boot_drive_str
	call puts

	mov di, endl
	call puts

	jmp halt


boot_drive:				db 0x0
bytes_per_sector: 		dw 0
sectors_per_cluster:	db 0
reserved_sector_count:	dw 0
fat_count:				db 0
sectors_per_fat:		dw 0
fat_params_msg_loading:	db "Saving FAT-Params... ", 0
fat_params_msg_done:	db "[done]", ENDL, 0

endl:					db ENDL, 0
hello: 					db "Hello Kernel!", ENDL, 0

halt_msg:				db "Halting kernel...", 0

read_err_msg:			db "ERROR::could not read disk:", 0 

boot_drive_int: 		db 0
boot_drive_str:			db 2 dup (0)
boot_drive_msg:			db "Boot drive is: ", 0

buf: