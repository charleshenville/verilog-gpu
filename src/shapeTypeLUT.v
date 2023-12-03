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
    output reg [47:0] v11,
	 output reg [3:0] numVerticies   
);

always @(*) begin
    case (shapeselect)
        1: begin
            // Assign values for case 1
				v0 <= {16'h0, 16'h0, 16'h0200}; // 4,6,3,5
            v1 <= {16'h0, 16'h0, 16'hFE00}; // 6 4 3 5
            v2 <= {16'h0, 16'h0200, 16'h0}; // 2 5 1 6
            v3 <= {16'h0, 16'hFE00, 16'h0}; // 2 5 1 6
            v4 <= {16'h0200, 16'h0, 16'h0}; // 4 1 2 3
            v5 <= {16'hFE00, 16'h0, 16'h0}; //
            v6 <= 48'b0;
            v7 <= 48'b0;
            v8 <= 48'b0;
            v9 <= 48'b0;
            v10 <= 48'b0;
            v11 <= 48'b0;
				numVerticies <= 6;
        end

         2: begin
            // Assign values for case 2
				v0 <= {16'hFE00, 16'hFE00, 16'hFE00}; //3,4,2
            v1 <= {16'hFE00, 16'hFE00, 16'h0200}; //8,6,1
            v2 <= {16'hFE00, 16'h0200, 16'hFE00}; //5,1,8
            v3 <= {16'h0200, 16'hFE00, 16'hFE00}; //5,1,6
            v4 <= {16'h0200, 16'h0200, 16'hFE00}; //4,3,7
            v5 <= {16'h0200, 16'hFE00, 16'h0200}; //2,7,4
            v6 <= {16'h0200, 16'h0200, 16'h0200}; //5,8,6
            v7 <= {16'hFE00, 16'h0200, 16'h0200}; //2,7,3
            v8 <= 48'b0;
            v9 <= 48'b0;
            v10 <= 48'b0;
            v11 <= 48'b0;
				numVerticies <= 8;
        end

			3: begin
            // Assign values for case 3
			   v0 <= {16'h0200, 16'h0, 16'h0}; //6, 5, 2, 3, 4
            v1 <= {16'h00E5, 16'h01CA, 16'h0}; // 6, 10, 11, 3, 1
            v2 <= {16'h00E5, 16'h008E, 16'h01B4}; //4, 1, 2, 11, 12
            v3 <= {16'h00E5, 16'hFE8E, 16'h010D}; //8, 12, 3, 1, 5
            v4 <= {16'h00E5, 16'hFE8E, 16'hFEF3}; // 4, 1, 8, 6, 9
            v5 <= {16'h00E5, 16'h008E, 16'hFE4C}; // 9, 10, 2, 1, 5
            v6 <= {16'hFE00, 16'h0, 16'h0}; // 8, 9, 10, 11, 12
            v7 <= {16'hFF1B, 16'hFE36, 16'h0}; // 7, 9, 5, 4, 12
            v8 <= {16'hFF1B, 16'hFF73, 16'hFE4C}; //5 6 10 7 8
            v9 <= {16'hFF1B, 16'h0172, 16'hFEF3}; //7 9 8 2 11
//				v8 <= {16'h0001, 16'hFF73, 16'h0001}; //5 6 10 7 8
//          v9 <= {16'h0001, 16'h0172, 16'h0001}; //7 9 8 2 11
            v10 <= {16'hFF1B, 16'h0172, 16'h010D}; //12 7 3 2 10
            v11 <= {16'hFF1B, 16'hFF73, 16'h01B4}; // 4 8 7 2 3
				numVerticies <= 12;
        end
        default: begin
            
            v0 <= {16'h0, 16'h0, 16'h01A2};
				v1 <= {16'hFE00, 16'hFED8, 16'hFE5E};
            v2 <= {16'h0200, 16'hFED8, 16'hFE5E};
				v3 <= {16'h0, 16'h024F, 16'hFE5E};
            v4 <= 48'b0;
            v5 <= 48'b0;
            v6 <= 48'b0;
            v7 <= 48'b0;
            v8 <= 48'b0;
            v9 <= 48'b0;
            v10 <= 48'b0;
            v11 <= 48'b0;
				numVerticies <= 4;
        end
    endcase
end

endmodule