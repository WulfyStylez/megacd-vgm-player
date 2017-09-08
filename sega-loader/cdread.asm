    org $6000
    incbin 'assets/payload-descriptor.bin'
	org	$6024

	andi.b	#$FA, $FF8003		;set 2Mbit mode

	lea	Packet(pc), a5
	jsr	ReadCD

	move.l	$80A2, (a5)
	move.l	(a5), d0
	move.l	$80AA, d0
	lsr.l	#8, d0
	lsr.l	#3, d0
	move.l	d0, 4(a5)
	move.l	#$8000, 8(a5)
	jsr	ReadCD

	move.b	#0, $FF800F


Wait:
	tst.b	$FF800E
	bne	Wait
	move.b	#1, $FF800F
Wait2:
	tst.b	$FF800E
	beq	Wait2

	moveq	#0, d0
	move.b	$FF800E, d0
	cmpi.b	#7, d0
	bgt	Wait
	add.w	d0, d0
	add.w	d0, d0
	jmp	FuncTable(pc, d0)
FuncTable:
	bra	Wait
	bra	FileList
	bra	FileByNumber
	bra	FileByNameSimple
	bra	FileByNameExtended
	bra	SetExtended
	bra	Jump
	bra	JumpSub



FileList:

	move.l	#$8000, a0
	move.l	#$80000, a1
NextFile:
	moveq	#0, d0
	move.b	(a0), d0		;get record length
	beq	EndList
	move.l	6(a0), $20(a1)		;file location
	move.l	$E(a0), $24(a1)		;file length
	moveq	#0, d1
	move.b	$20(a0), d1		;file name length
	subi.w	#1, d1
	beq	Terminate		;skip copy if length = 0		
	lea	$21(a0), a2
	movea.l	a1, a4
copyName:
	move.b	(a2)+, (a4)+		;copy filename to new table
	dbra	d1, CopyName
Terminate:
	move.b	#0, (a4)

	adda.l	d0, a0
	addi.l	#$28, a1
	bra	NextFile
	
EndList:
	move.b	#$FF, (a1)
	ori.b	#1, $FF8003
	move.b	#0, $FF800F
	bra	Wait





FileByNumber:
	lea	Packet(pc), a5
	move.l	$FF8010, (a5)
	move.l	$FF8014, d0
	move.l	$FF8018, 8(a5)
File:
	move.l	d0, $FF8020
	move.l	d0, d1
	lsr.l	#8, d1
	lsr.l	#3, d1
	andi.l	#$7FF, d0
	beq	SectorAligned
	addq	#1, d1

SectorAligned:
	move.l	d1, 4(a5)

	bsr	ReadCD

	move.l	$8000, d7

	ori.b	#1, $FF8003

	move.b	#0, $FF800F
	
	bra	Wait




FileByNameSimple:
	lea	Packet(pc), a5
	move.l	#$80000, 8(a5)
	move.l	#$40000, 4(a5)
	move.l	#0, (BeginOffset)

FileByNameExtended:
	move.l	#$FF8010, a0
	bsr	FindFile
	bcc	FileNotFound

	lsl.l	#8, d1
	lsl.l	#3, d1
	add.l	(BeginOffset), d1
	sub.l	(BeginOffset), d0
	lsr.l	#8, d1
	lsr.l	#3, d1

	lea	Packet(pc), a5

	move.l	4(a5), d3
	cmp.l	d0, d3
	bgt	TooBig			;File is either smaller than requested length or size of WordRAM

	move.l	d3, d0
TooBig:

	move.l	d1, (a5)
	bra	File

FileNotFound:
	ori.b	#1, $FF8003
	move.b	#$FF, $FF800F
	bra	Wait




SetExtended:
	lea	Packet(pc),a5
	move.l	$FF8010, 8(a5)
	move.l	$FF8014, 4(a5)
	move.l	$FF8018, (BeginOffset)

	move.b	#0, $FF800F
	bra	Wait



Jump:
	move.l	$FF8010, a0
	jmp	(a0)

JumpSub:
	move.l	$FF8010, a0
	jsr	(a0)
	rts



FindFile:
	move.l	#$8000, a2

NextName:
	moveq	#0, d3
	move.b	(a2), d3
	beq	NotFound

	lea	$21(a2), a3
	move.l	a0, a1
Compare:
	tst.b	(a1)
	beq	Found
	cmp.b	(a1)+,  (a3)+
	beq	Compare

	add.l 	d3, a2
	bra	NextName

NotFound:	
	move	#0, CCR
	rts

Found:
	move.l	$E(a2), d0
	move.l	6(a2), d1
	move	#1, CCR
	rts	




ReadCD:	
	movea.l	a5, a0
	move.w	#$89, d0		;init CD controller
	jsr 	$5f22
	move.w	#$20, d0		;start read operation
	jsr	$5f22

Check:
	move.w	#$8A, d0		;check for data
	jsr	$5f22
	bcs	Check

Check2:
	move.w	#$8B, d0
	jsr	$5f22
	bcc	Check2

Check3:
	move.w	#$8C, d0
	movea.l	8(a5), a0
	lea	$C(a5), a1
	jsr	$5f22
	bcc	Check3

	move.w	#$8D, d0
	jsr	$5f22

	addi.l	#$800, 8(a5)
	addq.l	#1, (a5)
	subq.l	#1, 4(a5)
	bne	Check
	rts


	
BeginOffset:
	dc.l	$0
Packet:
	dc.l	$10, 1, $8000, ExtraJunk, 0
ExtraJunk:
	dc.b	0
    
    ; round the output binary out to 0x1000 bytes, also tells us if we've written too much code
    org	$6FFC
    dc.l 0
    