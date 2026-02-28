# Implementation 

## Timing

Given IHP 130nm is so fast, even if the max frequency on the output path is currently 
believed to be around 75MHz.
I decided to challenge myself to push the timing to 100MHz such that I can safely
push the max frequency of the ASIC and learn more about the characteristics of the 
GPIO output path. 

Inside the `mac_unit` the multiplication and addition operations are performed on the 
same cycle, so obviously the critical path is going to be on this path. 
 
## Worst path using bf16 arithmetic `v3.0`

Quite pleasingly the timing closes out of the box on 100MHz using `v3.0` on all 
corneres appart from the slower 1.08V 125C corner. As a reminder, this is with 
a full bfloat16 multiplication + addition in a single cycle!

Using the default config, the WNS is only -0.7 nm off, so really we are only off
by a shoestring. 

To help investigate further I prevented the synthsiszer from flattening the hierachy (and 
enabled autonaming), this obviously degraded timing significantly (-0.7 -> -4.6) but
gave me much more clarity into what my critical paths looked like. 

As expected, our ciritical path goes through the adder close path mantissa, more specifically ending
in the mantissa clamping to zero on denomals: 
```
===========================================================================
report_checks -path_delay max (Setup)
============================================================================
======================= nom_slow_1p08V_125C Corner ===================================

Startpoint: m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/data_o_sg13g2_dfrbpq_1_Q_2
            (rising edge-triggered flip-flop clocked by clk)
Endpoint: m_2x2_systolic_mac/g_unit_x[0].g_unit_y[1].m_unit/add_q[1]_sg13g2_dfrbpq_1_Q
          (rising edge-triggered flip-flop clocked by clk)
Path Group: clk
Path Type: max

Fanout         Cap        Slew       Delay        Time   Description
---------------------------------------------------------------------------------------------
                                  0.000000    0.000000   clock clk (rise edge)
                                  0.000000    0.000000   clock source latency
     1    0.033548    0.075206    0.044770    0.044770 ^ clk (in)
                                                         clk (net)
                      0.075474    0.000000    0.044770 ^ clkbuf_0_clk/A (sg13g2_buf_16)
     4    0.109699    0.062922    0.144207    0.188977 ^ clkbuf_0_clk/X (sg13g2_buf_16)
                                                         clknet_0_clk (net)
                      0.064465    0.007387    0.196364 ^ clkbuf_2_0__f_clk/A (sg13g2_buf_16)
     6    0.104396    0.060539    0.137210    0.333574 ^ clkbuf_2_0__f_clk/X (sg13g2_buf_16)
                                                         clknet_2_0__leaf_clk (net)
                      0.062187    0.007630    0.341204 ^ clkbuf_leaf_1_clk/A (sg13g2_buf_8)
    14    0.064461    0.068867    0.144833    0.486037 ^ clkbuf_leaf_1_clk/X (sg13g2_buf_8)
                                                         clknet_leaf_1_clk (net)
                      0.069144    0.003423    0.489460 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/data_o_sg13g2_dfrbpq_1_Q_2/CLK (sg13g2_dfrbpq_1)
     6    0.033956    0.181089    0.397480    0.886940 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/data_o_sg13g2_dfrbpq_1_Q_2/Q (sg13g2_dfrbpq_1)
                                                         m_2x2_systolic_mac/data_flow_right[3][13] (net)
                      0.181101    0.001588    0.888528 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/b_nzero_sg13g2_nand2_1_Y_A_sg13g2_nor4_1_Y/C (sg13g2_nor4_1)
     1    0.008058    0.299400    0.336033    1.224562 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/b_nzero_sg13g2_nand2_1_Y_A_sg13g2_nor4_1_Y/Y (sg13g2_nor4_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/b_nzero_sg13g2_nand2_1_Y_A (net)
                      0.299400    0.000290    1.224851 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/b_nzero_sg13g2_nand2_1_Y/A (sg13g2_nand2_1)
     1    0.010575    0.159902    0.211572    1.436423 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/b_nzero_sg13g2_nand2_1_Y/Y (sg13g2_nand2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/b_nzero (net)
                      0.159902    0.000709    1.437132 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/fanout203/A (sg13g2_buf_1)
     8    0.044249    0.235765    0.305195    1.742327 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/fanout203/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/net203 (net)
                      0.236197    0.008385    1.750712 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y_A1_sg13g2_nand3_1_Y_C_sg13g2_o21ai_1_Y_B1_sg13g2_o21ai_1_Y/B1 (sg13g2_o21ai_1)
     2    0.006924    0.174884    0.143332    1.894045 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y_A1_sg13g2_nand3_1_Y_C_sg13g2_o21ai_1_Y_B1_sg13g2_o21ai_1_Y/Y (sg13g2_o21ai_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y_A1_sg13g2_nand3_1_Y_C_sg13g2_o21ai_1_Y_B1 (net)
                      0.174884    0.000394    1.894439 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y_A1_sg13g2_nand3_1_Y_C_sg13g2_o21ai_1_Y_A1_sg13g2_nor2b_1_A/B_N (sg13g2_nor2b_1)
     8    0.040654    0.534298    0.540130    2.434569 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y_A1_sg13g2_nand3_1_Y_C_sg13g2_o21ai_1_Y_A1_sg13g2_nor2b_1_A/Y (sg13g2_nor2b_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y_A1_sg13g2_nand3_1_Y_C_sg13g2_o21ai_1_Y_A1_sg13g2_nor2b_1_A_Y (net)
                      0.534340    0.004010    2.438579 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xnor2_1_Y_2_A_sg13g2_nand2_1_Y_A_sg13g2_nand3_1_Y_A_sg13g2_or2_1_X_A_sg13g2_nand3_1_Y_C_sg13g2_a22oi_1_Y/B1 (sg13g2_a22oi_1)
     2    0.009443    0.195229    0.274812    2.713392 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xnor2_1_Y_2_A_sg13g2_nand2_1_Y_A_sg13g2_nand3_1_Y_A_sg13g2_or2_1_X_A_sg13g2_nand3_1_Y_C_sg13g2_a22oi_1_Y/Y (sg13g2_a22oi_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xnor2_1_Y_2_A_sg13g2_nand2_1_Y_A_sg13g2_nand3_1_Y_A_sg13g2_or2_1_X_A_sg13g2_nand3_1_Y_C (net)
                      0.195229    0.000666    2.714058 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y/A (sg13g2_xnor2_1)
     2    0.010281    0.181064    0.236332    2.950390 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y/Y (sg13g2_xnor2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_xor2_1_X_B (net)
                      0.181064    0.000627    2.951017 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_xor2_1_X/B (sg13g2_xor2_1)
     2    0.011333    0.186502    0.276803    3.227820 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_xor2_1_X/X (sg13g2_xor2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y_B_sg13g2_xnor2_1_Y_B (net)
                      0.186502    0.000737    3.228557 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y_B_sg13g2_xnor2_1_Y/B (sg13g2_xnor2_1)
     2    0.009181    0.174544    0.213966    3.442523 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y_B_sg13g2_xnor2_1_Y/Y (sg13g2_xnor2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y_B (net)
                      0.174545    0.000893    3.443416 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y/A (sg13g2_xnor2_1)
     2    0.008938    0.164698    0.217249    3.660665 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B_sg13g2_xnor2_1_Y/Y (sg13g2_xnor2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X_B (net)
                      0.164698    0.000524    3.661189 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X/B (sg13g2_xor2_1)
     2    0.010110    0.141349    0.188614    3.849803 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_xor2_1_X/X (sg13g2_xor2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A (net)
                      0.141349    0.000448    3.850251 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_and3_1_C/C (sg13g2_and3_1)
     2    0.008226    0.060764    0.197967    4.048218 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xor2_1_X_A_sg13g2_and3_1_C/X (sg13g2_and3_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_xnor2_1_Y_3_B_sg13g2_a21oi_1_Y_A2 (net)
                      0.060767    0.000488    4.048707 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_nor2b_1_Y_B_N_sg13g2_o21ai_1_Y_A1_sg13g2_a221oi_1_Y/A1 (sg13g2_a221oi_1)
     2    0.015977    0.397658    0.390088    4.438794 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_nor2b_1_Y_B_N_sg13g2_o21ai_1_Y_A1_sg13g2_a221oi_1_Y/Y (sg13g2_a221oi_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_nor2b_1_Y_B_N_sg13g2_o21ai_1_Y_A1 (net)
                      0.397658    0.001106    4.439900 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_nor2b_1_Y_A_sg13g2_nor3_1_Y/C (sg13g2_nor3_2)
     2    0.008824    0.100933    0.141836    4.581737 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_nor2b_1_Y_A_sg13g2_nor3_1_Y/Y (sg13g2_nor3_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_nor2b_1_Y_A (net)
                      0.100935    0.000838    4.582574 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y_A2_sg13g2_a22oi_1_Y/A2 (sg13g2_a22oi_1)
     1    0.008237    0.163915    0.196021    4.778596 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y_A2_sg13g2_a22oi_1_Y/Y (sg13g2_a22oi_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y_A2 (net)
                      0.163915    0.000587    4.779183 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y/A1 (sg13g2_a21oi_2)
     2    0.033681    0.198275    0.238181    5.017364 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/m_mul/z_o_sg13g2_a21oi_1_Y/Y (sg13g2_a21oi_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/mz[15] (net)
                      0.198396    0.003015    5.020380 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/fanout150/A (sg13g2_buf_8)
     3    0.009361    0.036585    0.182094    5.202474 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/fanout150/X (sg13g2_buf_8)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/net150 (net)
                      0.036591    0.000964    5.203437 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/a_nzero_sg13g2_nand2_1_A_Y_sg13g2_nor2_1_B_Y_sg13g2_nand2b_1_B/A_N (sg13g2_nand2b_2)
     2    0.012628    0.099483    0.179943    5.383380 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/a_nzero_sg13g2_nand2_1_A_Y_sg13g2_nor2_1_B_Y_sg13g2_nand2b_1_B/Y (sg13g2_nand2b_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/a_nzero_sg13g2_nand2_1_A_Y_sg13g2_nor2_1_B_Y_sg13g2_nand2b_1_B_Y (net)
                      0.099534    0.000820    5.384200 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/e_o_sg13g2_xor2_1_X_A_sg13g2_or2_1_X/A (sg13g2_or2_1)
     2    0.009783    0.075975    0.217445    5.601645 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/e_o_sg13g2_xor2_1_X_A_sg13g2_or2_1_X/X (sg13g2_or2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/e_o_sg13g2_xor2_1_X_A (net)
                      0.075975    0.000320    5.601965 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/e_o_sg13g2_xor2_1_X/A (sg13g2_xor2_1)
     5    0.026197    0.366466    0.345537    5.947501 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_mul/e_o_sg13g2_xor2_1_X/X (sg13g2_xor2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/mul[8] (net)
                      0.366475    0.001559    5.949060 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer983/A (sg13g2_buf_1)
     1    0.003832    0.052847    0.210063    6.159123 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer983/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net983 (net)
                      0.052847    0.000148    6.159272 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_A_sg13g2_nand2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_a21oi_1_Y_A1_sg13g2_nand2b_1_Y/B (sg13g2_nand2b_1)
     2    0.009098    0.108518    0.127351    6.286623 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_A_sg13g2_nand2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_a21oi_1_Y_A1_sg13g2_nand2b_1_Y/Y (sg13g2_nand2b_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_A_sg13g2_nand2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_a21oi_1_Y_A1 (net)
                      0.108518    0.000552    6.287175 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_A_sg13g2_nand2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_a21oi_1_Y/A1 (sg13g2_a21oi_2)
     3    0.013947    0.129239    0.159165    6.446341 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_A_sg13g2_nand2_1_Y_B_sg13g2_xnor2_1_Y_B_sg13g2_a21oi_1_Y/Y (sg13g2_a21oi_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_A_sg13g2_nand2_1_Y_B_sg13g2_xnor2_1_Y_B (net)
                      0.129241    0.000711    6.447052 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_C_sg13g2_mux2_1_X_A1_sg13g2_xnor2_1_Y_B_sg13g2_nor2b_1_Y_B_N_sg13g2_nand2b_1_Y/B (sg13g2_nand2b_1)
     2    0.006702    0.092201    0.139211    6.586263 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_C_sg13g2_mux2_1_X_A1_sg13g2_xnor2_1_Y_B_sg13g2_nor2b_1_Y_B_N_sg13g2_nand2b_1_Y/Y (sg13g2_nand2b_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_C_sg13g2_mux2_1_X_A1_sg13g2_xnor2_1_Y_B_sg13g2_nor2b_1_Y_B_N (net)
                      0.092201    0.000358    6.586621 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_C_sg13g2_mux2_1_X_A1_sg13g2_xnor2_1_Y_B_sg13g2_nor2b_1_Y_B_N_sg13g2_a221oi_1_A1/A1 (sg13g2_a221oi_1)
     2    0.013635    0.361187    0.370588    6.957209 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_C_sg13g2_mux2_1_X_A1_sg13g2_xnor2_1_Y_B_sg13g2_nor2b_1_Y_B_N_sg13g2_a221oi_1_A1/Y (sg13g2_a221oi_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_Y_sg13g2_nand4_1_B_C_sg13g2_nand3_1_Y_C_sg13g2_and4_1_X_C_sg13g2_mux2_1_X_A1_sg13g2_xnor2_1_Y_B_sg13g2_nor2b_1_Y_B_N_sg13g2_a221oi_1_A1_Y (net)
                      0.361338    0.002373    6.959582 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_C_sg13g2_nor2_1_Y_B_sg13g2_nor2_1_A_B_sg13g2_o21ai_1_Y_A2_sg13g2_a22oi_1_Y_B1_sg13g2_nand2_1_Y_A_sg13g2_or2_1_A_B_sg13g2_o21ai_1_A2/A2 (sg13g2_o21ai_1)
     2    0.011680    0.166404    0.247175    7.206757 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_C_sg13g2_nor2_1_Y_B_sg13g2_nor2_1_A_B_sg13g2_o21ai_1_Y_A2_sg13g2_a22oi_1_Y_B1_sg13g2_nand2_1_Y_A_sg13g2_or2_1_A_B_sg13g2_o21ai_1_A2/Y (sg13g2_o21ai_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_C_sg13g2_nor2_1_Y_B_sg13g2_nor2_1_A_B_sg13g2_o21ai_1_Y_A2_sg13g2_a22oi_1_Y_B1_sg13g2_nand2_1_Y_A_sg13g2_or2_1_A_B_sg13g2_o21ai_1_A2_Y (net)
                      0.166404    0.000454    7.207211 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer960/A (sg13g2_buf_2)
     2    0.014320    0.058244    0.190656    7.397867 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer960/X (sg13g2_buf_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net960 (net)
                      0.058332    0.001955    7.399822 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_C_sg13g2_nor2_1_Y_B_sg13g2_nor2_1_A_B_sg13g2_o21ai_1_Y_A2_sg13g2_a22oi_1_Y_B1_sg13g2_nand2_1_Y_A_sg13g2_or2_1_A_X_sg13g2_nand2_1_B/A (sg13g2_nand2_2)
     3    0.021448    0.088046    0.090612    7.490433 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_C_sg13g2_nor2_1_Y_B_sg13g2_nor2_1_A_B_sg13g2_o21ai_1_Y_A2_sg13g2_a22oi_1_Y_B1_sg13g2_nand2_1_Y_A_sg13g2_or2_1_A_X_sg13g2_nand2_1_B/Y (sg13g2_nand2_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[7]_sg13g2_nor2b_1_Y_B_N_sg13g2_nand3_1_A_C_sg13g2_nor2_1_Y_B_sg13g2_nor2_1_A_B_sg13g2_o21ai_1_Y_A2_sg13g2_a22oi_1_Y_B1_sg13g2_nand2_1_Y_A_sg13g2_or2_1_A_X_sg13g2_nand2_1_B_Y (net)
                      0.088096    0.001661    7.492094 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/fanout137/A (sg13g2_buf_8)
     5    0.024020    0.040966    0.136542    7.628637 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/fanout137/X (sg13g2_buf_8)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net137 (net)
                      0.041003    0.002164    7.630800 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[9]_sg13g2_xor2_1_X_A_sg13g2_xnor2_1_Y_A_sg13g2_o21ai_1_Y_A2_sg13g2_o21ai_1_Y/A1 (sg13g2_o21ai_1)
     2    0.006078    0.089084    0.116358    7.747158 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[9]_sg13g2_xor2_1_X_A_sg13g2_xnor2_1_Y_A_sg13g2_o21ai_1_Y_A2_sg13g2_o21ai_1_Y/Y (sg13g2_o21ai_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[9]_sg13g2_xor2_1_X_A_sg13g2_xnor2_1_Y_A_sg13g2_o21ai_1_Y_A2 (net)
                      0.089085    0.000428    7.747586 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[9]_sg13g2_xor2_1_X_A_sg13g2_xnor2_1_Y_A_sg13g2_o21ai_1_Y/A1 (sg13g2_o21ai_1)
     3    0.016239    0.286329    0.291990    8.039577 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[9]_sg13g2_xor2_1_X_A_sg13g2_xnor2_1_Y_A_sg13g2_o21ai_1_Y/Y (sg13g2_o21ai_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[9]_sg13g2_xor2_1_X_A_sg13g2_xnor2_1_Y_A (net)
                      0.286341    0.001517    8.041094 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[10]_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X_A0_sg13g2_and2_1_X_A_sg13g2_o21ai_1_B1_A2_sg13g2_nor2b_1_Y/B_N (sg13g2_nor2b_1)
     1    0.003823    0.086164    0.238972    8.280066 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[10]_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X_A0_sg13g2_and2_1_X_A_sg13g2_o21ai_1_B1_A2_sg13g2_nor2b_1_Y/Y (sg13g2_nor2b_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[10]_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X_A0_sg13g2_and2_1_X_A_sg13g2_o21ai_1_B1_A2 (net)
                      0.086164    0.000152    8.280217 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[10]_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X_A0_sg13g2_and2_1_X_A_sg13g2_o21ai_1_B1/A1 (sg13g2_o21ai_1)
     2    0.014639    0.168724    0.198328    8.478546 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[10]_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X_A0_sg13g2_and2_1_X_A_sg13g2_o21ai_1_B1/Y (sg13g2_o21ai_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[10]_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X_A1 (net)
                      0.168731    0.000930    8.479476 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y_A_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X_A1_sg13g2_o21ai_1_Y/A1 (sg13g2_o21ai_1)
     2    0.013726    0.261911    0.296097    8.775573 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y_A_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X_A1_sg13g2_o21ai_1_Y/Y (sg13g2_o21ai_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y_A_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X_A1 (net)
                      0.261917    0.000979    8.776551 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1204/A (sg13g2_buf_1)
     1    0.005419    0.056992    0.190515    8.967067 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1204/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1204 (net)
                      0.056992    0.000385    8.967451 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1166/A (sg13g2_buf_1)
     1    0.005662    0.050880    0.115763    9.083215 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1166/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1166 (net)
                      0.050881    0.000340    9.083554 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1165/A (sg13g2_buf_1)
     1    0.012654    0.092807    0.144007    9.227561 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1165/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1165 (net)
                      0.092824    0.001228    9.228789 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1164/A (sg13g2_buf_1)
     1    0.002777    0.035572    0.121445    9.350235 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1164/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1164 (net)
                      0.035572    0.000203    9.350438 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1163/A (sg13g2_buf_1)
     1    0.003011    0.035180    0.092453    9.442891 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1163/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1163 (net)
                      0.035180    0.000218    9.443109 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1162/A (sg13g2_buf_1)
     1    0.003860    0.039979    0.096120    9.539228 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1162/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1162 (net)
                      0.039980    0.000235    9.539464 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1161/A (sg13g2_buf_1)
     1    0.011187    0.083685    0.131705    9.671169 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1161/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1161 (net)
                      0.083697    0.001013    9.672182 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1160/A (sg13g2_buf_1)
     1    0.010772    0.081728    0.152820    9.825003 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1160/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1160 (net)
                      0.081742    0.001073    9.826076 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1159/A (sg13g2_buf_1)
     1    0.003051    0.036773    0.116872    9.942947 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1159/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1159 (net)
                      0.036773    0.000232    9.943179 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1158/A (sg13g2_buf_1)
     1    0.002497    0.032302    0.090747   10.033926 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1158/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1158 (net)
                      0.032302    0.000187   10.034113 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1157/A (sg13g2_buf_1)
     1    0.010372    0.078440    0.124002   10.158115 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1157/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1157 (net)
                      0.078451    0.000957   10.159073 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1156/A (sg13g2_buf_1)
     1    0.011839    0.088061    0.154857   10.313930 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1156/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1156 (net)
                      0.088076    0.001159   10.315088 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1146/A (sg13g2_buf_1)
     1    0.008578    0.068783    0.145437   10.460526 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/rebuffer1146/X (sg13g2_buf_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net1146 (net)
                      0.068783    0.000318   10.460844 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y_A_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X/A1 (sg13g2_mux2_1)
     1    0.006050    0.064098    0.170691   10.631536 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y_A_sg13g2_xor2_1_X_B_sg13g2_mux2_1_X/X (sg13g2_mux2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y_A_sg13g2_xor2_1_X_B (net)
                      0.064098    0.000249   10.631783 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y_A_sg13g2_xor2_1_X/B (sg13g2_xor2_1)
     1    0.016214    0.242254    0.273523   10.905306 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y_A_sg13g2_xor2_1_X/X (sg13g2_xor2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y_A (net)
                      0.242258    0.000764   10.906070 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y/A (sg13g2_inv_4)
     2    0.012637    0.060150    0.085901   10.991971 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11]_sg13g2_inv_1_Y/Y (sg13g2_inv_4)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/lzc_data[11] (net)
                      0.060152    0.000731   10.992702 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_leaf_lzc[5].m_leaf_lzc/cnt_o_sg13g2_nor2_1_Y/A (sg13g2_nor2_2)
     3    0.009911    0.109778    0.115994   11.108697 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_leaf_lzc[5].m_leaf_lzc/cnt_o_sg13g2_nor2_1_Y/Y (sg13g2_nor2_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/leaf_lzc[11] (net)
                      0.109779    0.000487   11.109183 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_inner_lzc_lvl[2].g_inner_lzc_span[2].m_inner_lzc/next_o_sg13g2_and2_1_X/B (sg13g2_and2_1)
     2    0.008727    0.074394    0.189103   11.298286 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_inner_lzc_lvl[2].g_inner_lzc_span[2].m_inner_lzc/next_o_sg13g2_and2_1_X/X (sg13g2_and2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/lzc_tree[1][8] (net)
                      0.074394    0.000211   11.298497 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_inner_lzc_lvl[3].g_inner_lzc_span[1].m_inner_lzc/next_o_sg13g2_and2_1_X/A (sg13g2_and2_2)
     5    0.019474    0.086865    0.204727   11.503224 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_inner_lzc_lvl[3].g_inner_lzc_span[1].m_inner_lzc/next_o_sg13g2_and2_1_X/X (sg13g2_and2_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/lzc_tree[2][7] (net)
                      0.086888    0.001352   11.504577 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_inner_lzc_lvl[4].g_inner_lzc_span[0].m_inner_lzc/next_o_sg13g2_nor2b_1_Y/B_N (sg13g2_nor2b_2)
     2    0.012985    0.107510    0.213213   11.717790 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_inner_lzc_lvl[4].g_inner_lzc_span[0].m_inner_lzc/next_o_sg13g2_nor2b_1_Y/Y (sg13g2_nor2b_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc_cnt_o (net)
                      0.107510    0.000446   11.718236 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/fanout30/A (sg13g2_buf_8)
     8    0.030996    0.046479    0.150537   11.868773 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/fanout30/X (sg13g2_buf_8)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net30 (net)
                      0.046479    0.000397   11.869170 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_inner_lzc_lvl[4].g_inner_lzc_span[0].m_inner_lzc/next_o_sg13g2_a21o_1_X_2/A1 (sg13g2_a21o_1)
     2    0.012628    0.099061    0.196897   12.066067 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_lzc/g_inner_lzc_lvl[4].g_inner_lzc_span[0].m_inner_lzc/next_o_sg13g2_a21o_1_X_2/X (sg13g2_a21o_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/zero_cnt[0] (net)
                      0.099078    0.001314   12.067380 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/fanout22/A (sg13g2_buf_8)
     2    0.011364    0.032797    0.135071   12.202451 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/fanout22/X (sg13g2_buf_8)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/net22 (net)
                      0.032801    0.000754   12.203205 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_5_B1_sg13g2_nand3b_1_Y_C_sg13g2_nand3_1_Y_C_sg13g2_a21oi_1_B1/A1 (sg13g2_a21oi_2)
     2    0.010224    0.124593    0.092377   12.295582 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_5_B1_sg13g2_nand3b_1_Y_C_sg13g2_nand3_1_Y_C_sg13g2_a21oi_1_B1/Y (sg13g2_a21oi_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_5_B1_sg13g2_nand3b_1_Y_A_N (net)
                      0.124594    0.000654   12.296235 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_4_B1_sg13g2_nand3_1_Y_A_sg13g2_o21ai_1_Y/A1 (sg13g2_o21ai_1)
     2    0.009574    0.192967    0.233694   12.529929 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_4_B1_sg13g2_nand3_1_Y_A_sg13g2_o21ai_1_Y/Y (sg13g2_o21ai_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_4_B1_sg13g2_nand3_1_Y_A (net)
                      0.192967    0.000635   12.530564 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_4_B1_sg13g2_nand3_1_Y_A_sg13g2_o21ai_1_B1/B1 (sg13g2_o21ai_1)
     2    0.010394    0.141092    0.175187   12.705751 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_4_B1_sg13g2_nand3_1_Y_A_sg13g2_o21ai_1_B1/Y (sg13g2_o21ai_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_3_B1_sg13g2_nand2_1_Y_B_sg13g2_xor2_1_X_A (net)
                      0.141092    0.000587   12.706339 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_3_B1_sg13g2_nand2_1_Y_B_sg13g2_xor2_1_X_A_sg13g2_a21oi_1_A1/A1 (sg13g2_a21oi_2)
     2    0.013734    0.133042    0.168689   12.875028 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_3_B1_sg13g2_nand2_1_Y_B_sg13g2_xor2_1_X_A_sg13g2_a21oi_1_A1/Y (sg13g2_a21oi_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_2_B1_sg13g2_nand2_1_Y_B_sg13g2_xor2_1_X_B (net)
                      0.133048    0.000985   12.876013 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_B1_sg13g2_o21ai_1_Y_A2_sg13g2_nand2b_1_Y/B (sg13g2_nand2b_1)
     2    0.009024    0.112847    0.157987   13.033999 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_B1_sg13g2_o21ai_1_Y_A2_sg13g2_nand2b_1_Y/Y (sg13g2_nand2b_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_B1_sg13g2_o21ai_1_Y_A2 (net)
                      0.112848    0.000617   13.034616 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_a22oi_1_Y_A2_sg13g2_nor2_1_Y/B (sg13g2_nor2_2)
     2    0.010037    0.129454    0.122599   13.157215 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_a22oi_1_Y_A2_sg13g2_nor2_1_Y/Y (sg13g2_nor2_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_a22oi_1_Y_A2 (net)
                      0.129456    0.000729   13.157945 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_a22oi_1_Y_A2_sg13g2_a21oi_1_A2/A1 (sg13g2_a21oi_2)
     6    0.038321    0.226596    0.239178   13.397123 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_a22oi_1_Y_A2_sg13g2_a21oi_1_A2/Y (sg13g2_a21oi_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_a22oi_1_Y_A2_sg13g2_a21oi_1_A2_Y (net)
                      0.226681    0.004064   13.401187 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_4_B1_sg13g2_nand3_1_Y/A (sg13g2_nand3_1)
     2    0.008719    0.109243    0.148932   13.550119 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_4_B1_sg13g2_nand3_1_Y/Y (sg13g2_nand3_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_4_B1 (net)
                      0.109245    0.000603   13.550723 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_B1_sg13g2_nand4_1_D/C (sg13g2_nand4_1)
     1    0.005798    0.174014    0.223576   13.774299 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_B1_sg13g2_nand4_1_D/Y (sg13g2_nand4_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_B1_sg13g2_nand4_1_D_Y (net)
                      0.174015    0.000235   13.774534 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_B1_sg13g2_nand4_1_D_Y_sg13g2_nor2_1_B/A (sg13g2_nor2_2)
     1    0.009411    0.111626    0.153356   13.927890 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_B1_sg13g2_nand4_1_D_Y_sg13g2_nor2_1_B/Y (sg13g2_nor2_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/e_o_sg13g2_a221oi_1_Y_B1_sg13g2_nand4_1_D_Y_sg13g2_nor2_1_B_Y (net)
                      0.111629    0.000735   13.928624 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_nand2b_1_Y_B_sg13g2_nor3_1_Y/B (sg13g2_nor3_2)
     2    0.006476    0.067364    0.088217   14.016841 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_nand2b_1_Y_B_sg13g2_nor3_1_Y/Y (sg13g2_nor3_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_nand2b_1_Y_B (net)
                      0.067365    0.000369   14.017210 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_nand2b_1_Y_B_sg13g2_and2_1_B/A (sg13g2_and2_2)
     6    0.026340    0.090814    0.186656   14.203866 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_nand2b_1_Y_B_sg13g2_and2_1_B/X (sg13g2_and2_2)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2b_1_Y_B_N_sg13g2_a21oi_1_Y_A2_sg13g2_nand2b_1_Y_B_sg13g2_and2_1_B_X (net)
                      0.090824    0.000977   14.204843 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2_1_Y_5_B_sg13g2_a22oi_1_Y/A2 (sg13g2_a22oi_1)
     1    0.011356    0.207089    0.220144   14.424987 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2_1_Y_5_B_sg13g2_a22oi_1_Y/Y (sg13g2_a22oi_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2_1_Y_5_B (net)
                      0.207090    0.000919   14.425906 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2_1_Y_5/B (sg13g2_nor2_1)
     1    0.003665    0.085118    0.099289   14.525195 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[0].m_unit/m_add/m_o_sg13g2_nor2_1_Y_5/Y (sg13g2_nor2_1)
                                                         m_2x2_systolic_mac/data_top_unit[2][1] (net)
                      0.085118    0.000255   14.525450 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[1].m_unit/add_q[1]_sg13g2_mux2_1_A0/A1 (sg13g2_mux2_1)
     1    0.001939    0.052074    0.182911   14.708361 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[1].m_unit/add_q[1]_sg13g2_mux2_1_A0/X (sg13g2_mux2_1)
                                                         m_2x2_systolic_mac/g_unit_x[0].g_unit_y[1].m_unit/add_q[1]_sg13g2_dfrbpq_1_Q_D (net)
                      0.052074    0.000070   14.708430 v m_2x2_systolic_mac/g_unit_x[0].g_unit_y[1].m_unit/add_q[1]_sg13g2_dfrbpq_1_Q/D (sg13g2_dfrbpq_1)
                                             14.708430   data arrival time

                                 10.000000   10.000000   clock clk (rise edge)
                                  0.000000   10.000000   clock source latency
     1    0.033548    0.075206    0.044770   10.044769 ^ clk (in)
                                                         clk (net)
                      0.075474    0.000000   10.044769 ^ clkbuf_0_clk/A (sg13g2_buf_16)
     4    0.109699    0.062922    0.144207   10.188977 ^ clkbuf_0_clk/X (sg13g2_buf_16)
                                                         clknet_0_clk (net)
                      0.064465    0.007387   10.196364 ^ clkbuf_2_0__f_clk/A (sg13g2_buf_16)
     6    0.104396    0.060539    0.137210   10.333574 ^ clkbuf_2_0__f_clk/X (sg13g2_buf_16)
                                                         clknet_2_0__leaf_clk (net)
                      0.061405    0.005387   10.338961 ^ clkbuf_leaf_0_clk/A (sg13g2_buf_8)
    10    0.068270    0.071605    0.147206   10.486167 ^ clkbuf_leaf_0_clk/X (sg13g2_buf_8)
                                                         clknet_leaf_0_clk (net)
                      0.071893    0.003251   10.489418 ^ m_2x2_systolic_mac/g_unit_x[0].g_unit_y[1].m_unit/add_q[1]_sg13g2_dfrbpq_1_Q/CLK (sg13g2_dfrbpq_1)
                                 -0.250000   10.239418   clock uncertainty
                                  0.000000   10.239418   clock reconvergence pessimism
                                 -0.175393   10.064025   library setup time
                                             10.064025   data required time
---------------------------------------------------------------------------------------------
                                             10.064025   data required time
                                            -14.708430   data arrival time
---------------------------------------------------------------------------------------------
                                             -4.644406   slack (VIOLATED)
```

