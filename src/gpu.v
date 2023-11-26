
module gpu (
                CLOCK_50,                                               //      On Board 50 MHz
                // Your inputs and outputs here
                SW,
                KEY,                                                    // On Board Keys
                // The ports below are for the VGA output.  Do not change.
                VGA_CLK,                                                //      VGA Clock
                VGA_HS,                                                 //      VGA H_SYNC
                VGA_VS,                                                 //      VGA V_SYNC
                VGA_BLANK_N,                                            //      VGA BLANK
                VGA_SYNC_N,                                             //      VGA SYNC
                VGA_R,                                                  //      VGA Red[9:0]
                VGA_G,                                                  //      VGA Green[9:0]
                VGA_B                                                   //      VGA Blue[9:0]
        );

        input CLOCK_50;                               //      50 MHz
        input   [3:0]   KEY;
        input [9:0] SW;
        output                  VGA_CLK;                                //      VGA Clock
        output                  VGA_HS;                                 //      VGA H_SYNC
        output                  VGA_VS;                                 //      VGA V_SYNC
        output                  VGA_BLANK_N;                            //      VGA BLANK
        output                  VGA_SYNC_N;                             //      VGA SYNC
        output  [7:0]   VGA_R;                                  //      VGA Red[7:0] Changed from 10 to 8-bit DAC
        output  [7:0]   VGA_G;                                  //      VGA Green[7:0]
        output  [7:0]   VGA_B;                                  //      VGA Blue[7:0]

        wire resetn;
        assign resetn = KEY[0];

        // Create the colour, x, y and writeEn wires that are inputs to the controller.

        wire [2:0] colour;
        wire [8:0] x;
        wire [8:0] y;
        wire writeEn;

        // Create an Instance of a VGA controller - there can be only one!
        // Define the number of colours as well as the initial background
        // image file (.MIF) for the controller.
        vga_adapter VGA(
                        .resetn(resetn),
                        .clock(CLOCK_50),
                        .colour(colour),
                        .x(x),
                        .y(y),
                        .plot(writeEn),
                        /* Signals for the DAC to drive the monitor. */
                        .VGA_R(VGA_R),
                        .VGA_G(VGA_G),
                        .VGA_B(VGA_B),
                        .VGA_HS(VGA_HS),
                        .VGA_VS(VGA_VS),
                        .VGA_BLANK(VGA_BLANK_N),
                        .VGA_SYNC(VGA_SYNC_N),
								.VGA_CLK(VGA_CLK));
                defparam VGA.RESOLUTION = "480x360";
                defparam VGA.MONOCHROME = "FALSE";
                defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
                defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
			decodeAndMap d0 (x, y, colour, writeEn, resetn, CLOCK_50, SW[1:0], SW[4:2]);

endmodule

module decodeAndMap(drawX, drawY, drawColour, WE, resetn, clock, shapeselect, inputColour);

    parameter X_SCREEN_PIXELS = 9'd320;
    parameter Y_SCREEN_PIXELS = 9'd180;

    input [1:0] shapeselect;
    input clock, resetn;
    input [2:0] inputColour;
    output reg [2:0] drawColour;
    output [8:0] drawX, drawY;
    output reg WE;

    wire [47:0] w0;
    wire [47:0] w1;
    wire [47:0] w2;
    wire [47:0] w3;
    wire [47:0] w4;
    wire [47:0] w5;
    wire [47:0] w6;
    wire [47:0] w7;
    wire [47:0] w8;
    wire [47:0] w9;
    wire [47:0] w10;
    wire [47:0] w11;

    wire [3:0] numVerticies;
    wire DC;

    reg [47:0] v0;
    reg [47:0] v1;
    reg [47:0] v2;
    reg [47:0] v3;
    reg [47:0] v4;
    reg [47:0] v5;
    reg [47:0] v6;
    reg [47:0] v7;
    reg [47:0] v8;
    reg [47:0] v9;
    reg [47:0] v10;
    reg [47:0] v11;

    reg [8:0] currentStartX, currentStartY, currentEndX, currentEndY;
    reg activate;

    shapeTypeLUT s0(shapeselect, w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, numVerticies);
    connectVerticies c0(activate, clock, resetn, currentStartX, currentStartY, currentEndX, currentEndY, drawX, drawY, DC);

    reg [5:0] y, Y;
    reg [5:0] lastConnectState;

    reg doneDrawingShape;

    always @(*) begin

        case (shapeselect)
        1: begin // OCTAHEDRON

        end
        2: begin // CUBE

        end
        3: begin // ICOSAHEDRON

        end
        default: begin // TETRAHEDRON
            case(y)
                0: begin
                    Y <= DC ? 7 : 0;
                    WE <= 1;
                    lastConnectState <= y;
                    activate <= 1;
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 90;
                    currentEndX <= (v1[47:32] >> 3) + 160;
                    currentEndY <= (v1[31:16] >> 3) + 90;
                end

                1: begin
                    Y <= DC ? 7 : 1;
                    lastConnectState <= y;
                    activate <= 1;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 90;
                end

                2: begin
                    Y <= DC ? 7 : 2;
                    lastConnectState <= y;
                    activate <= 1;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 90;
                end

                3: begin
                    Y <= DC ? 7 : 3;
                    lastConnectState <= y;
                    activate <= 1;
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 90;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 90;
                end

                4: begin
                    Y <= DC ? 7 : 4;
                    lastConnectState <= y;
                    activate <= 1;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 90;
                end

                5: begin
                    Y <= DC ? 7 : 5;
                    lastConnectState <= y;
                    activate <= 1;
                    currentStartX <= (v2[47:32] >> 3) + 160;
                    currentStartY <= (v2[31:16] >> 3) + 90;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 90;
                end
                6: begin
                    Y <= 6;
                    WE <= 0;
                end
                7: begin
                    Y <= lastConnectState + 1;
                    activate <= 0;
                end
					 31: begin
							Y <= 0;
                    activate <= 0;
					 end
            endcase
            doneDrawingShape <= y == 6;
        end
        endcase
    end

    always @ (posedge clock) begin
        if (~resetn) begin
            y <= 31;
            drawColour <= inputColour;

            v0 <= w0;
            v1 <= w1;
            v2 <= w2;
            v3 <= w3;
            v4 <= w4;
            v5 <= w5;
            v6 <= w6;
            v7 <= w7;
            v8 <= w8;
            v9 <= w9;
            v10 <= w10;
            v11 <= w11;

        end else y <= Y;
    end

