.psp

MONSTER_POINTER     equ 0x0A1B0AE0
HOOK                equ 0x088E79EC
RENDER_HOOK         equ 0x0A16A650
ViewMatrix          equ 0x09F4F120
sceGeListEnQueue    equ 0x08965990
crosshair_tex_ptr   equ 0x0Bfff360
CROSSHAIR_DURATION  equ 45

icon_x equ 0
icon_y equ 225

.include "./src/gpu_macros.asm"

.macro lih,dest,value
	lui			at, value / 0x10000
	lh			dest, value & 0xFFFF(at)
.endmacro

.macro lib,dest,value
	lui			at, value / 0x10000
	lb			dest, value & 0xFFFF(at)
.endmacro

.macro sih,orig,value
	lui			at, value / 0x10000
	sh			orig, value & 0xFFFF(at)
.endmacro

.createfile "./bin/target_cam.bin", 0x0B100000

enabled:
    .byte   1
selected_monster:
    .byte   0
.align 4

.func main
    lw      v0, 0x74(s5)
    lbu     a2, 0x8F(s1)
    
    li      t0, enabled
    lb      t0, 0x0(t0)
    bne     t0, zero, find_angle
    nop

return:
    li      a1, 0
    li      a2, 0
    j       HOOK+8
    li      a3, 0
.endfunc

.func find_angle; (player_data: a0) -> short: v0
    addiu   sp, sp, -0x4
    sw      ra, 0x0(sp)

    lib     a1, selected_monster
    li      a2, MONSTER_POINTER
    addu    a1, a1, a2
    lw      a1, 0x0(a1)
    jal     monster_in_area
    nop
    beq     t0, zero, @@ret
    nop
    
    jal     get_angle
    nop

    li      a1, crosshair_timer
    li      a2, CROSSHAIR_DURATION
    sh      a2, 0x0(a1)

@@ret:
    lw      ra, 0x0(sp)
    j       return
    addiu   sp, sp, 0x4
.endfunc

.func get_angle; (player_data: a0, monster_data: a1) -> short v0
    lv.s    s000, 0x80(a0)
    lv.s    s001, 0x88(a0)
    lv.s    s002, 0x80(a1)
    lv.s    s003, 0x88(a1)

    vsub.p  c000, c002, c000

    vmul.p  c002, c000, c000
    vfad.p  r020, c002  ; r020 = s003
    vsqrt.s s003, s003
    vdiv.s  s003, s000, s003
    vasin.s s003, s003

    vsgn.s  s001, s001
	vmul.s  s003, s003, s001

    vzero.s s002
    vsge.s  s000, s001, s002

    lui     a1, 0x4000
    mtv     a1, s002
    vadd.s  s003, s003, s002

    vmul.s  s002, s000, s002
    vadd.s  s003, s003, s002

    li      a1, 0x467fff00; 0xFFFF/(2*pi)/(2/pi)
    mtv     a1, s002
    vmul.s  s000, s002, s003

    vf2in.s s000, s000, 0

    mfv     a1, s000

    slti    at, a1, 0x0
    beq     at, zero, no_flip
    li      a2, 0xffff
    addu    a1, a1, a2

no_flip:
    andi    v0, a1, 0xFFFF
    jr      ra
    nop
.endfunc

.func monster_in_area; (player_data: a0, monster_data: a1) -> bool: t0
    lb      t0, 0xD6(a0)
    lb      t1, 0xD6(a1)
    xor     t0, t0, t1
    jr      ra
    slti    t0, t0, 0x1
.endfunc


.close


RENDER_LOAD equ 0x0B100130
.createfile "./bin/RENDER.bin", RENDER_LOAD
;  ICON RENDERING

.func render
    addiu       sp, sp, -0x4
    sw          ra, 0x00(sp)
    
    jal         set_cursor
    nop

    li          t1, 0x0
    li          t0, 0x0
@loop:
    jal         get_id
    move        a0, t1
    jal         load_texture
    move        a0, v0
    
    addiu       t1, t1, 4
    addiu       t0, t0, 0x10
    slti        at, t0, 0x30
    bne         at, zero, @loop
    nop

    li          a0, gpu_code
    li          a2, 0
    li          a3, 0
    jal         sceGeListEnQueue
    li          a1, 0x0

    b           crosshair_stuff
    nop
    
@render_return:

    lw          ra, 0x0(sp)
    addiu       sp, sp, 0x4
    lw          a0, 0x8(sp)
    lw          v0, 0x4(sp)
    j           RENDER_HOOK+9
    nop
    