What a chunker ... 

Well, this wasn't unexpected, and improving latency on the close path by replacing the 
classic leading zero count (LZC) by a more optimized leading zero anticipation logic (LZA), we 
already on the potenciel plans in case timing needed to be improved. 

But, before implementing the LZA, and paying the cost in additional logic, I want to revisit the 
existing logic and see what I can improve. 

### Improving existing logic

#### Multiplier 

Looking at this cirtical path, we can see that in the multiplier the propagation time is mainly occupied 
by going though the multiplier. I higly doubt that a hand written booth radix 4 multiplier
would performe substantially better than yosys's process aware synthesized multiplier, so 
I am not considering the multiplier as an area on which I can save significant time. 

We can note how, before reaching the booth multiplier I have a dependacy on the `b_nzero` net. This is 
for determining the value of the hidden 1 to properly handle the case when one of the inputs is zero. 
Exept ... I can also handle this after the mantissa multiplication, which I do as part of the 
subnormal rounding to zero. So I can start by removing this dependancy saving me up to ~,,9ns. 

```
-assign {ma, mb} = {{a_nzero, ma_i}, {b_nzero, mb_i}}; // hidden bit is 0 on 0.0
+assign {ma, mb} = {{1'b1, ma_i}, {1'b1, mb_i}}; // zero case will be handled by zero masked on output
```

