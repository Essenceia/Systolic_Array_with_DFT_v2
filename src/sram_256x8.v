/* SRAM wrapper

IHP SRAM Macro
Single port 256x64 wide SRAM, single cycle access
Dissconnecting all build in self testing for this experiement

If both read and write are enabled at the same time, the write address will be used. 

P.S: I have no idea whay RM stands for

# Macro Interface Signal List


Signal              Sensitivity                 Logic            Direction     Description
------              -----------                 -----            ---------     -----------
A_ADDR[7:0]         Positive Clock Edge         Positive         Input         8 address bits  
A_DIN[7:0]          Positive Clock Edge         Positive         Input         8 data bits 
A_BM[7:0]           Positive Clock Edge         Positive         Input         8 bit mask bits   
A_WEN               Positive Clock Edge         Positive         Input         Write-enable  
A_MEN               Positive Clock Edge         Positive         Input         Memory enable -> if disabled, the memory is deactivated   
A_REN               Positive Clock Edge         Positive         Input         Read enable 
A_CLK               Clock                       Positive         Input         Clock pin   
A_BIST_DIN[7:0]     Positive Clock Edge         Positive         Input         8 data bits 
A_BIST_BM[7:0]      Positive Clock Edge         Positive         Input         8 bit mask bits   
A_BIST_ADDR[7:0]    Positive Clock Edge         Positive         Input         8 address bits for BIST mode  
A_BIST_WEN          Positive Clock Edge         Positive         Input         BIST Write-enable   
A_BIST_MEN          Positive Clock Edge         Positive         Input         BIST Memory enable -> if disabled, the memory is deactivated  
A_BIST_REN          Positive Clock Edge         Positive         Input         BIST Read enable  
A_BIST_CLK          Clock                       Positive         Input         BIST Clock pin  
A_BIST_EN           Positive Clock Edge         Positive         Input         BIST Enable pin 
A_DOUT[7:0]         Positive Clock Edge         Positive         Output        8 data bits, no high impedance function   
A_DLY               Level                       Positive         Input         Delay setting, adjustment of memory internal timings; MANDATORY setting: Tie to 1

VDD                                                                            Macro support logic supply voltage
VSS                                                                            Macro support logic ground
VDDARRAY                                                                       Memory array supply voltage
*/
module sram_256x8 (
	input wire clk,
	input wire mem_en_i, // enable memory, will use for dynamic power
 
	/* write */
	input wire w_en_i,
	input wire [7:0] w_addr_i,
	input wire [7:0] w_data_i, 
	

	/* read */
	input wire r_en_i,
	input wire [7:0] r_addr_i, 
	output wire [7:0] r_data_o
	
); 
wire [7:0] addr;

assign addr = w_en_i ? w_addr_i: r_addr_i; 

RM_IHPSG13_1P_256x64_c2_bm_bis m_ihp_sram (

`ifdef USE_POWER_PINS
	.VDD(VPWR), // logic supply voltage
	.VSS(VGND), // logic ground
	.VDDARRAY(VPWR), // memory array supply voltage
`endif

    .A_CLK(clk),
    .A_MEN(mem_en_i),
    .A_WEN(w_en_i),
    .A_REN(r_en_i),
    .A_ADDR(addr),
    .A_DIN(w_data_i),
    .A_DLY(1'b1),
    .A_DOUT(r_data_o),
    .A_BM(8'hFF),
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN{1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);

endmodule 
