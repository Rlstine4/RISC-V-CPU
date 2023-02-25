

 <main>:

  	addi	sp,sp,-48
  	sd	s0,40(sp)
  	addi	s0,sp,48
   
	    lui	a5,0x0
	    mv	a5,a5
  	ld	a4,0(a5)
  	    sd	a4,-48(s0)
    	ld	a4,8(a5)
  	    sd	a4,-40(s0)
    	lw	a5,16(a5)
  	    sw	a5,-32(s0)

    
  	    sw	zero,-28(s0)

<.LBB2>:

  
  	    sw	zero,-20(s0)
    	j	c6 <.L2>

 <.L6>:
    
  	    sw	zero,-24(s0)
    	j	a6 <.L3>

 <.L5>:
       
  	    lw	a5,-24(s0)
    	slli	a5,a5,0x2
    	addi	a5,a5,-16
    	add	a5,a5,s0
  	    lw	a4,-32(a5)
  	    lw	a5,-24(s0)
    	addiw	a5,a5,1
    	sext.w	a5,a5
    	slli	a5,a5,0x2
    	addi	a5,a5,-16
    	add	a5,a5,s0
  	    lw	a5,-32(a5)
  	    bge	a5,a4,9c <.L4>
    
  	    lw	a5,-24(s0)
    	slli	a5,a5,0x2
    	addi	a5,a5,-16
    	add	a5,a5,s0
  	    lw	a5,-32(a5)
  	    sw	a5,-28(s0)
                
  	    lw	a5,-24(s0)
    	addiw	a5,a5,1
    	sext.w	a5,a5
    	slli	a5,a5,0x2
    	addi	a5,a5,-16
    	add	a5,a5,s0
  	    lw	a4,-32(a5)
  	    lw	a5,-24(s0)
    	slli	a5,a5,0x2
    	addi	a5,a5,-16
    	add	a5,a5,s0
  	    sw	a4,-32(a5)
            
  	    lw	a5,-24(s0)
    	addiw	a5,a5,1
    	sext.w	a5,a5
    	slli	a5,a5,0x2
    	addi	a5,a5,-16
    	add	a5,a5,s0
  	    lw	a4,-28(s0)
  	    sw	a4,-32(a5)

<.L4>:

  	    lw	a5,-24(s0)
    	addiw	a5,a5,1
  	    sw	a5,-24(s0)

<.L3>:
    	li	a5,4
  	    lw	a4,-20(s0)
    	subw	a5,a5,a4
  	    sext.w	a4,a5
  	    lw	a5,-24(s0)
    	sext.w	a5,a5
  	    bge	a4,a5,30 <.L5>

<.LBE3>:
   
  	    lw	a5,-20(s0)
    	addiw	a5,a5,1
  	    sw	a5,-20(s0)

 <.L2>:
  	    lw	a5,-20(s0)
  	    sext.w	a4,a5
    	li	a5,4
  	    bge	a5,a4,2a <.L6>

 <.LBE2>:

    	nop
    	nop
    	ld	s0,40(sp)
    	addi	sp,sp,48
    	ret
