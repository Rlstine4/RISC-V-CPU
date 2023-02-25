


<main>:


      addi	sp,sp,-48
      sw	s0,40(sp)
      addi	s0,sp,48
    
        li	a5,40
        sw	a5,-40(s0)
        li	a5,892
           sw	a5,-36(s0)
         li	a5,5
            sw	a5,-32(s0)

  
           sw	zero,-28(s0)

<.LBB2>:
   

    
          sw	zero,-20(s0)
        j	<.L2>

<.L6>:
   
      sw	zero,-24(s0)
    j	<.L3>

 <.L5>:
 
      lw	a5,-24(s0)
    slli	a5,a5,0x2
    addi	a5,a5,-16
    add	a5,a5,s0
      lw	a4,-24(a5)
      lw	a5,-24(s0)
   	addi	a5,a5,1
       
       	slli	a5,a5,0x2
     addi	a5,a5,-16
         	add	a5,a5,s0
      lw	a5,-24(a5)
      bge	a5,a4, <.L4>
            
                
      lw	a5,-24(s0)
    slli	a5,a5,0x2
    addi	a5,a5,-16
    add	a5,a5,s0
      lw	a5,-24(a5)
      sw	a5,-28(s0)
                
      lw	a5,-24(s0)
    addi	a5,a5,1
  
    slli	a5,a5,0x2
    addi	a5,a5,-16
    add	a5,a5,s0
      lw	a4,-24(a5)
   	lw	a5,-24(s0)
    slli	a5,a5,0x2
    addi	a5,a5,-16
    add	a5,a5,s0
      sw	a4,-24(a5)
                
      lw	a5,-24(s0)
    addi	a5,a5,1

    slli	a5,a5,0x2
    addi	a5,a5,-16
    add	a5,a5,s0
      lw	a4,-28(s0)
      sw	a4,-24(a5)

 <.L4>:
  
      lw	a5,-24(s0)
    addi	a5,a5,1
      sw	a5,-24(s0)

 <.L3>:
    li	a5,3
      lw	a4,-20(s0)
    sub	a5,a5,a4

      lw	a5,-24(s0)

      blt	a5,a4, <.L5>

 <.LBE3>:
    
      lw	a5,-20(s0)
    addi	a5,a5,1
      sw	a5,-20(s0)

 <.L2>:
      lw	a5,-20(s0)
      
    li	a5,2
      bge	a5,a4, <.L6>

<.LBE2>:
  
    nop
    nop
    lw	s0,40(sp)
    addi	sp,sp,48
    ret