.endfunc

.func set_cursor

    lih         a0, selected_monster

    slti        at, a0, 9
    bne         at, zero, @continue
    nop
    li          a0, 0
    sih         a0, selected_monster
    
@continue:

    srl         a0, a0, 2
    li          at, select_vertices
    
    sll         a2, a0, 5
    sll         a3, a0, 3
    addu        a2, a2, a3
    sll         a3, a0, 1
    addu        a0, a2, a3

    addiu       a0, a0, icon_x+10
    sh          a0, 0x08(at)
    addiu       a0, a0, 22
    sh          a0, 0x18(at)

    jr          ra
    nop

.endfunc

.func get_id

    li          a1, MONSTER_POINTER
    addu        a1, a1, a0
    lw          a0, 0x0(a1)
    beql        a0, zero, get_id_ret
    li          v0, 0x0
    lb          v0, 0x62(a0)
    slti        at, v0, 65
    beql        at, zero, get_id_ret
    li          v0, 0x0
get_id_ret:
    jr          ra
    nop

.endfunc


.func load_texture
    bne         a0, zero, normal_tex_load
    nop

    li          at, vertices
    addu        at, at, t0
    addu        at, at, t0

    sw          zero, 0x00(at)
    sw          zero, 0x10(at)

    li          at, 0x1910
    li          a1, clut_add
    addu        a1, a1, t0
    sh          at, 0x0(a1)

    jr          ra
    nop

normal_tex_load:
    ; set CLUT
    addiu       a0, a0, -1

    li          at, icons
    sll         a0, a0, 1
    add         a1, at, a0

    lb          a0, 0x0(a1)
    lb          a1, 0x1(a1)
    sll         a1, a1, 6

    li          at, 0x1910
    add         at, at, a1
    li          a1, clut_add
    addu        a1, a1, t0
    sh          at, 0x0(a1)

    ; set vertices
    li          at, vertices
    addu        at, at, t0
    addu        at, at, t0
    srl         a1, a0, 0x3
    
    ; * 42
    sll         a2, a1, 5
    sll         a3, a1, 3
    addu        a2, a2, a3
    sll         a3, a1, 1
    addu        a1, a2, a3
    
    
    sh          a1, 0x02(at)
    addiu       a1, a1, 42
    sh          a1, 0x12(at)
    
    srl         a1, a0, 0x3
    sll         a1, a1, 0x3
    subu        a1, a0, a1
    
    ; * 42
    sll         a2, a1, 5
    sll         a3, a1, 3
    addu        a2, a2, a3
    sll         a3, a1, 1
    addu        a1, a2, a3
    
    
    sh          a1, 0x00(at)
    addiu       a1, a1, 42
    sh          a1, 0x10(at)

ret:
    jr          ra
    nop
.endfunc

.area 65*2, 0x0

icons:
.include "./src/monster_icons.asm"
.endarea
.align 4

crosshair_timer:
    .word       0xDEADBEEF

.func crosshair_stuff
    li          a1, crosshair_timer
    lh          a0, 0x0(a1)
    beq         a0, zero, @render_return
    nop
    addiu       a0, a0, -0x1
    sh          a0, 0x0(a1)

    ; set texture addr
    li          a0, crosshair_tex_ptr
    lw          a0, 0x0(a0)
    sll         a0, a0, 8
    srl         a0, a0, 8
    lui         a1, 0xA000
    or          a1, a0, a1
    li          a2, crosshair_tex_add
    sw          a1, 0x0(a2)

    ; set clut addr
    li          a1, 0x8210
    add         a0, a0, a1
    lui         a1, 0xB000
    or          a1, a0, a1
    li          a2, crosshair_clut_add
    sw          a1, 0x0(a2)

