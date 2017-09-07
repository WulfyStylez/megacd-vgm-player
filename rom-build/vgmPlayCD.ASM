; ----------------------------------------
; MEGA CD VGM PLAYER V0.80
; Based on MEGA DRIVE VGM PLAYER V3.30 by Dead Fish Software
; (http://mjsstuf.x10host.com/pages/vgmPlay/vgmPlay.htm)
; ----------------------------------------

PBASE =     $200000 ; program base (Word RAM)
RBASE =     $FF1000 ; ram base (safe area for megacd)

    ORG PBASE
START:
    incbin 'vgmPlayCD.bin'
    
    ; banner name, max 33 characters!
    ORG (PBASE+$10D8) 
    dc.b 'MEGA CD VGM PLAYER V0.95',0xD, 0xA, 0
    
    ORG (PBASE+$20)
    ; fix up 16-bit jump tables
jumpfix_1:
    lea (PBASE+$13A2), a0
    bra jumptables_shared

jumpfix_2:
    lea (PBASE+$16D8), a0
jumptables_shared:
    movea.w (a0,d1.w),a0
    add.l #PBASE, a0
    jmp (a0)
    
; add base offset to vgm address calculation
fix_vgm_addr: ; bsr here
    movea.l (a0,d0.w),a0
    add.l #PBASE, a0
    rts
    
exception_ret:
    rte
    
exit: ; cleanup and return to ipl
    jmp $ff0000 ; jump back to sega security ipl (slo is at $FF0584)

    ORG (PBASE+$200)
    ; set the h + v vectors from scd rom to a return
    lea ($fffd08), a0
    move.l #exception_ret, (a0)
    add #$6, a0
    move.l #exception_ret, (a0)
    

    ORG (PBASE+$139C)
    bra jumpfix_1
    ORG (PBASE+$16D2)
    bra jumpfix_2
    
    ORG (PBASE+$1744)
    bsr fix_vgm_addr
    
    ; jump back to loader on b press
    ORG (PBASE+$1804)
    bra exit

    END START