endmodule


module connectVerticies(go, clk, rst, startX, startY, endX, endY, outX, outY, done);

	input clk, rst, go;
	input [8:0] startX, startY, endX, endY;
	output reg [8:0] outX, outY;
	output reg done;
	reg isDone;
	
	parameter [1:0] A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;
	reg [1:0] Y, y; // NEXT, CURRENT STATE
	
	wire signed [9:0] dx, dy;  
	assign dx = endX - startX;
	assign dy = endY - startY;
	
	reg [8:0] checkEndX;
	reg [8:0] checkEndY;
	
	wire up, right;
	assign up = dy >= 0;
	assign right = dx >= 0;
	
	reg signed [11:0] err;
	
	wire moveX, moveY;
	assign moveX = (2*err >= dy);
	assign moveY = (2*err <= dx);
	
	always@(*)begin
	
		checkEndX = (dx < 2) ? startX : endX;
		checkEndY = (dy < 2) ? startY : endY;
		case(y)
			A: Y <= go ? B : A;
			B: Y <= isDone ? C : B;
			C: Y <= !go ? A : B;
		endcase
		done <= y == C;
	end
	
	always@(posedge clk) begin
		if(~rst) begin
			y <= A;
			isDone <= 0;
		end
		else y<=Y; // huh
		
		case(y)
			A: begin
					err <= dx + dy;
					outX <= startX;
					outY <= startY;
				end
			B: begin
					if (outX == checkEndX && outY == checkEndY) isDone <= 1;
					else begin
						isDone <= 0;
						if(moveX) begin
							outX <= right ? outX + 1 : outX - 1;
							err <= err + dy;
						end
						if(moveY) begin
							outY <= up ? outY + 1 : outY - 1;
							err <= err + dx;
						end
						if(moveX && moveY) begin
							outX <= right ? outX + 1 : outX - 1;
							outY <= up ? outY + 1 : outY - 1;
							err <= err + dx + dy;
						end
					end
				end
		endcase
	end
	
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
    output reg [47:0] v11,
	 output reg [3:0] numVerticies   
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
				numVerticies <= 6;
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
				numVerticies <= 8;
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
				numVerticies <= 12;
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
				numVerticies <= 4;
        end
    endcase
end

endmodule

//module XYIncrement(clock, resetn, enabled, initX, initY, maxX, maxY, outX, outY, done);
//
//        input clock, resetn, enabled;
//        input [7:0] initX;
//        input [6:0] initY;
//        input [7:0] maxX;
//        input [6:0] maxY;
//        output reg [7:0] outX;
//        output reg [6:0] outY;
//        output reg done;
//
//        reg [1:0] y, Y;
//
//        always@(*) begin
//
//                case(y)
//                 0: if (enabled) Y=1; else Y=0;
//                 1: Y=2;
//                 2: if (done) Y=0; else Y=2;
//                endcase
//
//        end
//
//        always@(posedge clock) begin
//
//                if(!resetn) begin
//                        y = 0;
//                        done <= 1'b0;
//
//                end
//                else y=Y;
//
//                case(y)
//                        0: begin
//                                outX <= initX;
//                                outY <= initY;
//                        end
//                        1: begin
//                                outX <= initX;
//                                outY <= initY;
//                                done <= 1'b0;
//                        end
//                        2: begin
//                                if (outY != (maxY + initY) | outX != (maxX + initX)) begin
//                                        if (outX != (maxX + initX)) outX <= outX + 8'd1;
//                                        else begin
//                                                outX <= initX;
//                                                outY <= outY + 7'd1;
//                                        end
//                                end else done <= 1'b1;
//                        end
//                endcase
//
//        end
//
//endmodule
