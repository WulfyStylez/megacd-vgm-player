
; some ez vdp macros
VDP_DATA	= $C00000
VDP_CONTROL = $C00004
	org	$FF0584
Start:
	; set up vblank routine to be cd bios compatible
	lea	VintBios(pc), a1
	jsr $368
	
	; do some cd bios calls before changing VBlank interrupt
	jsr $318 ; disable horizontal interrupts
	jsr $2AC ; loadDefaultVdpRegs
	jsr $2A0 ; clearAllVram
	jsr $328 ; loadDefaultFontAndAddress
	
	lea	Vint(pc), a1		;Load Address for VBL routine
	jsr $368		;make appropriate change in Interrupt Jump table

	move.b	#$40, $a10009	;set up I/O Port

	move.b	#0, $A1200E	;clear out Handshake
	
	bset	#1, $A12003	;give Sub CPU control of WordRAM

Wait:
	tst.b	$A1200F		;wait for SUB CPU to respond
	beq	Wait
	move.b	#1, $A1200E	;request file list
Wait2:
	tst.b	$A1200F		;wait for sub CPU to finish
	bne	Wait2

	move.l	#VDP_DATA, a2
	move.l	#VDP_CONTROL, a3

	move.w  #$8f02, (a3)	;set auto-increment to 2 to allow long writes
	
	; load palette
	lea Palette, a0
	move.l #31, d0  ; 32 words
	move.l #$C0000003, (a3) ; write to cram from address 0
palette_load_loop:
	move.l (a0)+, (a2)
	dbra d0, palette_load_loop


DisplayList:	

	move.w  #$8104, (a3)	;turn off display, VINTs

	bsr	ClearScreen

	movea.l	(Page), a0	;set a0 to beginning of file list page

	move.l	#$78000002, (a3)	;set up Pointer sprite

	move.w	(PointerPos), (a2)
	move.w	#$400, (a2)
	move.w	#$403D, (a2)
	move.w	#128, (a2)
	
	move.l  #$40040003,d1	;VDP Command word for beginning of Screen (well two spaces over anyway)
	move.l	#$00800000, d2	;delta between lines
	moveq	#$28, d3
	move.w	#$4000, d0	;choose pallete #2
	moveq	#$1A, d4

	lea	Title(pc), a4

	move.l	d1, (a3)
	moveq	#26, d5
DisplayTitle:
	move.b	(a4)+, d0
	move.w	d0, (a2)
	dbra	d5, DisplayTitle

	add.l	d2, d1
	add.l	d2, d1		;skip a line
	
DisplayName:
	move.l	d1, (a3)
	movea.l	a0, a1
CopyChar:
	move.b	(a1)+, d0
	beq	NextLine
	move.w	d0, (a2)
	bra	CopyChar

NextLine:
	add.l	d3, a0		;move to next filename
	add.l	d2, d1		;move to next line in VRAM
	sub.b	#1, d4
	beq	End
	cmpi.b	#$FF, (a0)	;Check for sentinel
	bne	DisplayName

End:
	move.w	#$8164, (a3)	;turn on display, VINTS

	move.b	#0, (Reload)
LoopForever:
	tst.b	(Reload)
	bne	LoadHandler
	bra LoopForever




LoadHandler:
	moveq	#0, d0
	move.b	(Load), d0
	add.b	d0, d0
	add.b	d0, d0
	jmp	LoadTable(pc, d0)
LoadTable:
	bra	DisplayList
	bra	DisplayFile
	bra	LoadProgram
	bra	LoadProgramW
	bra	PlayRAW



PlayRAW:
	tst.b	$A1200F
	bne	PlayRAW			;wait for sub cpu to finish

	move.b	#0, $A1200E		;Clear handshake

WaitRaw:
	tst.b	$A1200F
	beq	WaitRaw

	move.l	#$A000, $A12010		;sample address
	move.w	#$800, $A12014		;playback frequency


	move.b	#8, $A1200E
WaitRaw2:
	tst.b	$A1200F
	bne	WaitRAw2

	bra	End




