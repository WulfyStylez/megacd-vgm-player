; ----------------------------------------
; MEGA CD VGM PLAYER V0.99
; Based on MEGA DRIVE VGM PLAYER V3.30 by Dead Fish Software
; (http://mjsstuf.x10host.com/pages/vgmPlay/vgmPlay.htm)
; ported and further modified by WulfyStylez, 2k17
; ----------------------------------------

align macro
     cnop 0,\1
     endm
PBASE =     $200000 ; program base

    ORG PBASE
INIT:
    bra skip_header
    
    ORG (PBASE + 8)
    dc.l 0, vgm_data
skip_header:
    ; copy our program out to PBASE (if needed) and jump to PBASE+$40
    move.l #PBASE, d3
    cmpi.l #$200000, d3
    beq start_jumpout
    ; copy from word ram to 68k ram, up to memory CD BIOS needs
    if (PBASE > $feffff)
        move #((($FFFD00-PBASE)>>2)-1), d3
    else
        move #$4000, d3
    endif
	movea.l	#$200000, a4
	movea.l	#PBASE, a5
copyout_loop:
	move.l	(a4)+, (a5)+
	dbf	d3, copyout_loop
    
start_jumpout:
    movea.l #(PBASE + $40), a1 ;dst
    jmp (a1)

    ORG (PBASE+$40)
START:
    ; setup vblank
    lea vblank_handler(pc), a1
    jsr $368 ; set vblank addr
    
    ; init VDP, font, and palette
    jsr $2AC ; loadDefaultVdpRegs (screen will be disabled)
    jsr $2A0 ; clearAllVram
	; load palette
    lea $C00000, a1
    move.w  #$8F02,4(a1) ; auto-inc set to 2
	move.l #$C0000003, 4(a1) ; write to cram + 0
	move.w #0, (a1)     ; color 0: black
	move.w #$EEE, (a1)  ; color 1: white
	jsr $328    ; CD BIOS: loadDefaultFontAndAddress
    
    bsr load_logo_tiles ; load rom-internal tilemap
    
    bsr	draw_text_and_logo
    move.w  #$8174,($C00004).l ; enable display!
    
    move.w	#$100,($A11100).l   ; Z80 busreq
    move.w	#$100,($A11200).l   ; pull Z80 out of reset
    move.b	#$40,($A10003).l    ; init joypads    
    move.b	#$40,($A10009).l
    
    ; init vgm player vars
    move.b	#$80,(byte_2001F0).l
    move.w	#1,(current_track).l
    clr.w	(word_2001F8).l
    bra	main_loop

; load original logo graphics to vram + $2000
load_logo_tiles:
		movem.w	d0-d4/a0,-(sp)
		move.w	#$8F02,($C00004).l
		move.l	#$60000000,($C00004).l  ; write to VRAM + 0x2000
		moveq	#1,d4
        
        subi #$300, sp  ; space for 3 lines of 1bpp tiles
		lea	logo_tiles_1bpp_nemesis(pc),a1
        move sp, a2
        jsr $2F0    ; CD BIOS: nemesis_decompress_to_ram(void* in, void* out)
        
        move sp, a0
		move.w	#$2FF,d0

loc_2002F8:
		move.b	(a0)+,d2
		clr.l	d3
		moveq	#7,d1

loc_2002FE:
		ror.l	#4,d4
		btst	d1,d2
		beq	loc_200308
		or.l	d4,d3

loc_200308:
		dbf	d1,loc_2002FE
		move.l	d3,($C00000).l
		dbf	d0,loc_2002F8
        
        addi #$300, sp
		movem.w	(sp)+,d0-d4/a0
		rts

draw_graphic:
		movea.l	#$C00000,a1
		lsl.w	#1,d1
		lsl.w	#7,d2
		add.w	d2,d1
		ori.w	#$4000,d1
		swap	d1
		move.w	#3,d1

loc_200E32:
		move.l	d1,4(a1)
		swap	d1
		addi.w	#$80,d1
		swap	d1
		move.w	d4,d2

loc_200E40:
		move.w	d0,(a1)
		addq	#1,d0
		subq	#1,d2
		bne	loc_200E40
		subq	#1,d3
		bne	loc_200E32
		rts
        
        
draw_font:
		movea.l	#$C00000,a1
		move.w	(word_2001F2).l,d0
		move.w	(word_2001F4).l,d1
		lsl.w	#6,d1
		add.w	d0,d1
		lsl.w	#1,d1
		addi.w	#$4000,d1
		swap	d1
		move.w	#3,d1
		move.l	d1,4(a1)
		moveq	#0,d2

loc_200E76:
		move.b	(a0)+,d2
		beq	loc_200EC8
		cmpi.b	#$C,d2
		beq	loc_200E9A
		cmpi.b	#$D,d2
		beq	loc_200EA8
		addq	#1,d0
		cmpi.w	#$28,d0
		bcc	loc_200E94
		move.w	d2,(a1)
		bra	loc_200E76

loc_200E94:
		suba.w	#1,a0
		bra	loc_200EAA

loc_200E9A:
		move.w	#0,(a1)
		addq	#1,d0
		cmpi.w	#$28,d0
		bcs.s	loc_200E9A
		bra	loc_200EAA

loc_200EA8:
		move.b	(a0)+,d2

loc_200EAA:
		addq	#1,(word_2001F4).l
		move.b	d4,d0
		moveq	#0,d0
		swap	d1
		andi	#$FF80,d1
		addi.w	#$80,d1
		swap	d1
		move.l	d1,4(a1)
		bra	loc_200E76

loc_200EC8:
		move.w	d0,(word_2001F2).l
		rts
        

sub_200ED0:
		movem.l	d0-d4/a1,-(sp)
		movea.l	#$C00000,a1
		move.w	(word_2001F2).l,d0
		move.w	(word_2001F4).l,d1
		move.w	d0,d2
		move.w	d1,d3
		lsl.w	#6,d1
		add.w	d0,d1
		lsl.w	#1,d1
		addi.w	#$4000,d1
		swap	d1
		move.w	#3,d1

loc_200EFA:
		move.l	d1,4(a1)

loc_200EFE:
		move.w	#0,(a1)
		addq	#1,d2
		cmpi.b	#$28,d2
		bcs.s	loc_200EFE
		addq	#1,d3
		cmpi.b	#$1C,d3
		bcc	loc_200F22
		moveq	#0,d2
		andi.l	#$FF80FFFF,d1
		addi.l	#$800000,d1
		bra	loc_200EFA

loc_200F22:
		movem.l	(sp)+,d0-d4/a1
		rts
        

vblank_handler:
		jsr	$360
		rte

sub_200F50:
		link	a3,#-$100
		movem.l	d0-d3/a1,-(sp)
		moveq	#0,d3
		bsr	draw_font
		movem.l	(sp)+,d0-d3/a1
		moveq	#0,d2
		moveq	#7,d4
		movea.l	sp,a2
		move.w	#$FA,d0

loc_200F6E:
		move.b	(a1)+,d5
		move.b	(a1)+,d1
		lsl.w	#8,d1
		move.b	d5,d1
		tst.w	d1
		beq	loc_200FD4
		tst.w	d0
		beq	loc_200F6E
		subq	#1,d0
		addq	#1,d4
		cmpi.b	#$D,d1
		bne	loc_200F8E
		move.b	(a1)+,d1
		move.b	(a1)+,d1
		bra	loc_200FB2

loc_200F8E:
		cmpi.w	#$28,d4
		beq	loc_200FA4
		move.b	d1,(a2)+
		cmpi.b	#$20,d1
		bne	loc_200F6E
		move.l	a1,d2
		move.l	a2,d3
		bra	loc_200F6E

loc_200FA4:
		cmpi.b	#$20,d1
		beq	loc_200FB2
		tst.l	d2
		beq	loc_200FC2
		movea.l	d2,a1
		movea.l	d3,a2

loc_200FB2:
		move.b	#$C,(a2)+
		move.b	#$20,(a2)+
		moveq	#0,d2
		moveq	#1,d4
		bra	loc_200F6E

loc_200FC2:
		move.b	#$C,(a2)+
		move.b	#$20,(a2)+
		move.b	d1,(a2)+
		moveq	#0,d2
		moveq	#2,d4
		bra	loc_200F6E

loc_200FD4:
		move.b	#$C,(a2)+
		move.b	d1,(a2)+
		movea.l	sp,a2
		movem.l	d0-d3/a0-a1,-(sp)
		movea.l	a2,a0
		moveq	#1,d3
		bsr	draw_font
		movem.l	(sp)+,d0-d3/a0-a1
		unlk	a3
		rts

sub_200FF2:
		move.b	(a1)+,d5
		move.b	(a1)+,d1
		lsl.w	#8,d1
		move.b	d5,d1
		tst.w	d1
		bne	sub_200FF2
		rts
        
; used repeatedly in func for printing strings to screen
screen_print macro address
    movem.l d0-d3/a0-a1, -(sp)
    lea \address(pc), a0
    bsr draw_font
    movem.l (sp)+, d0-d3/a0-a1
    endm
        
print_gd3_info:
		move.w	#0,(word_2001F2).l
		move.w	d1,(word_2001F4).l
		move.b	(a0)+,d0
		lsl.w	#8,d0
		move.b	(a0)+,d0
		swap	d0
		move.b	(a0)+,d0
		lsl.w	#8,d0
		move.b	(a0)+,d0
		cmpi.l	#'Gd3 ',d0
		bne	loc_20105E
		movea.l	a0,a1
		adda.w	#8,a1
		lea	str_GD3Info(pc),a0
		bsr	sub_200F50
		bsr	sub_200FF2
		bsr	sub_200F50
		bsr	sub_200FF2
		bsr	sub_200FF2
		bsr	sub_200FF2
		bsr	sub_200F50
		bsr	sub_200FF2
		bsr	sub_200F50
		bsr	sub_200F50
		bsr	sub_200F50
		bra	loc_201066

loc_20105E:
		addq	#1,(word_2001F4).l
		move.b	d4,d0

loc_201066:
		bsr	sub_200ED0
		rts

str_GD3Info:	dc.b ' GD3 INFO',$D,$A
		dc.b $D,$A
		dc.b ' Track:',0
        dc.b ' Game :',0
        dc.b ' Auth.:',0
        dc.b ' Date :',0
        dc.b ' VgmBy:',0
        dc.b ' Notes:',0
		align 2


draw_text_and_logo:
    move.w	#1,(word_2001F2).l
    move.w	#1,(word_2001F4).l
    
    screen_print str_title
    screen_print str_newline
    
    ; only one song? don't print prev/next track text
    move.l (vgm_data, pc), d0
    cmpi.w #1, d0
    beq print_onetrack
    
    screen_print str_prev
    screen_print str_next
print_onetrack:
    screen_print str_return
    screen_print str_restart
    move #$100, d0
    move #$1B, d1
    move #1, d2
    move #8, d3
    move #$C, d4
    bsr draw_graphic
    rts
    
str_title: dc.b 'MEGA CD VGM PLAYER V0.99',$D, $A, 0
str_newline: dc.b $D, $A, 0
str_prev: dc.b " LEFT/UP  - Previous Track",$D, $A, 0
str_next: dc.b " RIGHT/DOWN - Next Track",$D, $A, 0
str_return: dc.b " B - Return",$D, $A, 0
str_restart: dc.b " C - Restart Track",$D, $A, 0

    align 2

loc_201204:
		subq	#1,d0
		bne	loc_201204
		rts

vgc_return_hdrerr:
		moveq	#1,d0

vgc_return:
		adda.l	#$24,sp
		rts

play_vgc:
		suba.l	#$24,sp
		cmpi.l	#'Vgc ',(a0)
		bne	vgc_return_hdrerr
		cmpi.l	#$100,4(a0)
		bne	vgc_return_hdrerr
		movea.l	$10(a0),a1
		adda.l	a0,a1
		movem.l	d0-d5/a0-a3,-(sp)
		move.w	#9,d1
		movea.l	a1,a0
		bsr	print_gd3_info
		movem.l	(sp)+,d0-d5/a0-a3
		moveq	#$FFFFFFFF,d0
		move.l	$C(a0),d1
		beq	loc_201252
		move.l	a0,d0
		add.l	d1,d0

loc_201252:
		move.l	d0,6(sp)
		adda.l	8(a0),a0
		move.l	(a0)+,d0
		beq	loc_201266
		movea.l	a0,a5
		move.l	a0,$E(sp)
		adda.l	d0,a0

loc_201266:
		movea.l	a0,a4
		move.l	(PBASE+$8),$A(sp)
		lea	byte_201286,a0
		lea	$12(sp),a1
		moveq	#$11,d0

loc_20127A:
		move.b	(a0)+,(a1)+
		dbf	d0,loc_20127A
		moveq	#0,d6
		bra	loc_20138A
byte_201286:	dc.b $9F, $BF, $DF, $FF, $9F, 0, 0, 0, 0, 0, 0,	0, 0, 0
		dc.b 0,	0, 0, $80


sub_201298:
		movea.l	#$A04000,a0
		adda.w	d0,a0

loc_2012A0:
		btst	#7,(a0)
		bne	loc_2012A0
		move.b	d1,(a0)+

loc_2012A8:
		btst	#7,(a0)
		bne	loc_2012A8
		move.b	d2,(a0)
		rts


loc_2012B2:
		move.b	d2,$23(sp)
		bra	loc_20137E

loc_2012BA:
		lea	$17(sp),a0
		move.b	d2,d1
		andi	#$F,d2
		cmpi.w	#4,d2
		bcs.s	loc_2012CC
		subq	#1,d2

loc_2012CC:
		or.b	d1,(a0,d2.w)
		addq	#6,d2
		move.b	d1,(a0,d2.w)
		bra	loc_20137E
        
loc_2012DA:
		move.b	(a4)+,d1
		move.b	(a4)+,d2
		cmpi.b	#$2A,d1
		beq	loc_2012B2
		cmpi.b	#$28,d1
		beq	loc_2012BA
		moveq	#0,d0
		bsr	sub_201298
		bra	loc_20137E
        
loc_2012F4:
		move.b	(a4)+,d1
		move.b	(a4)+,d2
		moveq	#2,d0
		bsr	sub_201298
		bra	loc_20137E
        
loc_201302:
		move.b	(a4)+,d0
		move.b	d0,d1
		bmi.s	loc_20130C
		move.b	$16(sp),d1

loc_20130C:
		move.b	d1,$16(sp)
		btst	#4,d1
		bne	loc_201320
		move.b	d0,($C00011).l
		bra	loc_20137E

loc_201320:
		andi	#$60,d1
		lsr.w	#5,d1
		move.b	d0,$12(sp,d1.w)
		bra	loc_20137E
        
loc_20132E:
		move.b	(a4)+,d0
		swap	d0
		move.b	(a4)+,d0
		lsl.w	#8,d0
		move.b	(a4)+,d0
		movea.l	$E(sp),a5
		adda.l	d0,a5
		bra	loc_20137E
        
loc_201342:
		move.b	(a5)+,$23(sp)
		bra	loc_20137E

loc_20134A:
		tst.b	0(sp)
		bne	loc_201358
		lsr.w	#1,d1
		adda.w	d1,a4
		bra	loc_20138A

loc_201358:
		suba.w	#1,a4
		bra	loc_2013C2
        
loc_201360:
		andi	#$F,d0
		beq	loc_20148E
		subq	#1,d0
		bne	loc_201372
		adda.w	#1,a4
		bra	loc_201384

loc_201372:
		subq	#3,d0
		bcc	loc_20148E
		moveq	#0,d1
		bra	loc_20134A

loc_20137E:
		move.w	2(sp),d0
		bne	loc_2013C2

loc_201384:
		move.w	#$FFFF,0(sp)

loc_20138A:
		move.b	(a4)+,d0
		move.b	d0,d1
		andi	#$F,d0
		move.w	d0,2(sp)
		andi	#$F0,d1
		lsr.w	#2,d1
        lea branches_1, a0
        movea.l	(a0,d1.w),a0
        jmp (a0)
branches_1:	dc.l loc_20134A, loc_20134A, loc_20134A, loc_2012DA, loc_2012F4,	loc_201302, loc_20132E, loc_20148E
		dc.l loc_20148E, loc_20148E, loc_20148E, loc_20148E, loc_20148E,	loc_20148E, loc_201342, loc_201360

loc_2013C2:
		moveq	#0,d0
		moveq	#$2A,d1
		move.b	$23(sp),d2
		bsr	sub_201298
		lea	$17(sp),a1
		moveq	#5,d0
		moveq	#$28,d1

loc_2013D6:
		move.b	(a1)+,d2
		beq	loc_2013E2
		swap	d0
		bsr	sub_201298
		swap	d0

loc_2013E2:
		dbf	d0,loc_2013D6
		lea	$17(sp),a1
		moveq	#5,d0

loc_2013EC:
		move.b	6(a1),d2
		cmp.b	(a1)+,d2
		beq	loc_2013FC
		swap	d0
		bsr	sub_201298
		swap	d0

loc_2013FC:
		dbf	d0,loc_2013EC
		lea	$12(sp),a0
		moveq	#4,d0

loc_201406:
		move.b	(a0)+,($C00011).l
		dbf	d0,loc_201406
		moveq	#0,d6
		lea	loc_2016C8,a6
		bra	loc_2016C8
loc_20141A:
		movea.l	#$A04000,a0
		move.b	(a4)+,(a0)+
		bra	loc_201436
loc_201424:
		movea.l	#$A04002,a0
		move.b	(a4)+,(a0)+
		bra	loc_201436
loc_20142E:
		movea.l	#$C00011,a0
		lsr.w	#8,d1

loc_201436:
		lsr.l	#7,d1
		move.b	(a4)+,(a0)
		lsr.l	#1,d1
		andi	#$F,d0
		bra	loc_2016C0
        
loc_201444:
		moveq	#0,d1
		move.b	(a4)+,d1
		swap	d1
		move.b	(a4)+,-(sp)
		move.w	(sp)+,d1
		move.b	(a4)+,d1
		movea.l	$E(sp),a5
		adda.l	d1,a5
		lsr.l	#1,d1
		andi	#$F,d0
		bra	loc_2016C0
        
loc_201460:
		andi	#$F,d0
		bne	loc_201482
		move.l	6(sp),d1
		bmi.s	loc_20147C
		movea.l	d1,a4
		subq	#1,$A(sp)
		beq	loc_20147C
		cmpa.l	a0,a0
		moveq	#0,d0
		bra	loc_2016C0

loc_20147C:
		moveq	#0,d0
		bra	vgc_return

loc_201482:
		subq	#1,d0
		beq	loc_201494
		subq	#1,d0
		beq	loc_2014AE
		subq	#1,d0
		beq	loc_2014B4

loc_20148E:
		moveq	#2,d0
		bra	vgc_return

loc_201494:
		moveq	#$D,d0
		lsr.l	d0,d0
		adda.w	#1,a4
		bra	loc_2016C0

loc_2014A0:
		lsr.w	#8,d1

loc_2014A4:
		lsr.l	#3,d1

loc_2014A6:
		lsr.l	#2,d1

loc_2014A8:
		lsr.w	#1,d1
		bra	loc_2016C0

loc_2014AE:
		move.w	#$2DF,d0
		bra	loc_2014A6

loc_2014B4:
		move.w	#$372,d0
		bra	loc_2014A8
loc_2014BA:
		andi	#$F,d0
		addq	#1,d0
		bra	loc_2014A0
loc_2014C2:
		moveq	#$F,d1
		and.w	d1,d0
		move.b	(a4)+,d1
		lsl.w	#4,d1
		or.w	d1,d0
		bra	loc_2014A4
loc_2014CE:
		move.b	(a4)+,d0
		lsl.w	#8,d0
		move.b	(a4)+,d0
		bra	loc_2014A4
loc_2014D6:
		movea.l	#$A04000,a0
		move.b	#$2A,(a0)+
		moveq	#$A,d1
		lsr.l	d1,d1
		move.b	(a5)+,(a0)
		lsr.l	#1,d1
		andi	#$F,d0
		bra	loc_2016C0
        
loc_2014F0:
		move.b	#$2A,($A04000).l
		andi	#$F,d0
		addq	#1,d0
		move.w	d0,0(sp)

loc_201504:
		move.b	(a5)+,($A04001).l
		lsr.w	#1,d0
		moveq	#$F,d0
		and.b	(a4),d0
		addq	#1,d7
		addq	#1,d6
		lea	loc_20151C,a6
		sub.w	d0,d6
		bcs.s	loc_20154C

loc_20151C:
		moveq	#$18,d0
		lsr.l	d0,d0
		move.b	(a4)+,d0
		lsr.w	#4,d0
		addq	#1,d7
		addq	#1,d6
		lea	loc_201536,a6
		move.b	(a5)+,($A04001).l
		sub.w	d0,d6
		bcs.s	loc_20154C

loc_201536:
		subq	#1,0(sp)
		bcc	loc_201542
		lea	loc_2016C8,a6
		jmp	(a6)

loc_201542:
		moveq	#$1F,d0
		lsr.l	d0,d0
		moveq	#$A,d0
		lsr.l	d0,d0
		bra	loc_201504

loc_20154C:
		bra	loc_20168C
loc_201550:
		movea.l	#$A04000,a0
		move.b	#$2A,(a0)+
		movea.l	sp,a1
		move.b	(a4)+,(a1)+
		move.b	(a4)+,d1
		move.b	d1,(a1)+
		move.b	(a5)+,(a0)
		andi	#$F,d0
		move.w	d0,(a1)
		andi	#3,d1
		add.w	d1,d0
		lea	loc_20157A,a6
		addq	#1,d6
		sub.w	d0,d6
		bcs.s	loc_2015B6

loc_20157A:
		addq	#1,d7
		move.b	1(sp),d0
		lsr.w	#2,d0
		moveq	#3,d1
		and.b	(sp),d1
		bne	loc_2015BA
		move.b	(a4)+,d0

loc_20158C:
		move.b	d0,1(sp)
		andi	#3,d0
		add.w	2(sp),d0
		lea	loc_2015A8,a6
		move.b	(a5)+,($A04001).l
		addq	#1,d6
		sub.w	d0,d6
		bcs.s	loc_2015B6

loc_2015A8:
		subq.b	#1,(sp)
		bne	loc_2015B2
		lea	loc_2016C8,a6
		jmp	(a6)

loc_2015B2:
		bra	loc_20157A

loc_2015B6:
		bra	loc_20168C

loc_2015BA:
		bra	loc_20158C

loc_2015BC:
		movea.l	#$A04000,a0
		move.b	#$2A,(a0)+
		movea.l	sp,a1
		move.b	(a4)+,(a1)+
		move.b	(a4)+,d1
		move.b	d1,(a1)+
		move.b	(a5)+,(a0)
		andi	#$F,d0
		move.w	d0,(a1)
		andi	#1,d1
		add.w	d1,d0
		lea	loc_2015E6,a6
		addq	#1,d6
		sub.w	d0,d6
		bcs.s	loc_201622

loc_2015E6:
		addq	#1,d7
		move.b	1(sp),d0
		lsr.l	#1,d0
		moveq	#7,d1
		and.b	(sp),d1
		bne	loc_201626
		move.b	(a4)+,d0

loc_2015F8:
		move.b	d0,1(sp)
		andi	#1,d0
		add.w	2(sp),d0
		lea	loc_201614,a6
		move.b	(a5)+,($A04001).l
		addq	#1,d6
		sub.w	d0,d6
		bcs.s	loc_201622

loc_201614:
		subq.b	#1,(sp)
		bne	loc_20161E
		lea	loc_2016C8,a6
		jmp	(a6)

loc_20161E:
		bra	loc_2015E6

loc_201622:
		bra	loc_20168C

loc_201626:
		bra	loc_2015F8
loc_201628:
		movea.l	#$A04000,a0
		move.b	#$2A,(a0)+
		move.b	(a4)+,(sp)
		moveq	#0,d1
		sub.b	(a4)+,d1
		andi	#$F,d0
		move.b	(a5)+,(a0)
		move.b	d1,1(sp)
		lsr.w	#1,d1
		lea	loc_201650,a6
		addq	#1,d7
		addq	#1,d6
		sub.w	d0,d6
		bcs.s	loc_201686

loc_201650:
		moveq	#$C,d1
		lsr.w	d1,d1
		moveq	#$F,d0
		and.b	-3(a4),d0
		move.b	-1(a4),d1
		sub.b	d1,1(sp)
		moveq	#0,d1
		addx.w	d1,d0
		lea	loc_201678,a6
		addq	#1,d7
		move.b	(a5)+,($A04001).l
		addq	#1,d6
		sub.w	d0,d6
		bcs.s	loc_201686

loc_201678:
		subq.b	#1,(sp)
		bne	loc_201682
		lea	loc_2016C8,a6
		jmp	(a6)

loc_201682:
		bra	loc_201650

loc_201686:
		bra	loc_20168C

loc_20168A:
		lsr.l	#1,d1

loc_20168C:
		add.w	d0,d6
		sub.w	d6,d0
		moveq	#0,d6
		bra	loc_201698

loc_201694:
		lsr.l	#8,d1
		lsr.l	#4,d1

loc_201698:
		move.b	($A10003).l,d1
		not.b	d1
		move.b	(byte_2001F0).l,d2
		move.b	d1,(byte_2001F0).l
		eor.b	d1,d2
		and.b	d2,d1
		bne	loc_2017F8
		addq	#1,d7
		moveq	#$E,d1
		lsr.l	d1,d1
		subq	#1,d0
		bne	loc_201694
		jmp	(a6)

loc_2016C0:
		addq	#1,d7
		addq	#1,d6
		sub.w	d0,d6
		bcs.s	loc_20168A

loc_2016C8:
		move.b	(a4)+,d0
		move.b	d0,d1
		andi	#$F0,d1
		lsr.w	#2,d1
        lea branches_2, a0
        movea.l	(a0,d1.w),a0
        jmp (a0)
branches_2:	dc.l loc_2014BA, loc_2014C2, loc_2014CE, loc_20141A, loc_201424,	loc_20142E, loc_201444, loc_20148E
		dc.l loc_20148E, loc_20148E, loc_201628, loc_2015BC, loc_201550,	loc_2014F0, loc_2014D6, loc_201460

; =====================================
;   END OF vgc_play
; =====================================

main_loop:
		lea	vgm_data(pc),a1

        ; HACK: vgmPlay.exe inserts offsets from rom+0 when creating vgc data.
        ; This will differ between builds, and I simply append binary data to
        ; vgcPlay.dat to test, so let's do some math to nullify these offsets.
        
		move.w	(current_track).l,d0
		lsl.w	#2,d0 
        movea.l	(a1,d0.w),a0    ; get target vgc offset from index of offsets
        move.l	4(a1),d1        ; get base offset of vgm data by looking at first entry
        suba.l d1, a0   ; a0 is now offset from end of entry table
        
        ; get size of entry table, add this to a0
        move.l (a1), d0
        addi #1, d0
        lsl #2, d0
        adda.l d0, a0
        
        ; add vgm_data offset, and we're good!
        adda.l a1, a0
        
		tst.w	(word_2001F8).l
		beq	loc_201768

		movea.l	(PBASE+$C),a0
		beq	loc_201768

loc_201758:
		bsr	sub_201832
		bne	loc_20180A
		moveq	#$16,d1
		lsr.l	d1,d1
		subq	#1,d0
		bne	loc_201758

loc_201768:
		move.w	#$FFFF,(word_2001F8).l
		bsr	play_vgc
		tst.b	d0
		bne	vgc_playback_err
		bsr	sub_201870
		bra	next_track
    
vgc_playback_err:
    subq #1, d0
    bne vgm_data_error
    screen_print str_badhdr
    bra vgm_error_loop

vgm_data_error:
    screen_print str_baddata
    
vgm_error_loop:
    bra vgm_error_loop
    
; these are printed before hanging. let's leave a blank line before and none after
str_badhdr: dc.b $D, $A, " Invalid VGM header!", 0
str_baddata: dc.b $D, $A, " VGM data error!",0

loc_2017F8:
		adda.l	#$28,sp
		bsr	sub_201870

loc_20180A:
		move.w	#0,(word_2001F8).l
		bsr	sub_20184C
		btst	#5,d1
		bne	main_loop
		moveq	#5,d0
		and.b	d1,d0
		bne	prev_track
		andi	#$A,d1
		bne	next_track
        
        ; b pressed, jump back to Sega Loader
		jmp $FF0584
jumpout_post_loop:
        bra jumpout_post_loop
        
next_track:
		lea	vgm_data,a0
		move.l	(a0),d1
		move.w	(current_track).l,d0
		addq	#1,d0
		cmp.w	d1,d0
		bls.s	set_current_track
		moveq	#1,d0
        bra set_current_track
prev_track:
		lea	vgm_data,a0
		move.l	(a0),d1
		move.w	(current_track).l,d0
		subq	#1,d0
		bne	set_current_track
		move.w	d1,d0

set_current_track:
		move.w	d0,(current_track).l
		bra	main_loop

; =====================================
;   END OF main_loop
; =====================================

sub_201832:
		move.b	($A10003).l,d1
		not.b	d1
		move.b	(byte_2001F0).l,d2
		move.b	d1,(byte_2001F0).l
		eor.b	d1,d2
		and.b	d2,d1
		rts

sub_20184C:
		move.l	#$1F33,d0

loc_201852:
		subq	#1,d0
		bne	loc_201852
		move.b	($A10003).l,d0
		not.b	d0
		andi.b	#$3F,d0
		bne	sub_20184C
		move.l	#$1F33,d0

loc_20186A:
		subq	#1,d0
		bne	loc_20186A
		rts

sub_201870:
		move.w	d1,-(sp)
		move.w	#0,($A11200).l
		moveq	#$1F,d0
		lsr.l	d0,d1
		lsr.l	d0,d1
		lsr.l	d0,d1
		move.w	#$100,($A11200).l
		movea.l	#$C00011,a0
		move.b	#$9F,(a0)
		move.b	#$BF,(a0)
		move.b	#$DF,(a0)
		move.b	#$FF,(a0)
		move.w	(sp)+,d1
		rts

byte_2001F0:	dc.b 0
		dc.b   0
word_2001F2:	dc.w 0
word_2001F4:	dc.w 0
current_track:	dc.w 0
word_2001F8:	dc.w 0

; decompressed size: $300
logo_tiles_1bpp_nemesis: 
    incbin resources/logo_tiles.nem

vgm_data:


		END
