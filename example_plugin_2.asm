
        ; Пример 2, спавн случайного предмета в рюкзак игрокам

        ; ===================
        ; XRAY PROJECT API
        ; ===================
        format PE GUI 4.0 DLL
        include 'win32ax.inc'
        include 'kglobals.inc'
        include 'macro.inc'
        include 'xrproc.inc'


section '.code' code readable writable executable
main:
        mov    eax,[DllEntryPoint]
;*******************************************************************************

;*******************************************************************************
proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
iglobal
        ipThreadId dd 0
endg
        mov eax, [fdwReason]
.if eax = DLL_PROCESS_ATTACH

        stdcall API_Init
        invoke CreateThread,0,0x100000,CreateObject_Thread,NULL,0,ipThreadId
.endif
        mov eax,TRUE
        ret
endp
;*******************************************************************************

;*******************************************************************************
proc CreateObject_Thread
iglobal
        thread_start db '- create spawn thread',0
endg
        pushad
        invoke Sleep,15000
        cinvoke xrCore.msg,thread_start
.packet_loop:
        stdcall [GetClientByNum],0
        or  eax,eax
        je  .send_packet_finish
        cmp byte[eax+CLIENTCLASS.wHour],0
        jne .send_packet
        cmp byte[eax+CLIENTCLASS.wMinute],0
        je  .send_packet_finish
.send_packet:
        stdcall GetRandomStringPtr
        mov esi, eax
        stdcall [GetClientCount]
        mov  ecx,eax
.get_client_by_num:
        dec  ecx
        stdcall [GetClientByNum],ecx
        or   eax, eax
        je   .send_packet_finish
        stdcall [SpawnObjectClient],eax,esi ; eax - pClass, esi - pSection
        jmp .get_client_by_num
.send_packet_finish:
        stdcall [GetRandomNumber],10,100  ; рандомное число задержки
        imul eax,eax,1000
        invoke Sleep,eax
        jmp .packet_loop
.send_ret:
        popad
        ret
endp
;*******************************************************************************

;*******************************************************************************
proc GetRandomStringPtr
iglobal
        object_0      db 'mp_medkit',0
        object_1      db 'medkit_army',0
        object_2      db 'medkit_scientic',0

        array            dd object_0, object_1, object_2
        ; ----------------------------------------------------------------------
        size_table       = $-array
        ; -------------------------
endg
        push esi edi ebx ecx edx
        mov  eax, size_table
        shr  eax, 2
        dec  eax
        stdcall [GetRandomNumber],0,eax
        mov  eax,[array+eax*4]
        pop  edx ecx ebx edi esi
        ret
endp
;*******************************************************************************

;*******************************************************************************
.end main
IncludeAllGlobals
section '.reloc' fixups data writable discardable
;*******************************************************************************