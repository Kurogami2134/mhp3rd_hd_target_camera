.macro vertex, u, v, rgba, x, y, z
    .halfword   u
    .halfword   v
    .byte       rgba >> 24 & 0xFF
    .byte       rgba >> 16 & 0xFF
    .byte       rgba >> 8 & 0xFF
    .byte       rgba & 0xFF
    .halfword   x
    .halfword   y
    .halfword   z
    .halfword   0
.endmacro

.macro vtype, bp_trans, tex, color, nor, pos, wei, wei_cnt, idx
    .word 0x12000000 | (bp_trans & 1) << 23 | (wei & 3) << 9 | (max(0, wei_cnt-1) & 7) << 14 | tex & 3 | (color & 7) << 2 | (nor & 3) << 5 | (pos & 3) << 7 | (idx & 3) << 11
.endmacro

.macro end
    .word 0x0C000000
.endmacro

.macro finish
    .word 0x0F000000
.endmacro

.macro base, hi
    .word 0x10000000 | hi << 16
.endmacro

.macro offset, add
    .word 0x13000000 | add
.endmacro

.macro origin
    .word 0x14000000
.endmacro

.macro tbp0, lo
    .word 0xA0000000 | lo
.endmacro

.macro tbw0, width, hi
    .word 0xA8000000 | width |  hi << 16
.endmacro

.macro tsize0, width, height
    .word 0xB8000000 | height << 8 | width
.endmacro

.macro tme, enabled
    .word 0x1E000000 | enabled
.endmacro

.macro tflush
    .word 0xCB000000
.endmacro

.macro tfunc, func, alpha
    .word 0xC9000000 | alpha << 8 | func
.endmacro

.macro tfilter, min_filter, mag_filter
    .word 0xC6000000 | mag_filter << 8 | min_filter
.endmacro

.macro vaddr, addr
    .word 0x01000000 | addr
.endmacro

.macro prim, v_count, type
    .word 0x04000000 | v_count | type << 16
.endmacro

.macro tpf, format
    .word 0xc3000000 | format
.endmacro

.macro tmode, swizzle, separate_clut, levels
    .word swizzle | separate_clut << 8 | levels << 16 | 0xC2000000
.endmacro

.macro clutf, format, index
    .word 0xc5000000 | format | index << 8
.endmacro

.macro clutaddlo, address
    .word 0xb0000000 | address
.endmacro

.macro clutaddhi, address
    .word 0xb1000000 | (address << 16)
.endmacro

.macro clutadd, address
    .word 0xb0000000 | (address & 0x00FFFFFF)
    .word 0xb1000000 | ((address & 0xFF000000) >> 8)
.endmacro

.macro load_clut, size;  size / 32
    .word 0xc4000000 | size
.endmacro
