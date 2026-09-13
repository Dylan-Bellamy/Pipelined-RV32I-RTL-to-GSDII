/*
Hazard Unit
*/
module hazard(
    // Forwarding Unit
    input wire [4:0] rs1E,
    input wire [4:0] rs2E,
    input wire RegWriteM,
    input wire [4:0] write_regM,
    input wire RegWriteW,
    input wire [4:0] write_regW,
    output reg [1:0] forwardAE,
    output reg [1:0] forwardBE,
    
    // Stall Unit
    input wire [4:0] rs1D,       
    input wire [4:0] rs2D,  
    input wire [4:0] rdE,           
    input wire [1:0] ResultSrcE,
    output reg stallF,   
    output reg stallD,
     
    // Flush 
	input wire PCSrcE,
	output reg flushD,
	output reg flushE
);
    wire lwStall;
    
    assign lwStall = (ResultSrcE == 2'b01) && ((rs1D == rdE) || (rs2D == rdE));
    
    always @(*) begin
        // Forwarding Unit
        if (RegWriteM && (write_regM != 0) && (write_regM == rs1E)) 
            forwardAE = 2'b10;
        else if (RegWriteW && (write_regW != 0) && (write_regW == rs1E))    
            forwardAE = 2'b01;
        else forwardAE = 2'b00;
        
        if (RegWriteM && (write_regM != 0) && (write_regM == rs2E))
            forwardBE = 2'b10;    
        else if (RegWriteW && (write_regW != 0) && (write_regW == rs2E))    
            forwardBE = 2'b01;
        else forwardBE = 2'b00;
        
        // Stall Unit
        stallF = lwStall;
        stallD = lwStall;
        
        // Flush
        flushD = PCSrcE; // Flush Decode Stage when branch is taken
        
        // Flush Execute Stage if
        // a) When a Load-Use Stall is happening
        // b) When a branch is taken
        flushE = lwStall || PCSrcE;
	end
endmodule