LoadProgramW:

	
	move.w  #$8124, (a3)	;turn off display

	bsr	ClearScreen

	move.w	#$8144, (a3)	;turn on display

ProgramWWait:
	tst.b	$A1200f		;wait for Sub CPU to finish
	bne	ProgramWWait


	
	move.w	#$8144, (a3)	;turn off VINTs

	jmp	$200000



LoadProgram:


	move.w  #$8124, (a3)	;turn off display

	bsr	ClearScreen

	move.w	#$8144, (a3)	;turn on display


	lea	CopyProgram(pc), a0
	movea.l	#$FFFE00, a1

	moveq	#$7f, d0

ProgramWait:
	tst.b	$A1200f		;wait for Sub CPU to finish
	bne	ProgramWait



CopyLoader:
	move.l	(a0)+, (a1)+
	dbra	d0, CopyLoader

	jmp	$FFFE00

CopyProgram:
	move.w	$A12022, d0
	subi.w	#1, d0

	movea.l	#$200000, a0
	movea.l	#$FF0000, a1
CopyIt:
	move.b	(a0)+, (a1)+
	dbra	d0, CopyIt

	move.w	#$8144, (a3)		;turn off VINTs

	jmp	$FF00000



DisplayFile:
	move.w	#0, (Reload)
	
	lea	VintText(pc), a1		;Load Address for VBL routine
	jsr	 $368		;make appropriate change in Interrupt Jump table


	move.w  #$8124, (a3)	;turn off display

	bsr	ClearScreen

FileWait:
	tst.b	$A1200F
	bne	FileWait	;wait for sub cpu to finish

	
	movea.l	#$200000, a0
	move.l	#$00800000, d2	;delta between lines
	move.w	#$4000, d0	;choose pallete #2
FileAgain:
	move.l  #$40040003,d1	;VDP Command word for beginning of Screen (well two spaces over anyway)

	
	moveq	#32, d4
Line:
	moveq	#36, d3
	move.l	d1, (a3)
Character:
	move.b	(a0)+, d0
	move.w	d0, (a2)
	dbra	d3, Character

	add.l	d2, d1
	dbra	d4, Line
	
	move.w	#$8164, (a3)

TextLoop:
	tst.b	(Reload)
	bne	TextLoadHandler
	bra	TextLoop

TextLoadHandler
	tst.b	(Load)
	bne	StartOver
	move.w  #$8124, (a3)	;turn off display
	move.w	#0, (Reload)

	bsr	ClearScreen
	bra	FileAgain
	
StartOver:
	move.w	#0, (Reload)
	bra	Start

; Vint we can use with the CD BIOS
VintBios:
	jsr $360	; sendInt2ToSubCpu
	rte

VintText:
	move.b	#1, $A12000	;trigger interrupt on Sub CPU
	move.w	(a3), d7	;read status port to prevent VDP lock

	tst.w	(Buttons)
	bne	WaitButtons

	bsr	ReadPad

	btst	#2, d7
	beq	PageUp

	btst	#3, d7
	beq	PageDown

	btst	#7, d7
	beq	GoBack

	rte

PageUp:
	subi.l	#1184, (Page)
	move.b	#1, (Reload)
	rte

PageDown:
	addi.l	#1184, (Page)
	move.b	#1, (Reload)
	rte
GoBack:
	move.b	#1, (Reload)
	move.b	#4, (Load)
	rte


Vint:
	move.b	#1, $A12000	;trigger interrupt on Sub CPU
	move.l	#$78000002, (a3)
	move.w	(PointerPos), (a2)
	move.l	d1, (a3)

	tst.w	(Buttons)	;delay between button presses
	bne	WaitButtons

	bsr	ReadPad

	btst	#2, d7
	beq	PrevPage

	btst	#3, d7
	beq	NextPage

	btst	#0, d7
	beq	PointerDown

	btst	#1, d7
	beq	PointerUp

	btst	#6, d7
	beq	OpenText

	btst	#7, d7
	beq	OpenProgram

	btst	#5, d7
	beq	OpenProgramW

	btst	#4, d7
	beq	LoadRAW

	rte
WaitButtons:
	subi.w #1, (Buttons)	
	rte	