### Adder 

Now to tackle the adder where most of the propagation time is used up ~8.5ns, hopefully this should give me as 
much opportunities for optimization. 

#### Close path: mantissa shifter 

Going into the adder, the first critical path exits from the lsb of the exponent to the lsb of the shifted mantissa
before the LZC. It looks like the path used to select the shift amount based on the difference
between the two exponents. If the exponents are equal we don't shift, and if there difference is one we shift by one. 
Looking I the code I was using the carry bit of both of the exponent comparisons to determine equality ... I can do better... 

This will cost a bit more logic to do the comparison but we are not longer at the end 2 8 bit adders 
and since we are checking for equality, we no longer care about the swapped exponent version.  
```
-assign exy_eq = ~eab_diff_carry & ~eba_diff_carry; // 1 = equal, 0 = not equal
+assign exy_eq = ea_i == eb_i; // 1 = equal, 0 = not equal, also don't care about swap if they are equal
``` 

#### Close path: Mantissa denormal to zero

At the end of the worst path we also have the mantissa masking to zero on denormals. 
The critical path passes though an or reduction of the normalized exponent that is used in the masking, 
the strategy to fix this is going to be to pre-identify the conditions where the exponent would 
go to zero and use this for masking. 

```
-assign mz_cp_norm = {M{~(exy_eq | ~|ez_cp_norm) }} & mz_cp_norm_lite[M:1];
+logic ex_eq_zero_cnt;
+assign ex_eq_zero_cnt = ~|ex[E-1:LZC_W] & (ex[LZC_W-1:0] == zero_cnt);
+assign mz_cp_norm = {M{~(xy_eq | ex_eq_zero_cnt |ez_cp_underflow) }} & mz_cp_norm_lite[M:1];// critical path through underflow
```

