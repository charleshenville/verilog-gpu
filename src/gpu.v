
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
        input [3:0] KEY;
        input [9:0] SW;
        output VGA_CLK;                                //      VGA Clock
        output VGA_HS;                                 //      VGA H_SYNC
        output VGA_VS;                                 //      VGA V_SYNC
        output VGA_BLANK_N;                            //      VGA BLANK
        output VGA_SYNC_N;                             //      VGA SYNC
        output [7:0] VGA_R;                                  //      VGA Red[7:0] Changed from 10 to 8-bit DAC
        output [7:0] VGA_G;                                  //      VGA Green[7:0]
        output [7:0] VGA_B;                                  //      VGA Blue[7:0]

        wire resetn;
        assign resetn = KEY[0];

        // Create the colour, x, y and writeEn wires that are inputs to the controller.

        wire [2:0] colour;
        wire [8:0] x;
        wire [7:0] y;
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
					 defparam VGA.RESOLUTION = "320x240";
                defparam VGA.MONOCHROME = "FALSE";
                defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
                defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
			decodeAndMap d0 (x, y, colour, writeEn, resetn, CLOCK_50, SW[1:0], SW[4:2]);

endmodule

module decodeAndMap(drawX, drawY, drawColour, WE, resetn, clock, shapeselect, inputColour);

    parameter X_SCREEN_PIXELS = 9'd320;
    parameter Y_SCREEN_PIXELS = 8'd240;

    input [1:0] shapeselect;
    input clock, resetn;
    input [2:0] inputColour;
    output reg [2:0] drawColour;
    output reg [8:0] drawX, drawY;
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
	 
	 wire [47:0] u0;
    wire [47:0] u1;
    wire [47:0] u2;
    wire [47:0] u3;
    wire [47:0] u4;
    wire [47:0] u5;
    wire [47:0] u6;
    wire [47:0] u7;
    wire [47:0] u8;
    wire [47:0] u9;
    wire [47:0] u10;
    wire [47:0] u11;

    reg [10:0] currentStartX, currentStartY, currentEndX, currentEndY;
    reg activate;
	 reg enableSingleRotation;
	 wire DR;

    shapeTypeLUT s0(shapeselect, w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, numVerticies);
	 
	 wire [8:0] cX, cY;
    connectVerticies c0(activate, clock, resetn, currentStartX, currentStartY, currentEndX, currentEndY, cX, cY, DC);
	 incrementalRotation i0(enableSingleRotation, clock, resetn, v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, DR);
    
	 wire [8:0] bX, bY;
	 wire DB;
	 
	 reg enableBlack;
	 
	 reg [31:0] nCycles;
	 
	 blackOut b0(clock, resetn, enableBlack, X_SCREEN_PIXELS, Y_SCREEN_PIXELS, bX, bY, DB);
	 
	 reg [5:0] y, Y;
    reg [5:0] lastConnectState;

    reg doneDrawingShape;

    always @(*) begin

        case (shapeselect)
        1: begin // OCTAHEDRON
				case(y)
                0: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 120;
                end

                1: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentEndX <= (v5[47:32] >> 3 + 160);
                    currentEndY <= (v5[31:16] >> 3 + 120);
                end

                2: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 120;
                end

                3: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end

                4: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 120;
                end

                5: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentEndX <= ((v5[47:32] >> 3) + 160);
                    currentEndY <= ((v5[31:16] >> 3) + 120);
                end

                6: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 120;
                end

                7: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end
					 8: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentStartX <= (v3[47:32] >> 3) + 160;
                    currentStartY <= (v3[31:16] >> 3) + 120;
                end
					 9: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentEndX <= (v5[47:32] >> 3) + 160;
                    currentEndY <= 	(v5[31:16] >> 3) + 120;
                end
					 10: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentStartX <= (v2[47:32] >> 3) + 160;
                    currentStartY <= (v2[31:16] >> 3) + 120;
                end
					 11: begin
						  Y <= 14;
                    lastConnectState <= y;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end
                12: begin
                    Y <= 12;
                    WE <= 0;
                end
                13: begin
                    Y <= DC ? 13 : lastConnectState + 1;
                    activate <= 0;
						  WE <= 0;
                end
					 14: begin
						  Y <= DC ? 13 : 14;
						  activate <= 1;
						  WE <= 1;
					 end
					 31: begin
						  Y <= 0;
                    activate <= 0;
						  currentStartX <= 0;
						  currentStartY <= 0;
						  WE <= 0;
					 end
            endcase
            doneDrawingShape <= y == 12;
        end
        2: begin // CUBE

        end
        3: begin // ICOSAHEDRON

        end
        default: begin // TETRAHEDRON
            case(y)
                0: begin
						  Y <= 8;
                    lastConnectState <= y;
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v1[47:32] >> 3) + 160;
                    currentEndY <= (v1[31:16] >> 3) + 120;
                end

                1: begin
						  Y <= 8;
                    lastConnectState <= y;
						  currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= ((v2[47:32] >> 3) + 160);
                    currentEndY <= ((v2[31:16] >> 3) + 120);
                end

                2: begin
						  Y <= 8;
                    lastConnectState <= y;
						  currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 120;
                end

                3: begin
						  Y <= 8;
                    lastConnectState <= y;
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 120;
                end

                4: begin
						  Y <= 8;
                    lastConnectState <= y;
						  currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 120;
                end

                5: begin
						  Y <= 8;
                    lastConnectState <= y;
                    currentStartX <= (v2[47:32] >> 3) + 160;
                    currentStartY <= (v2[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 120;
                end
                6: begin
                    Y <= 28; // OR 6 for static.
                    WE <= 0;
                end
                7: begin
                    Y <= DC ? 7 : lastConnectState + 1;
                    activate <= 0;
						  WE <= 0;
                end
					 8: begin
						  Y <= DC ? 7 : 8;
						  activate <= 1;
						  WE <= 1;
					 end
					 25: begin
						Y <= 0;
						enableBlack <= 0;
					 end
					 26: begin
						Y <= DB ? 25 : 26;
					 end
					 27: begin // Black Out
						Y<=26;
						enableBlack <= 1;
					 end
					 28: begin
						Y <= 29;
						enableSingleRotation <= 1;
					 end
					 29: begin
						Y <= DR ? 30 : 29;
					 end
					 30: begin
						Y <= (nCycles == 833334) ? 27:30;
						v0 <= u0;
						v1 <= u1;
						v2 <= u2;
						v3 <= u3;
						v4 <= u4;
						v5 <= u5;
						v6 <= u6;
						v7 <= u7;
						v8 <= u8;
						v9 <= u9;
						v10 <= u10;
						v11 <= u11;
						enableSingleRotation <= 0;
					 end
					 31: begin
						  Y <= 0;
                    activate <= 0;
						  currentStartX <= 0;
						  currentStartY <= 0;
						  WE <= 0;
						  enableSingleRotation <= 0;
						  enableBlack <= 0;
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
					 end
            endcase
            doneDrawingShape <= y == 6;
        end
        endcase
    end
	 wire doNext;
	 assign doNext = y == 17;
    always @ (posedge clock) begin
        if (~resetn) begin
            y <= 31;
				//enableBlack <= 0;
				nCycles <= 0;
            drawColour <= inputColour;

//            v0 <= w0;
//            v1 <= w1;
//            v2 <= w2;
//            v3 <= w3;
//            v4 <= w4;
//            v5 <= w5;
//            v6 <= w6;
//            v7 <= w7;
//            v8 <= w8;
//            v9 <= w9;
//            v10 <= w10;
//            v11 <= w11;

        end else begin
			y <= Y;
			
			if(y==0) nCycles <=0;
			if(y==30) nCycles <= nCycles + 1;
			
			if(enableBlack)begin
				drawX <= bX;
				drawY <= bY;
				drawColour <= 0;
			end else begin
				drawX <= cX;
				drawY <= cY;
				drawColour <= inputColour;
			end
		  end
    end

endmodule

module incrementalRotation(
	 input enable, clk, rst,
    input [47:0] v0,
    input [47:0] v1,
    input [47:0] v2,
    input [47:0] v3,
    input [47:0] v4,
    input [47:0] v5,
    input [47:0] v6,
    input [47:0] v7,
    input [47:0] v8,
    input [47:0] v9,
    input [47:0] v10,
    input [47:0] v11,
	 output reg [47:0] u0,
    output reg [47:0] u1,
    output reg [47:0] u2,
    output reg [47:0] u3,
    output reg [47:0] u4,
    output reg [47:0] u5,
    output reg [47:0] u6,
    output reg [47:0] u7,
    output reg [47:0] u8,
    output reg [47:0] u9,
    output reg [47:0] u10,
    output reg [47:0] u11,
	 output reg done
);

	reg signed [15:0] xv0;
	reg signed [15:0] xv1;
	reg signed [15:0] xv2;
	reg signed [15:0] xv3;
	reg signed [15:0] xv4;
	reg signed [15:0] xv5;
	reg signed [15:0] xv6;
	reg signed [15:0] xv7;
	reg signed [15:0] xv8;
	reg signed [15:0] xv9;
	reg signed [15:0] xv10;
	reg signed [15:0] xv11;
	
	reg signed [15:0] yv0;
	reg signed [15:0] yv1;
	reg signed [15:0] yv2;
	reg signed [15:0] yv3;
	reg signed [15:0] yv4;
	reg signed [15:0] yv5;
	reg signed [15:0] yv6;
	reg signed [15:0] yv7;
	reg signed [15:0] yv8;
	reg signed [15:0] yv9;
	reg signed [15:0] yv10;
	reg signed [15:0] yv11;
	
	reg signed [15:0] zv0;
	reg signed [15:0] zv1;
	reg signed [15:0] zv2;
	reg signed [15:0] zv3;
	reg signed [15:0] zv4;
	reg signed [15:0] zv5;
	reg signed [15:0] zv6;
	reg signed [15:0] zv7;
	reg signed [15:0] zv8;
	reg signed [15:0] zv9;
	reg signed [15:0] zv10;
	reg signed [15:0] zv11;
	
	reg [2:0] y, Y;
	
	always@(*) begin
		
		case(y)
			0: begin 
				Y <= enable ? 1 : 0;
				u0 <= v0;
				u1 <= v1;
				u2 <= v2;
				u3 <= v3;
				u4 <= v4;
				u5 <= v5;
				u6 <= v6;
				u7 <= v7;
				u8 <= v8;
				u9 <= v9;
				u10 <= v10;
				u11 <= v11;
			end
			1: begin
				Y <= 2;
				
//				xv0 <= v0[47:32];
//				xv1 <= v1[47:32];
//				xv2 <= v2[47:32];
//				xv3 <= v3[47:32];
//				xv4 <= v4[47:32];
//				xv5 <= v5[47:32];
//				xv6 <= v6[47:32];
//				xv7 <= v7[47:32];
//				xv8 <= v8[47:32];
//				xv9 <= v9[47:32];
//				xv10 <= v10[47:32];
//				xv11 <= v11[47:32];
//				
//				yv0 <= v0[31:16];
//				yv1 <= v1[31:16];
//				yv2 <= v2[31:16];
//				yv3 <= v3[31:16];
//				yv4 <= v4[31:16];
//				yv5 <= v5[31:16];
//				yv6 <= v6[31:16];
//				yv7 <= v7[31:16];
//				yv8 <= v8[31:16];
//				yv9 <= v9[31:16];
//				yv10 <= v10[31:16];
//				yv11 <= v11[31:16];
//				
//				zv0 <= v0[15:0];
//				zv1 <= v1[15:0];
//				zv2 <= v2[15:0];
//				zv3 <= v3[15:0];
//				zv4 <= v4[15:0];
//				zv5 <= v5[15:0];
//				zv6 <= v6[15:0];
//				zv7 <= v7[15:0];
//				zv8 <= v8[15:0];
//				zv9 <= v9[15:0];
//				zv10 <= v10[15:0];
//				zv11 <= v11[15:0];
				
				yv0 <= v0[47:32];
				yv1 <= v1[47:32];
				yv2 <= v2[47:32];
				yv3 <= v3[47:32];
				yv4 <= v4[47:32];
				yv5 <= v5[47:32];
				yv6 <= v6[47:32];
				yv7 <= v7[47:32];
				yv8 <= v8[47:32];
				yv9 <= v9[47:32];
				yv10 <= v10[47:32];
				yv11 <= v11[47:32];
				
				xv0 <= 0 - v0[31:16];
				xv1 <= 0 - v1[31:16];
				xv2 <= 0 - v2[31:16];
				xv3 <= 0 - v3[31:16];
				xv4 <= 0 - v4[31:16];
				xv5 <= 0 - v5[31:16];
				xv6 <= 0 - v6[31:16];
				xv7 <= 0 - v7[31:16];
				xv8 <= 0 - v8[31:16];
				xv9 <= 0 - v9[31:16];
				xv10 <= 0 - v10[31:16];
				xv11 <= 0 - v11[31:16];
				
//				xv0 <= (511*v0[47:32] - 10*v0[31:16])>>9;
//				xv1 <= (511*v1[47:32] - 10*v1[31:16])>>9;
//				xv2 <= (511*v2[47:32] - 10*v2[31:16])>>9;
//				xv3 <= (511*v3[47:32] - 10*v3[31:16])>>9;
//				xv4 <= (511*v4[47:32] - 10*v4[31:16])>>9;
//				xv5 <= (511*v5[47:32] - 10*v5[31:16])>>9;
//				xv6 <= (511*v6[47:32] - 10*v6[31:16])>>9;
//				xv7 <= (511*v7[47:32] - 10*v7[31:16])>>9;
//				xv8 <= (511*v8[47:32] - 10*v8[31:16])>>9;
//				xv9 <= (511*v9[47:32] - 10*v9[31:16])>>9;
//				xv10 <= (511*v10[47:32] - 10*v10[31:16])>>9;
//				xv11 <= (511*v11[47:32] - 10*v11[31:16])>>9;
//				
//				yv0 <= (10*v0[47:32] + 511*v0[31:16] - 5*v0[15:0])>>9;
//				yv1 <= (10*v1[47:32] + 511*v1[31:16] - 5*v1[15:0])>>9;
//				yv2 <= (10*v2[47:32] + 511*v2[31:16] - 5*v2[15:0])>>9;
//				yv3 <= (10*v3[47:32] + 511*v3[31:16] - 5*v3[15:0])>>9;
//				yv4 <= (10*v4[47:32] + 511*v4[31:16] - 5*v4[15:0])>>9;
//				yv5 <= (10*v5[47:32] + 511*v5[31:16] - 5*v5[15:0])>>9;
//				yv6 <= (10*v6[47:32] + 511*v6[31:16] - 5*v6[15:0])>>9;
//				yv7 <= (10*v7[47:32] + 511*v7[31:16] - 5*v7[15:0])>>9;
//				yv8 <= (10*v8[47:32] + 511*v8[31:16] - 5*v8[15:0])>>9;
//				yv9 <= (10*v9[47:32] + 511*v9[31:16] - 5*v9[15:0])>>9;
//				yv10 <= (10*v10[47:32] + 511*v10[31:16] - 5*v10[15:0])>>9;
//				yv11 <= (10*v11[47:32] + 511*v11[31:16] - 5*v11[15:0])>>9;
//				
////				zv0 <= (v0[47:32] + 5*v0[31:16] + 511*v0[15:0])>>9;
////				zv1 <= (v1[47:32] + 5*v1[31:16] + 511*v1[15:0])>>9;
////				zv2 <= (v2[47:32] + 5*v2[31:16] + 511*v2[15:0])>>9;
////				zv3 <= (v3[47:32] + 5*v3[31:16] + 511*v3[15:0])>>9;
////				zv4 <= (v4[47:32] + 5*v4[31:16] + 511*v4[15:0])>>9;
////				zv5 <= (v5[47:32] + 5*v5[31:16] + 511*v5[15:0])>>9;
////				zv6 <= (v6[47:32] + 5*v6[31:16] + 511*v6[15:0])>>9;
////				zv7 <= (v7[47:32] + 5*v7[31:16] + 511*v7[15:0])>>9;
////				zv8 <= (v8[47:32] + 5*v8[31:16] + 511*v8[15:0])>>9;
////				zv9 <= (v9[47:32] + 5*v9[31:16] + 511*v9[15:0])>>9;
////				zv10 <= (v10[47:32] + 5*v10[31:16] + 511*v10[15:0])>>9;
////				zv11 <= (v11[47:32] + 5*v11[31:16] + 511*v11[15:0])>>9;
//				zv0 <= (5*v0[31:16] + 511*v0[15:0])>>9;
//				zv1 <= (5*v1[31:16] + 511*v1[15:0])>>9;
//				zv2 <= (5*v2[31:16] + 511*v2[15:0])>>9;
//				zv3 <= (5*v3[31:16] + 511*v3[15:0])>>9;
//				zv4 <= (5*v4[31:16] + 511*v4[15:0])>>9;
//				zv5 <= (5*v5[31:16] + 511*v5[15:0])>>9;
//				zv6 <= (5*v6[31:16] + 511*v6[15:0])>>9;
//				zv7 <= (5*v7[31:16] + 511*v7[15:0])>>9;
//				zv8 <= (5*v8[31:16] + 511*v8[15:0])>>9;
//				zv9 <= (5*v9[31:16] + 511*v9[15:0])>>9;
//				zv10 <= (5*v10[31:16] + 511*v10[15:0])>>9;
//				zv11 <= (5*v11[31:16] + 511*v11[15:0])>>9;
			end
			2: begin
				Y <= enable ? 2 : 0;
				u0 <= {xv0,yv0,zv0};
				 u1 <= {xv1,yv1,zv1};
				 u2 <= {xv2,yv2,zv2};
				 u3 <= {xv3,yv3,zv3};
				 u4 <= {xv4,yv4,zv4};
				 u5 <= {xv5,yv5,zv5};
				 u6 <= {xv6,yv6,zv6};
				 u7 <= {xv7,yv7,zv7};
				 u8 <= {xv8,yv8,zv8};
				 u9 <= {xv9,yv9,zv9};
				 u10 <= {xv10,yv10,zv10};
				 u11 <= {xv11,yv11,zv11};
				 
			end	
		endcase
		
	end
	
	always@(posedge clk)begin
		if(~rst) begin
			done <= 0;
			y <= 0;

		end else begin
			y <= Y;
			if (y==0) begin
				done <= 0;
			end
			if (y==2) begin
				done <= 1;
			end
		end
	end

endmodule

module connectVerticies(go, clk, rst, startX, startY, endX, endY, outX, outY, done);

	input clk, rst, go;
	
	input [9:0] startX, startY, endX, endY;
	reg [10:0] x0, y0, x1, y1;
	
	output reg [10:0] outX, outY;
	output reg done;
	reg isDone;
	
	parameter [2:0] A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100;
	reg [2:0] Y, y; // NEXT, CURRENT STATE
	
	wire signed [10:0] dx, dy;
	assign dx = endX - startX;
	assign dy = endY - startY;
	
	reg signed [10:0] deltaX, deltaY;
	
	wire up, right;
	assign up = dy >= 0;
	assign right = dx >= 0;
	
	reg signed [11:0] err;
	
	reg moveX, moveY;
	
	always@(*)begin
		
		if(!(startY > endY))begin
			y0 = startY;
			y1 = endY;
			x0 = startX ;
			x1 = endX;
		end else begin
			y1 = startY;
			y0 = endY;
			x1 = startX;
			x0 = endX;
		end
		
		deltaX <= (x0 < x1) ? (x1 - x0) : (x0 - x1);
		deltaY <= y0 - y1;
		
		moveX <= (2*err >= deltaY);
		moveY <= (2*err <= deltaX);
		
		case(y)
			A: Y <= go ? D : A;
			D: Y <= B;
			B: Y <= isDone ? C : B;
			C: Y <= !go ? A : C;
		endcase
		done <= y == C;
	end
	
	always@(posedge clk) begin
		if(~rst) begin
			y <= A;
			isDone <= 0;
			outX <= 0;
			outY <= 0;
		end
		else begin 
			y<=Y; // huh
			case(y)
				A: begin
						isDone <= 0;
						err <= deltaX + deltaY;
						outX <= x0;
						outY <= y0;
					end
				D: begin
						err <= deltaX + deltaY;
						outX <= x0;
						outY <= y0;
				end
				B: begin
						if (outX == x1 && outY == y1) isDone <= 1;
						else begin
							if(moveX) begin
								outX <= (x0 < x1) ? outX + 1 : outX - 1;
								err <= err + deltaY;
							end
							if(moveY) begin
								outY <= outY + 1;
								err <= err + deltaX;
							end
							if(moveX && moveY) begin
								outX <= (x0 < x1) ? outX + 1 : outX - 1;
								outY <= outY + 1;
								err <= err + deltaX + deltaY;
							end
							if(~moveX && ~moveY) begin
								outX <= x0;
								outY <= y0;
							end
						end
					end
				C: isDone <= 0;
			endcase
		end
		
	end
endmodule

module blackOut(clock, resetn, enabled, maxX, maxY, outX, outY, done);

        input clock, resetn, enabled;
        input [8:0] maxX;
        input [8:0] maxY;
        output reg [8:0] outX;
        output reg [8:0] outY;
        output reg done;

        reg [1:0] y, Y;

        always@(*) begin

                case(y)
                 0: if (enabled) Y=1; else Y=0;
                 1: Y=2;
                 2: if (done) Y=0; else Y=2;
                endcase

        end

        always@(posedge clock) begin

                if(~resetn) begin
                        y = 0;
                        done <= 0;

                end
                else y=Y;

                case(y)
                        0: begin
                                outX <= 0;
                                outY <= 0;
										  done <= 0;
                        end
                        1: begin
                                done <= 0;
                        end
                        2: begin
                                if (outY != maxY | outX != maxX) begin
                                        if (outX != maxX) outX <= outX + 1;
                                        else begin
                                                outX <= 0;
                                                outY <= outY + 1;
                                        end
                                end else done <= 1;
                        end
                endcase

        end

endmodule