Title:
	dc.b	'          Sega Loader V1.0'
PointerPos:
	dc.w	144
Reload:
	dc.b	0
Load:
	dc.b	0
Buttons:
	dc.w	0
Page:
	dc.l	$200000

ReadPad:
	move.b	#$FF, $a10003	;set TH for controller A
	move.b	$a10003, d7	;CBRLUD
	andi.b	#$3F, d7
	move.b	#0, $a10003
	move.b	$a10003, d6	;SA00UD
	andi.b	#$30, d6
	lsl.b	#2, d6
	or.b	d6, d7		;SACBRLUD

	move.w	#10, (Buttons)
	rts


PrevPage:
	cmpi.l	#$200000, (Page)
	beq	NoChange
	subi.l	#$410, (Page)
	move.b	#1, (Reload)
NoChange:
	rte

NextPage:
	cmpi.b	#$FF, (a0)
	beq	NoChange
	addi.l	#$410, (Page)
	move.b	#1, (Reload)
	rte

PointerDown:
	sub.w	#$8, (PointerPos)
	rte

PointerUp:
	add.w	#$8, (PointerPos)
	rte

OpenText:
	move.b	#1, (Load)		;Set Text Handler
	bra	LoadFile

OpenProgramW:
	move.b	#3, (Load)
	bra	LoadFile

OpenProgram:	
	move.b	#2, (Load)		;Set Program Handler
LoadFile:

	move.b	#0, $A1200E
	moveq	#0, d0			;clear out all 32-bits of d0
	move.w	(PointerPos), d0	;get current pointer position
	andi.w	#$3FF, d0
	subi.w	#144, d0		;translate to file number
	lsr.w	#3, d0
	mulu.w	#$28, d0
	add.l	(Page), d0		;turn file number into Address in table
	move.l	d0, a0
	move.l	$20(a0), $A12010	;move file block number into COM RAM
	move.l	$24(a0), d0		
	cmpi.l	#$40000, d0		;make sure file isn't too big
	bls	SizeGood
	move.l	#$40000, d0
SizeGood:
	move.l	d0, $A12014		;move file size into COM RAM
	move.l	#$80000, $A12018	;move Word Ram address into COM RAM
	bset	#1, $A12003		;give SUB cPU control of WordRAM
WaitForSub:
	tst.b	$A1200F
	beq	WaitForSub
	move.b	#2, $A1200E

	move.b	#1, (Reload)		;Set Reload Flag
	rte

LoadRAW:
	move.b	#4, (Load)

	move.b	#0, $A1200E
	moveq	#0, d0			;clear out all 32-bits of d0
	move.w	(PointerPos), d0	;get current pointer position
	andi.w	#$3FF, d0
	subi.w	#144, d0		;translate to file number
	lsr.w	#3, d0
	mulu.w	#$28, d0
	add.l	(Page), d0		;turn file number into Address in table
	move.l	d0, a0
	move.l	$20(a0), $A12010	;move file block number into COM RAM
	move.l	$24(a0), d0		
	cmpi.l	#$10000, d0		;make sure file isn't too big
	bls	RawSizeGood
	move.l	#$10000, d0
RawSizeGood:
	move.l	d0, $A12014		;move file size into COM RAM
	move.l	#$A000, $A12018		;move RAW Sample buffer address into COM RAM

	bra	WaitForSub
	

ClearScreen:
	move.l	#$40000003, (a3)
	move.w	#$1027, d6
Write:
	move.l	#0, (a2)
	dbra	d6, Write

	rts

; palette after sega logo on NTSC-U
Palette:
	dc.w 0, $0EE8, 0, $0EE4, $0EE0, $0EC0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.w 0, $0EC0, 0, $0EE0, $0EC0, $0EA0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.w 0, $0E80, 0, $0EC0, $0EA0, $0E80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dc.w 0, 0, $0C22, $0E44, $0E66, $0E88, $0EEE, $0AAA, $0888, $0444, $08AE, $6A08, $0E03, $0800, $0300, $2000, $0E20
	
	; Round the output + security code + header to 1000h bytes
	org	$FF0DFC
	dc.l 0
	