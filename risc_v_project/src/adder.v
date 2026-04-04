module adder( 
    input wire [31:0] a, b,
    output wire [31:0] sum 
);
    assign sum = a+b;
endmodule