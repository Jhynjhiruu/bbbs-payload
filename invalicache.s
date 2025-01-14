.include "macro.inc"

/* assembler directives */
.set noat      /* allow manual use of $at */
.set noreorder /* don't insert nops after branches */
.set gp=64     /* allow use of 64-bit general purpose registers */

.section .low, "ax"

/* Generated by spimdisasm 1.13.0 */

# Handwritten function
glabel osInvalICache
/* 35A0 800045A0 18A00011 */  blez       $a1, .L800045E8
/* 35A4 800045A4 00000000 */   nop
/* 35A8 800045A8 240B4000 */  addiu      $t3, $zero, 0x4000
/* 35AC 800045AC 00AB082B */  sltu       $at, $a1, $t3
/* 35B0 800045B0 1020000F */  beqz       $at, .L800045F0
/* 35B4 800045B4 00000000 */   nop
/* 35B8 800045B8 0080402D */  daddu      $t0, $a0, $zero
/* 35BC 800045BC 00854821 */  addu       $t1, $a0, $a1
/* 35C0 800045C0 0109082B */  sltu       $at, $t0, $t1
/* 35C4 800045C4 10200008 */  beqz       $at, .L800045E8
/* 35C8 800045C8 00000000 */   nop
/* 35CC 800045CC 2529FFE0 */  addiu      $t1, $t1, -0x20
/* 35D0 800045D0 310A001F */  andi       $t2, $t0, 0x1F
/* 35D4 800045D4 010A4023 */  subu       $t0, $t0, $t2
.L800045D8:
/* 35D8 800045D8 BD100000 */  cache      0x10, 0x0($t0) # handwritten instruction
/* 35DC 800045DC 0109082B */  sltu       $at, $t0, $t1
/* 35E0 800045E0 1420FFFD */  bnez       $at, .L800045D8
/* 35E4 800045E4 25080020 */   addiu     $t0, $t0, 0x20
.L800045E8:
/* 35E8 800045E8 03E00008 */  jr         $ra
/* 35EC 800045EC 00000000 */   nop
.L800045F0:
/* 35F0 800045F0 3C088000 */  lui        $t0, 0x8000
/* 35F4 800045F4 010B4821 */  addu       $t1, $t0, $t3
/* 35F8 800045F8 2529FFE0 */  addiu      $t1, $t1, -0x20
.L800045FC:
/* 35FC 800045FC BD000000 */  cache      0x00, 0x0($t0) # handwritten instruction
/* 3600 80004600 0109082B */  sltu       $at, $t0, $t1
/* 3604 80004604 1420FFFD */  bnez       $at, .L800045FC
/* 3608 80004608 25080020 */   addiu     $t0, $t0, (0x80000020 & 0xFFFF)
/* 360C 8000460C 03E00008 */  jr         $ra
/* 3610 80004610 00000000 */   nop
