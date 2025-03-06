
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
        invoke timeSetEvent,1000,0x1000000,ActorUpdate_Timer,NULL,1       
.endif
        mov eax,TRUE
        ret
endp
;*******************************************************************************

;*******************************************************************************
proc ActorUpdate_Timer,uTimerID,uMsg,dwUser,dw1,dww
iglobal
        actor_found_position db '-- Player: %s - on point: X:%3.2f, Y:%3.2f, Z:%3.2f',0

        posx                 dq ?
        posy                 dq ?
        posz                 dq ?

        check_map_point_x    dd -211.46           ; Вход в подземелье, на кордоне. На пороге.
        check_map_point_y    dd -18.02
        check_map_point_z    dd -136.91

        medkit_scientic      db 'medkit_scientic',0
endg
        pushad

.actor_loop_start:
        xor esi,esi
        dec esi

.actor_next:
        inc esi
        stdcall [GetClientByNum],esi
        or  eax,eax
        je  .send_ret
        mov edi,eax
                   cmp byte[edi+CLIENTCLASS.wHour],0
                   jne .actor_get_pos_t
                   cmp byte[edi+CLIENTCLASS.wMinute],0
                   je  .send_ret
.actor_get_pos_t:
                   stdcall GetDistancePoint,edi,[check_map_point_x],[check_map_point_y],[check_map_point_z]
                   or  eax, eax
                   jne .actor_next

                   ; Игрок находится в заданной позиции.

                   movss xmm0, dword[check_map_point_x]
                   cvtss2sd xmm0,xmm0
                   movsd [posx],xmm0

                   movss xmm0, dword[check_map_point_y]
                   cvtss2sd xmm0,xmm0
                   movsd [posy],xmm0

                   movss xmm0, dword[check_map_point_z]
                   cvtss2sd xmm0,xmm0
                   movsd [posz],xmm0

                   ; Вывод в консоль и тд.

                   cinvoke xrCore.msg,actor_found_position,[edi+CLIENTCLASS.addr_player_name],dword[posx],dword[posx+4],dword[posy],dword[posy+4],dword[posz],dword[posx+4]

                   ; Выдать аптечку
                   stdcall [SpawnObjectClient],edi,medkit_scientic    ; edi = CLIENT

        jmp .actor_next

.send_ret:
        popad
        ret
endp
;*******************************************************************************

;*******************************************************************************
proc GetDistancePoint, pClass, PointPosX, PointPosY, PointPosZ
iglobal
        actor_max_offset_for_point    dd 2.00   ; максимальное смещение от центра заданных координат
        actor_min_offset_for_point    dd 4.00   ; actor_min_offset_for_point = actor_max_offset_for_point*2
endg
        push  ebx ecx edx esi edi
        mov   edi,[pClass]
.get_y:
        movss xmm0, dword[PointPosY]
        movss xmm1, [actor_max_offset_for_point]
        addps xmm0, xmm1
        comiss xmm0,dword[edi+CLIENTCLASS.actor_pos_y]
        jb    .distance_bag
        movss xmm1, [actor_min_offset_for_point]
        subps xmm0, xmm1
        comiss xmm0,dword[edi+CLIENTCLASS.actor_pos_y]
        ja    .distance_bag
.get_z:
        movss xmm0, dword[PointPosZ]
        movss xmm1, [actor_max_offset_for_point]
        addps xmm0, xmm1
        comiss xmm0,dword[edi+CLIENTCLASS.actor_pos_z]
        jb    .distance_bag
        movss xmm1, [actor_min_offset_for_point]
        subps xmm0, xmm1
        comiss xmm0,dword[edi+CLIENTCLASS.actor_pos_z]
        ja    .distance_bag
.get_x:
        movss xmm0, dword[PointPosX]
        movss xmm1, [actor_max_offset_for_point]
        addps xmm0, xmm1
        comiss xmm0,dword[edi+CLIENTCLASS.actor_pos_x]
        jb    .distance_bag
        movss xmm1, [actor_min_offset_for_point]
        subps xmm0, xmm1
        comiss xmm0,dword[edi+CLIENTCLASS.actor_pos_x]
        ja    .distance_bag
.distance_ok:
        xor   eax, eax
        jmp   .distance_ret
.distance_bag:
        mov   eax, 1
.distance_ret:
        pop   edi esi edx ecx ebx
        ret
endp
;*******************************************************************************

;*******************************************************************************
.end main
IncludeAllGlobals
section '.reloc' fixups data writable discardable
;*******************************************************************************
