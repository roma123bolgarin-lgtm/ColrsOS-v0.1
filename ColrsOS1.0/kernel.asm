bits 16
org 0x1000        ; ТЕПЕР ВІДПОВІДАЄ АДРЕСІ ЗАВАНТАЖЕННЯ

start:
    cli
    xor ax, ax
    mov ds, ax    ; Налаштовуємо сегменти на 0
    mov es, ax
    mov ss, ax
    mov sp, 0x9C00 ; Стек у безпечній зоні
    sti

    call cls

    mov si, logo
    call print

menu_loop:
    mov si, menu
    call print

    mov di, buffer
    call read_line

    ; Перевірка команд
    mov si, buffer
    mov di, cmd_start
    call strcmp
    cmp ax,1
    je start_cmd

    mov si, buffer
    mov di, cmd_help
    call strcmp
    cmp ax,1
    je help_cmd

    mov si, buffer
    mov di, cmd_exit
    call strcmp
    cmp ax,1
    je reboot

    mov si, buffer
    mov di, cmd_echo
    call strcmp
    cmp ax,1
    je echo_cmd

    mov si, buffer
    mov di, cmd_info
    call strcmp
    cmp ax,1
    je sysinfo_cmd

    mov si, buffer
    mov di, cmd_color
    call strcmp
    cmp ax,1
    je color_cmd

    ; Якщо нічого не підійшло
    mov si, unknown
    call print
    jmp menu_loop

; ===== COMMANDS =====
start_cmd:
    mov si, startmsg
    call print
    jmp menu_loop

help_cmd:
    mov si, helpmsg
    call print
    jmp menu_loop

echo_cmd:
    mov si, echomsg
    call print
    mov di, buffer
    call read_line
    mov si, buffer
    call print
    ; Додамо перенос рядка після echo
    mov ah, 0x0E
    mov al, 13
    int 10h
    mov al, 10
    int 10h
    jmp menu_loop

sysinfo_cmd:
    mov si, sysinfomsg
    call print
    jmp menu_loop

color_cmd:
    mov si, colormsg    ; Завантажуємо адресу рядка, який ми створимо нижче
    call print
    jmp menu_loop

reboot:
    int 19h

; ===== FUNCTIONS =====
print:
.next:
    lodsb
    cmp al,0
    je .done
    mov ah,0x0E
    int 10h
    jmp .next
.done:
    ret

cls:
    mov ax,0003h
    int 10h
    ret

read_line:
.read:
    mov ah,0
    int 16h
    cmp al,13
    je .done
    mov ah,0Eh
    int 10h
    stosb
    jmp .read
.done:
    mov al,0
    stosb
    mov ah,0Eh
    mov al,13
    int 10h
    mov al,10
    int 10h
    ret

strcmp:
.loop:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne .no
    cmp al,0
    je .yes
    inc si
    inc di
    jmp .loop
.yes:
    mov ax,1
    ret
.no:
    xor ax,ax
    ret

; ===== DATA =====
logo db 13,10,"=======ColrsOS Menu=======",13,10,0
menu db 13,10,"Commands: start, help, exit, echo, sysinfo and color",13,10,"> ",0
unknown db "Unknown command!",13,10,0
startmsg db "Starting system services...",13,10,0
helpmsg db "Available: start, help, exit, echo, sysinfo, color",13,10,0
echomsg db "Enter text: ",0
sysinfomsg db "ColrsOS v0.1 (x86 16-bit)",13,10,0
colormsg db "Color command will appear in v0.2", 13, 10, 0

cmd_start db "start",0
cmd_help db "help",0
cmd_exit db "exit",0
cmd_echo db "echo",0
cmd_info db "sysinfo",0
cmd_color db "color",0

buffer times 64 db 0