#### Results 

So close ...just a bit more  
 
```
┏━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━┳━━━━━━━━━━┓
┃                      ┃ Hold     ┃ Reg to   ┃          ┃          ┃ of which  ┃ Setup    ┃           ┃          ┃           ┃ of which ┃           ┃          ┃
┃                      ┃ Worst    ┃ Reg      ┃          ┃ Hold Vio ┃ reg to    ┃ Worst    ┃ Reg to    ┃ Setup    ┃ Setup Vio ┃ reg to   ┃ Max Cap   ┃ Max Slew ┃
┃ Corner/Group         ┃ Slack    ┃ Paths    ┃ Hold TNS ┃ Count    ┃ reg       ┃ Slack    ┃ Reg Paths ┃ TNS      ┃ Count     ┃ reg      ┃ Violatio… ┃ Violati… ┃
┡━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━╇━━━━━━━━━━┩
│ Overall              │ 0.1139   │ 0.1139   │ 0.0000   │ 0        │ 0         │ -0.3224  │ -0.3224   │ -1.3166  │ 10        │ 10       │ 0         │ 0        │
│ nom_fast_1p32V_m40C  │ 0.1139   │ 0.1139   │ 0.0000   │ 0        │ 0         │ 5.5460   │ 5.5460    │ 0.0000   │ 0         │ 0        │ 0         │ 0        │
│ nom_slow_1p08V_125C  │ 0.4157   │ 0.4157   │ 0.0000   │ 0        │ 0         │ -0.3224  │ -0.3224   │ -1.3166  │ 10        │ 10       │ 0         │ 0        │
│ nom_typ_1p20V_25C    │ 0.2636   │ 0.2636   │ 0.0000   │ 0        │ 0         │ 3.3592   │ 3.3592    │ 0.0000   │ 0         │ 0        │ 0         │ 0        │
└──────────────────────┴──────────┴──────────┴──────────┴──────────┴───────────┴──────────┴───────────┴──────────┴───────────┴──────────┴───────────┴──────────┘
```