world_to_screen:  ; thanks pggkun
    ; load view matrix
    li      a0, ViewMatrix

    lv.q    r100, 0x00(a0)
    lv.q    r101, 0x10(a0)
    lv.q    r102, 0x20(a0)
    lv.q    r103, 0x30(a0)
    
    li      a0, MONSTER_POINTER
    lih     a1, selected_monster
    addu    a0, a0, a1
    lw		a0, 0x0(a0)

    ; load monster coords
    lv.q  c500, 0x80(a0)
    vone.s  s503

    ; view matrix * monster coords
    vtfm4.q r600, m100, c500

    ; set projection matrix
    vzero.q  c500
    vzero.q  c510
    vzero.q  c520
    vzero.q  c530

    li	a0,	0x3f9b8c00
    mtv	a0, s500

    li	a0, 0x40093eff
    mtv	a0, s511

    li	a0, 0xbf800000
    mtv	a0, s522

    li	a0, 0xbf800000
    mtv	a0, s532

    li	a0, 0xc2700000
    mtv	a0, s523

    ; projection matrix * view matrix * monster coords
    vtfm4.q r601, M500, r600

    vdiv.s s602, s601, s631
    vdiv.s s612, s611, s631
    vdiv.s s622, s621, s631

    li	a0, 0x43f00000
    mtv	a0, s600

    li	a0, 0x43880000
    mtv	a0, s610

    li	a0, 0x3f000000
    mtv	a0, s620

    vadd.s s602, s602, s630
    vmul.s s602, s602, s620
    vmul.s s602, s602, s600 ;result x

    vsub.s s612, s630, s612
    vmul.s s612, s612, s620
    vmul.s s612, s612, s610 ;result y

    ; set crosshair vertices
    vf2iz.p     r602, r602, 0
    mfv         a1, s602
    mfv         a2, s612
    addiu       a1, a1, -0xC
    addiu       a2, a2, -0x15

    li          a0, crosshair_vertices
    sh          a1, 0x08(a0)
    sh          a2, 0x0A(a0)

    addiu       a1, a1, 25
    addiu       a2, a2, 25
    sh          a1, 0x18(a0)
    sh          a2, 0x1A(a0)


    li          a0, crosshair_gpu
    li          a2, 0
    li          a3, 0
    jal         sceGeListEnQueue
    li          a1, 0x0

    b           @render_return
    nop
.endfunc
.align 0x10

crosshair_gpu:
    offset      0
    base        RENDER_LOAD >> 24
    vtype       1, 2, 7, 0, 2, 0, 0, 0
    tfilter     0, 0
    tmode       1, 0, 0
    tpf         4

crosshair_tex_add:
    tbp0        0x6AA950
    tbw0        0x100, 9
    
    tsize0      8, 8

    clutf       3, 0xff
    clutaddhi   0x09
    
    vaddr       crosshair_vertices-(RENDER_LOAD & 0xFF000000)
    tme         1
    tfunc       0, 1

crosshair_clut_add:
    clutaddlo     0x6AA950+0x8210
    load_clut   2
    tflush
    prim        2, 6

    finish
    end

.align 0x10

gpu_code:
    offset      0
    base        RENDER_LOAD >> 24
    vtype       1, 2, 7, 0, 2, 0, 0, 0
    tfilter     0, 0
    tmode       1, 0, 0
    tpf         4
    tbp0        0x3d2700
    tbw0        0x160, 9
    tsize0      9, 9

    clutf       3, 0xff
    clutaddhi   0x09
    
    vaddr       vertices-(RENDER_LOAD & 0xFF000000)
    tme         1
    tfunc       0, 1

clut_add:
    clutaddlo     0x3e0000
    load_clut   2
    tflush
    prim        2, 6

    clutaddlo     0x3e0000
    load_clut   2
    tflush
    prim        2, 6

    clutaddlo     0x3e0000
    load_clut   2
    tflush
    prim        2, 6

    ; draw select icon
    tbp0        0x3a6ea0
    tbw0        256, 9
    tsize0      8, 8
    clutaddlo   0x3af0f0
    load_clut   2
    tflush
    prim        2, 6

    finish
    end

.align 0x10
vertices:
    vertex      42, 0, 0xFFFFFFFF, icon_x, icon_y, 0
    vertex      42+42, 42, 0xFFFFFFFF, icon_x+42, icon_y+42, 0
    vertex      42, 0, 0xFFFFFFFF, icon_x+42, icon_y, 0
    vertex      42+42, 42, 0xFFFFFFFF, icon_x+82, icon_y+42, 0
    vertex      42, 0, 0xFFFFFFFF, icon_x+82, icon_y, 0
    vertex      42+42, 42, 0xFFFFFFFF, icon_x+124, icon_y+42, 0
select_vertices:
    vertex      129, 56, 0xFFFFFFFF, icon_x+10, icon_y+32, 0
    vertex      140, 63, 0xFFFFFFFF, icon_x+10+22, icon_y+32+14, 0
crosshair_vertices:
    vertex      57, 142, 0xFFFFFFFF, 0, 0, 0
    vertex      82, 167, 0xFFFFFFFF, 100, 100, 0
.close
