main:                                   # @main
        addi    sp, sp, -48
        sw      ra, 44(sp)                      # 4-byte Folded Spill
        sw      s0, 40(sp)                      # 4-byte Folded Spill
        addi    s0, sp, 48
        li      a0, 1
        sw      a0, -12(s0)
        li      a0, 74
        sw      a0, -16(s0)
        li      a0, 5
        sw      a0, -20(s0)
        li      a0, 89
        sw      a0, -24(s0)
        li      a0, 40
        sw      a0, -28(s0)
        li      a0, 0
        sw      a0, -32(s0)
        sw      a0, -36(s0)
        j       .LBB0_1
.LBB0_1:                                # =>This Loop Header: Depth=1
        lw      a1, -36(s0)
        li      a0, 4
        blt     a0, a1, .LBB0_10
        j       .LBB0_2
.LBB0_2:                                #   in Loop: Header=BB0_1 Depth=1
        li      a0, 0
        sw      a0, -40(s0)
        j       .LBB0_3
.LBB0_3:                                #   Parent Loop BB0_1 Depth=1
        lw      a1, -40(s0)
        lw      a2, -36(s0)
        li      a0, 5
        sub     a0, a0, a2
        blt     a0, a1, .LBB0_8
        j       .LBB0_4
.LBB0_4:                                #   in Loop: Header=BB0_3 Depth=2
        lw      a0, -40(s0)
        slli    a1, a0, 2
        addi    a0, s0, -28
        add     a0, a0, a1
        lw      a1, 0(a0)
        lw      a0, 4(a0)
        bge     a0, a1, .LBB0_6
        j       .LBB0_5
.LBB0_5:                                #   in Loop: Header=BB0_3 Depth=2
        lw      a0, -40(s0)
        slli    a0, a0, 2
        addi    a2, s0, -28
        add     a0, a0, a2
        lw      a0, 0(a0)
        sw      a0, -32(s0)
        lw      a0, -40(s0)
        slli    a0, a0, 2
        add     a1, a2, a0
        lw      a0, 4(a1)
        sw      a0, 0(a1)
        lw      a0, -32(s0)
        lw      a1, -40(s0)
        slli    a1, a1, 2
        add     a1, a1, a2
        sw      a0, 4(a1)
        j       .LBB0_6
.LBB0_6:                                #   in Loop: Header=BB0_3 Depth=2
        j       .LBB0_7
.LBB0_7:                                #   in Loop: Header=BB0_3 Depth=2
        lw      a0, -40(s0)
        addi    a0, a0, 1
        sw      a0, -40(s0)
        j       .LBB0_3
.LBB0_8:                                #   in Loop: Header=BB0_1 Depth=1
        j       .LBB0_9
.LBB0_9:                                #   in Loop: Header=BB0_1 Depth=1
        lw      a0, -36(s0)
        addi    a0, a0, 1
        sw      a0, -36(s0)
        j       .LBB0_1
.LBB0_10:
        lw      ra, 44(sp)                      # 4-byte Folded Reload
        lw      s0, 40(sp)                      # 4-byte Folded Reload
        addi    sp, sp, 48