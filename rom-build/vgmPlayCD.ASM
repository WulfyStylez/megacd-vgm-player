; ----------------------------------------
; MEGA CD VGM PLAYER V0.97
; Based on MEGA DRIVE VGM PLAYER V3.30 by Dead Fish Software
; (http://mjsstuf.x10host.com/pages/vgmPlay/vgmPlay.htm)
; ported and modified by WulfyStylez, 2k17
; ----------------------------------------

PBASE =     $200000 ; program base (Word RAM)
RBASE =     $FF1000 ; ram base (safe area for megacd)

    ORG PBASE
    ; layer our changes over the base (at the moment partially modified) ROM
START:
    incbin 'vgmPlayCD.bin'
    
    ; jump to actual ROM start from what was the header
    ORG PBASE
    bra (PBASE+$200)
    
    ; banner name, max 33 characters!
    ORG (PBASE+$10D8) 
    dc.b 'MEGA CD VGM PLAYER V0.97x',0xD, 0xA, 0
    
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
    
vblank_handler:
    jsr $360    ; sendInt2ToSubCpu, otherwise cd bios calls will freeze at vblank
    rte
    
exit: ; cleanup and return to ipl
    jmp $FF0584 ; jump back to sega loader

    ; code to run immediately after starting
    ORG (PBASE+$200)
    ; setup vblank
    lea.l vblank_handler(pc), a1
    jsr $368 ; set vblank addr
    

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