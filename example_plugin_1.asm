
        ; example plugin #1, send random message.
        ; out - example_msg.dll -> rename to -> example_msg.plugin


        format PE GUI 4.0 DLL
        include 'win32ax.inc'
        include 'xray_api_proc.inc'


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
        invoke timeSetEvent,60000,0x1000000,Timer_RandomChatMessage,NULL,1
        invoke DisableThreadLibraryCalls, [hinstDLL]
.endif
        mov eax,TRUE
        ret
endp
;*******************************************************************************

;*******************************************************************************
proc Timer_RandomChatMessage,uTimerID,uMsg,dwUser,dw1,dww
        push  esi edi ebx ecx edx
        stdcall [GetLocalClient]
        or eax,eax
        je  .send_to_ret
.send_msg:
                stdcall [GetClientCount]
                mov ecx,eax
                stdcall GetRandomStringPtr
                mov esi,eax

.send_to_msg_by_id:
        dec  ecx
        stdcall [GetClientByNum],ecx
        or   eax, eax
        je   .send_to_ret
        xchg edi, eax
        stdcall [CopyPacket],Buff,esi
        stdcall [SendTo],Buff,eax,dword[edi+CLIENTCLASS.ID]
        jmp .send_to_msg_by_id

.send_to_ret:
        pop  edx ecx ebx edi esi
        ret
endp
;*******************************************************************************

;*******************************************************************************
proc GetRandomStringPtr    ; для добавления новых, строго следуйте образцу, если не имеете понятия принцип работы!
iglobal
        message_000      db '%c[1,0,255,0] message example 1',0
        message_001      db '%c[1,0,255,50] message example 2',0
        message_002      db '%c[1,0,255,110] message example 3',0

        array            dd message_000, message_001,\
                            message_002
        ; ----------------------------------------------------------------------
        ; -------------------------
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