module gpu ();


endmodule

module shapeTypeLUT (
    input wire [1:0] shapeselect,
    output reg [47:0] v0,
    output reg [47:0] v1,
    output reg [47:0] v2,
    output reg [47:0] v3,
    output reg [47:0] v4,
    output reg [47:0] v5,
    output reg [47:0] v6,
    output reg [47:0] v7,
    output reg [47:0] v8,
    output reg [47:0] v9,
    output reg [47:0] v10,
    output reg [47:0] v11
);

always @(*) begin
    case (shapeselect)
        1: begin
            // Assign values for case 1
				v0 <= 48'h0; 
            v1 <= 48'h0;
            v2 <= 48'h0;
            v3 <= 48'h0;
            v4 <= 48'b0;
            v5 <= 48'b0;
            v6 <= 48'b0;
            v7 <= 48'b0;
            v8 <= 48'b0;
            v9 <= 48'b0;
            v10 <= 48'b0;
            v11 <= 48'b0;
        end
        2: begin
            // Assign values for case 2
				v0 <= 48'h0; 
            v1 <= 48'h0;
            v2 <= 48'h0;
            v3 <= 48'h0;
            v4 <= 48'b0;
            v5 <= 48'b0;
            v6 <= 48'b0;
            v7 <= 48'b0;
            v8 <= 48'b0;
            v9 <= 48'b0;
            v10 <= 48'b0;
            v11 <= 48'b0;
        end
        3: begin
            // Assign values for case 3
				v0 <= 48'h0; 
            v1 <= 48'h0;
            v2 <= 48'h0;
            v3 <= 48'h0;
            v4 <= 48'b0;
            v5 <= 48'b0;
            v6 <= 48'b0;
            v7 <= 48'b0;
            v8 <= 48'b0;
            v9 <= 48'b0;
            v10 <= 48'b0;
            v11 <= 48'b0;
        end
        default: begin
            
            v0 <= {16'h0, 16'h0, 16'h0330};
				v1 <= {16'hFFFF, 16'hFDBF, 16'hFCD0};
            v2 <= {16'h0001, 16'hFDBF, 16'hFCD0};
				v3 <= {16'h0, 16'h0483, 16'hFCD0};
            v4 <= 48'b0;
            v5 <= 48'b0;
            v6 <= 48'b0;
            v7 <= 48'b0;
            v8 <= 48'b0;
            v9 <= 48'b0;
            v10 <= 48'b0;
            v11 <= 48'b0;
        end
    endcase
end

endmodule

