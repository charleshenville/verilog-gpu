
module gpu (
                CLOCK_50,
                SW,
                KEY,
                VGA_CLK,
                VGA_HS,
                VGA_VS,
                VGA_BLANK_N,
                VGA_SYNC_N,
                VGA_R,
                VGA_G,
                VGA_B
        );

        input CLOCK_50;
        input [3:0] KEY;
        input [9:0] SW;
        output VGA_CLK;
        output VGA_HS;
        output VGA_VS;
        output VGA_BLANK_N;
        output VGA_SYNC_N;
        output [7:0] VGA_R;
        output [7:0] VGA_G;
        output [7:0] VGA_B;

        wire resetn;
        assign resetn = KEY[0];

        wire [2:0] colour;
        wire [8:0] x;
        wire [7:0] y;
        wire writeEn;

        vga_adapter VGA(
                        .resetn(resetn),
                        .clock(CLOCK_50),
                        .colour(colour),
                        .x(x),
                        .y(y),
                        .plot(writeEn),
								
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
			
			decodeAndMap d0 (x, y, colour, writeEn, resetn, CLOCK_50, SW[1:0], SW[4:2], VGA_VS, ~KEY[3], ~KEY[2], ~KEY[1]);

endmodule

module decodeAndMap(drawX, drawY, drawColour, WE, resetn, clock, shapeselect, inputColour, vs_n, rotateX, rotateY, rotateZ);

    parameter X_SCREEN_PIXELS = 9'd320;
    parameter Y_SCREEN_PIXELS = 8'd240;
		
	 input vs_n;
	 reg lvs_n;
    input [1:0] shapeselect;
    input clock, resetn, rotateX, rotateY, rotateZ;
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
	 incrementalRotation i0(enableSingleRotation, clock, resetn, v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, DR, rotateX, rotateY, rotateZ);
    
	 wire [8:0] bX, bY;
	 wire DB;
	 
	 reg enableBlack;
	 
	 reg [31:0] nCycles;
	 
	 blackOut b0(clock, resetn, enableBlack, X_SCREEN_PIXELS, Y_SCREEN_PIXELS, bX, bY, DB);
	 
	 reg [5:0] y, Y;
    reg [5:0] lastConnectState;

    always @(*) begin
        case (shapeselect)
        1,2: begin // OCTAHEDRON AND CUBE
				case(y)
                0,1,2,3,4,5,6,7,8,9,10,11: begin
						  Y <= 57;
                end
                12: begin
                    Y <= 61;
                end
                56: begin // Callback
                    Y <= DC ? 56 : lastConnectState + 1;
                end
					 57: begin // Conncecting State 
						  Y <= DC ? 56 : 57;
					 end
					 58: begin 
						Y <= 0;
					 end
					 59: begin // Wait until finished blacking
						Y <= DB ? 58 : 59;
					 end
					 60: begin // Black Out
						Y <= 59;
					 end
					 61: begin
						Y <= 62;
					 end
					 62: begin
						Y <= DR ? 63 : 62;
					 end
					 63: begin
						Y <= (lvs_n == 1 && vs_n == 0) ? 60:63;
						//Y <= (nCycles == 16) ? 0:63;
					 end
					 default: begin
						Y = 0;
					 end
            endcase
        end
        3: begin // ICOSAHEDRON
				case(y)
                0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29: begin
						  Y <= 57;
                end
                30: begin
                    Y <= 61; // OR 6 for static.
                end
                56: begin // Callback
                    Y <= DC ? 56 : lastConnectState + 1;
                end
					 57: begin // Conncecting State 
						  Y <= DC ? 56 : 57;
					 end
					 58: begin 
						Y <= 0;
					 end
					 59: begin // Wait until finished blacking
						Y <= DB ? 58 : 59;
					 end
					 60: begin // Black Out
						Y <= 59;
					 end
					 61: begin
						Y <= 62;
					 end
					 62: begin
						Y <= DR ? 63 : 62;
					 end
					 63: begin
						Y <= (lvs_n == 1 && vs_n == 0) ? 60:63;
						//Y <= (nCycles == 16) ? 0:63;
					 end
					 default: begin
						Y = 0;
					 end
            endcase
        end
        default: begin // TETRAHEDRON
            case(y)
				
                0,1,2,3,4,5: begin
						  Y <= 57;
                end
                6: begin
                    Y <= 61; // OR 6 for static.
                end
                56: begin // Callback
                    Y <= DC ? 56 : lastConnectState + 1;
                end
					 57: begin // Conncecting State 
						  Y <= DC ? 56 : 57;
					 end
					 58: begin 
						Y <= 0;
					 end
					 59: begin // Wait until finished blacking
						Y <= DB ? 58 : 59;
					 end
					 60: begin // Black Out
						Y <= 59;
					 end
					 61: begin
						Y <= 62;
					 end
					 62: begin
						Y <= DR ? 63 : 62;
					 end
					 63: begin
						Y <= (lvs_n == 1 && vs_n == 0) ? 60:63;
						//Y <= (nCycles == 16) ? 0:63;
					 end
					 default: begin
						Y = 0;
					 end
            endcase
        end
        endcase
    end
	 
    always @ (posedge clock) begin
        if (~resetn) begin
				y <= 0;
				nCycles <= 0;
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
				
				activate <= 0;
			  currentStartX <= 0;
			  currentStartY <= 0;
			  WE <= 0;
			  enableSingleRotation <= 0;
			  enableBlack <= 0;

        end else begin
			y <= Y;
			lvs_n <= vs_n;
			case(shapeselect)
			 1: begin // OCTAHEDRON
			 
				case(y)
                0: begin
                    lastConnectState <= y;
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 120;
                end
                1: begin
                    lastConnectState <= y;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 120;
                end

                2: begin
                    lastConnectState <= y;
                    currentEndX <= (v5[47:32] >> 3) + 160;
                    currentEndY <= (v5[31:16] >> 3) + 120;
                end

                3: begin
                    lastConnectState <= y;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end

                4: begin
                    lastConnectState <= y;
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 120;
                end

                5: begin
                    lastConnectState <= y;
                    currentEndX <= ((v5[47:32] >> 3) + 160);
                    currentEndY <= ((v5[31:16] >> 3) + 120);
                end

                6: begin
                    lastConnectState <= y;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 120;
                end

                7: begin
                    lastConnectState <= y;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end
					 8: begin
                    lastConnectState <= y;
                    currentStartX <= (v3[47:32] >> 3) + 160;
                    currentStartY <= (v3[31:16] >> 3) + 120;
                end
					 9: begin
                    lastConnectState <= y;
                    currentEndX <= (v5[47:32] >> 3) + 160;
                    currentEndY <= 	(v5[31:16] >> 3) + 120;
                end
					 10: begin
                    lastConnectState <= y;
                    currentStartX <= (v2[47:32] >> 3) + 160;
                    currentStartY <= (v2[31:16] >> 3) + 120;
                end
					 11: begin
                    lastConnectState <= y;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end
					 56: begin
                    activate = 0;
						  WE = 0;
                end
					 57: begin
						  activate = 1;
						  WE = 1;
					 end
					 58: begin
						enableBlack <= 0;
					 end
					 60: begin // Black Out
						enableBlack <= 1;
						WE <= 1;
					 end
					 61: begin
						enableSingleRotation <= 1;
					 end
					 62: begin
						nCycles <=0;
						enableSingleRotation <= 0;
					 end
					 63: begin
						nCycles <= nCycles + 1;
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
            endcase
			 end
			 2: begin // CUBE
					case(y)
                0: begin    
                    lastConnectState <= y; // 0-2
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 120;
                end

                1: begin
                    lastConnectState <= y; //0-3
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 120;
                end

                2: begin
                    lastConnectState <= y; //0-1
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v1[47:32] >> 3) + 160;
                    currentEndY <= (v1[31:16] >> 3) + 120;
                end

                3: begin
                    lastConnectState <= y; //1-7
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= (v7[47:32] >> 3) + 160;
                    currentEndY <= (v7[31:16] >> 3) + 120;
                end

                4: begin
                    lastConnectState <= y; //1-5
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= (v5[47:32] >> 3) + 160;
                    currentEndY <= (v5[31:16] >> 3) + 120;
                end

                5: begin
                    lastConnectState <= y; //2-4
                    currentStartX <= (v2[47:32] >> 3) + 160;
                    currentStartY <= (v2[31:16] >> 3) + 120;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end

                6: begin
                    lastConnectState <= y; //2-7
                    currentStartX <= (v2[47:32] >> 3) + 160;
                    currentStartY <= (v2[31:16] >> 3) + 120;
                    currentEndX <= (v7[47:32] >> 3) + 160;
                    currentEndY <= (v7[31:16] >> 3) + 120;
                end

                7: begin
                    lastConnectState <= y; //3-4
                    currentStartX <= (v3[47:32] >> 3) + 160;
                    currentStartY <= (v3[31:16] >> 3) + 120;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end
                8: begin
                    lastConnectState <= y; //3-5
                    currentStartX <= (v3[47:32] >> 3) + 160;
                    currentStartY <= (v3[31:16] >> 3) + 120;
                    currentEndX <= (v5[47:32] >> 3) + 160;
                    currentEndY <= (v5[31:16] >> 3) + 120;
                end
                9: begin
                    lastConnectState <= y; //4-6
                    currentStartX <= (v4[47:32] >> 3) + 160;
                    currentStartY <= (v4[31:16] >> 3) + 120;
                    currentEndX <= (v6[47:32] >> 3) + 160;
                    currentEndY <= (v6[31:16] >> 3) + 120;
                end
                10: begin
                    lastConnectState <= y; //5-6
                    currentStartX <= (v5[47:32] >> 3) + 160;
                    currentStartY <= (v5[31:16] >> 3) + 120;
                    currentEndX <= (v6[47:32] >> 3) + 160;
                    currentEndY <= (v6[31:16] >> 3) + 120;
                end
                11: begin
                    lastConnectState <= y; //6-7
                    currentStartX <= (v6[47:32] >> 3) + 160;
                    currentStartY <= (v6[31:16] >> 3) + 120;
                    currentEndX <= (v7[47:32] >> 3) + 160;
                    currentEndY <= (v7[31:16] >> 3) + 120;
                end
					 56: begin
                    activate = 0;
						  WE = 0;
                end
					 57: begin
						  activate = 1;
						  WE = 1;
					 end
					 58: begin
						enableBlack <= 0;
					 end
					 60: begin // Black Out
						enableBlack <= 1;
						WE <= 1;
					 end
					 61: begin
						enableSingleRotation <= 1;
					 end
					 62: begin
						nCycles <=0;
						enableSingleRotation <= 0;
					 end
					 63: begin
						nCycles <= nCycles + 1;
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
					endcase
			 end
			 3: begin // ICOSAHEDRON
				case(y)
				0: begin
                    lastConnectState <= y; // 0-5
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v5[47:32] >> 3) + 160;
                    currentEndY <= (v5[31:16] >> 3) + 120;
                end

                1: begin
                    lastConnectState <= y; //0-4
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end

                2: begin
                    lastConnectState <= y; //0-1
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v1[47:32] >> 3) + 160;
                    currentEndY <= (v1[31:16] >> 3) + 120;
                end

                3: begin
                    lastConnectState <= y; //0-2
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 120;
                end

                4: begin
                    lastConnectState <= y; //0-3
                    currentStartX <= (v0[47:32] >> 3) + 160;
                    currentStartY <= (v0[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <= (v3[31:16] >> 3) + 120;
                end

                5: begin
                    lastConnectState <= y; //1-5
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= ((v5[47:32] >> 3) + 160);
                    currentEndY <= ((v5[31:16] >> 3) + 120);
                end

                6: begin
                    lastConnectState <= y; //1-9
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= (v9[47:32] >> 3) + 160;
                    currentEndY <= (v9[31:16] >> 3) + 120;
                end

                7: begin
                    lastConnectState <= y; //1-10
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= (v10[47:32] >> 3) + 160;
                    currentEndY <= (v10[31:16] >> 3) + 120;
                end
                8: begin
                    lastConnectState <= y; //1-2
                    currentStartX <= (v1[47:32] >> 3) + 160;
                    currentStartY <= (v1[31:16] >> 3) + 120;
                    currentEndX <= (v2[47:32] >> 3) + 160;
                    currentEndY <= (v2[31:16] >> 3) + 120;
                end
                9: begin
                    lastConnectState <= y; //2-3
                    currentStartX <= (v2[47:32] >> 3) + 160;
                    currentStartY <= (v2[31:16] >> 3) + 120;
                    currentEndX <= (v3[47:32] >> 3) + 160;
                    currentEndY <=  (v3[31:16] >> 3) + 120;
                end
                10: begin
                    lastConnectState <= y; //2-10
                    currentStartX <= (v2[47:32] >> 3) + 160;
                    currentStartY <= (v2[31:16] >> 3) + 120;
                    currentEndX <= (v10[47:32] >> 3) + 160;
                    currentEndY <= (v10[31:16] >> 3) + 120;
                end
                11: begin
                    lastConnectState <= y; //2-11
                    currentStartX <= (v2[47:32] >> 3) + 160;
                    currentStartY <= (v2[31:16] >> 3) + 120;
                    currentEndX <= (v11[47:32] >> 3) + 160;
                    currentEndY <= (v11[31:16] >> 3) + 120;
                end
                12: begin
                    lastConnectState <= y; // 3-7
                    currentStartX <= (v3[47:32] >> 3) + 160;
                    currentStartY <= (v3[31:16] >> 3) + 120;
                    currentEndX <= (v7[47:32] >> 3) + 160;
                    currentEndY <= (v7[31:16] >> 3) + 120;
                end
                13: begin
                    lastConnectState <= y; //3-11
                    currentStartX <= (v3[47:32] >> 3) + 160;
                    currentStartY <= (v3[31:16] >> 3) + 120;
                    currentEndX <= (v11[47:32] >> 3) + 160;
                    currentEndY <= (v11[31:16] >> 3) + 120;
                end
                14: begin
                    lastConnectState <= y; //3-4
                    currentStartX <= (v3[47:32] >> 3) + 160;
                    currentStartY <= (v3[31:16] >> 3) + 120;
                    currentEndX <= (v4[47:32] >> 3) + 160;
                    currentEndY <= (v4[31:16] >> 3) + 120;
                end
                15: begin
                    lastConnectState <= y; //4-7
                    currentStartX <= (v4[47:32] >> 3) + 160;
                    currentStartY <= (v4[31:16] >> 3) + 120;
                    currentEndX <= (v7[47:32] >> 3) + 160;
                    currentEndY <= (v7[31:16] >> 3) + 120;
                end
                16: begin
                    lastConnectState <= y; //4-5
                    currentStartX <= (v4[47:32] >> 3) + 160;
                    currentStartY <= (v4[31:16] >> 3) + 120;
                    currentEndX <= (v5[47:32] >> 3) + 160;
                    currentEndY <= (v5[31:16] >> 3) + 120;
                end
                17: begin
                    lastConnectState <= y; //4-8
                    currentStartX <= (v4[47:32] >> 3) + 160;
                    currentStartY <= (v4[31:16] >> 3) + 120;
                    currentEndX <= ((v8[47:32] >> 3) + 160);
                    currentEndY <= ((v8[31:16] >> 3) + 120);
                end
                18: begin
                    lastConnectState <= y; //5-8
                    currentStartX <= (v5[47:32] >> 3) + 160;
                    currentStartY <= (v5[31:16] >> 3) + 120;
                    currentEndX <= (v8[47:32] >> 3) + 160;
                    currentEndY <= (v8[31:16] >> 3) + 120;
                end
                19: begin
                    lastConnectState <= y; //5-9
                    currentStartX <= (v5[47:32] >> 3) + 160;
                    currentStartY <= (v5[31:16] >> 3) + 120;
                    currentEndX <= (v9[47:32] >> 3) + 160;
                    currentEndY <= (v9[31:16] >> 3) + 120;
                end
                20: begin
                    lastConnectState <= y; //6-7
                    currentStartX <= (v6[47:32] >> 3) + 160;
                    currentStartY <= (v6[31:16] >> 3) + 120;
                    currentEndX <= (v7[47:32] >> 3) + 160;
                    currentEndY <= (v7[31:16] >> 3) + 120;
                end
                21: begin
                    lastConnectState <= y; //6-8
                    currentStartX <= (v6[47:32] >> 3) + 160;
                    currentStartY <= (v6[31:16] >> 3) + 120;
                    currentEndX <= (v8[47:32] >> 3) + 160;
                    currentEndY <=  (v8[31:16] >> 3) + 120;
                end
                22: begin
                    lastConnectState <= y; //6-9
                    currentStartX <= (v6[47:32] >> 3) + 160;
                    currentStartY <= (v6[31:16] >> 3) + 120;
                    currentEndX <= (v9[47:32] >> 3) + 160;
                    currentEndY <= (v9[31:16] >> 3) + 120;
                end
                23: begin
                    lastConnectState <= y; //6-10
                    currentStartX <= (v6[47:32] >> 3) + 160;
                    currentStartY <= (v6[31:16] >> 3) + 120;
                    currentEndX <= (v10[47:32] >> 3) + 160;
                    currentEndY <= (v10[31:16] >> 3) + 120;
                end
                24: begin
                    lastConnectState <= y; // 6-11
                    currentStartX <= (v6[47:32] >> 3) + 160;
                    currentStartY <= (v6[31:16] >> 3) + 120;
                    currentEndX <= (v11[47:32] >> 3) + 160;
                    currentEndY <= (v11[31:16] >> 3) + 120;
                end

                25: begin
                    lastConnectState <= y; //7-8
                    currentStartX <= (v7[47:32] >> 3) + 160;
                    currentStartY <= (v7[31:16] >> 3) + 120;
                    currentEndX <= (v8[47:32] >> 3) + 160;
                    currentEndY <= (v8[31:16] >> 3) + 120;
                end
                26: begin
                    lastConnectState <= y; //7-11
                    currentStartX <= (v7[47:32] >> 3) + 160;
                    currentStartY <= (v7[31:16] >> 3) + 120;
                    currentEndX <= (v11[47:32] >> 3) + 160;
                    currentEndY <= (v11[31:16] >> 3) + 120;
                end
                27: begin
                    lastConnectState <= y; //8-9
                    currentStartX <= (v8[47:32] >> 3) + 160;
                    currentStartY <= (v8[31:16] >> 3) + 120;
                    currentEndX <= (v9[47:32] >> 3) + 160;
                    currentEndY <= (v9[31:16] >> 3) + 120;
                end
                28: begin
                    lastConnectState <= y; //9-10
                    currentStartX <= (v9[47:32] >> 3) + 160;
                    currentStartY <= (v9[31:16] >> 3) + 120;
                    currentEndX <= (v10[47:32] >> 3) + 160;
                    currentEndY <= (v10[31:16] >> 3) + 120;
                end

                29: begin
                    lastConnectState <= y;  //10-11
                    currentStartX <= (v10[47:32] >> 3) + 160;
                    currentStartY <= (v10[31:16] >> 3) + 120;
                    currentEndX <= ((v11[47:32] >> 3) + 160);
                    currentEndY <= ((v11[31:16] >> 3) + 120);
                end
					 56: begin
                    activate = 0;
						  WE = 0;
                end
					 57: begin
						  activate = 1;
						  WE = 1;
					 end
					 58: begin
						enableBlack <= 0;
					 end
					 60: begin // Black Out
						enableBlack <= 1;
						WE <= 1;
					 end
					 61: begin
						enableSingleRotation <= 1;
					 end
					 62: begin
						nCycles <=0;
						enableSingleRotation <= 0;
					 end
					 63: begin
						nCycles <= nCycles + 1;
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
            endcase
			 end
			 default: begin // TETRAHEDRON
				case(y)
                0: begin
							lastConnectState <= y;
                    currentStartX = (v0[47:32] >> 3) + 160;
                    currentStartY = (v0[31:16] >> 3) + 120;
                    currentEndX = (v1[47:32] >> 3) + 160;
                    currentEndY = (v1[31:16] >> 3) + 120;
                end

                1: begin
					 lastConnectState <= y;
						  currentStartX = (v0[47:32] >> 3) + 160;
                    currentStartY = (v0[31:16] >> 3) + 120;
                    currentEndX = (v2[47:32] >> 3) + 160;
                    currentEndY = (v2[31:16] >> 3) + 120;
                end

                2: begin
					 lastConnectState <= y;
						  currentStartX = (v0[47:32] >> 3) + 160;
                    currentStartY = (v0[31:16] >> 3) + 120;
                    currentEndX = (v3[47:32] >> 3) + 160;
                    currentEndY = (v3[31:16] >> 3) + 120;
                end

                3: begin
					 lastConnectState <= y;
                    currentStartX = (v1[47:32] >> 3) + 160;
                    currentStartY = (v1[31:16] >> 3) + 120;
                    currentEndX = (v2[47:32] >> 3) + 160;
                    currentEndY = (v2[31:16] >> 3) + 120;
                end

                4: begin
					 lastConnectState <= y;
						  currentStartX = (v1[47:32] >> 3) + 160;
                    currentStartY = (v1[31:16] >> 3) + 120;
                    currentEndX = (v3[47:32] >> 3) + 160;
                    currentEndY = (v3[31:16] >> 3) + 120;
                end

                5: begin
					 lastConnectState <= y;
                    currentStartX = (v2[47:32] >> 3) + 160;
                    currentStartY = (v2[31:16] >> 3) + 120;
                    currentEndX = (v3[47:32] >> 3) + 160;
                    currentEndY = (v3[31:16] >> 3) + 120;
                end
                56: begin
                    activate = 0;
						  WE = 0;
                end
					 57: begin
						  activate = 1;
						  WE = 1;
					 end
					 58: begin
						enableBlack <= 0;
					 end
					 60: begin // Black Out
						enableBlack <= 1;
						WE <= 1;
					 end
					 61: begin
						enableSingleRotation <= 1;
					 end
					 62: begin
						nCycles <=0;
						enableSingleRotation <= 0;
					 end
					 63: begin
						nCycles <= nCycles + 1;
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
            endcase
			 end
			endcase
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
	 output reg done,
	 input rX, rY, rZ
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
	
	reg [3:0] y, Y;
	
	parameter alpha = 1023;
	parameter beta = 32;
	
	always@(*) begin
		
		case(y)
			0: begin 
				Y <= enable ? 1 : 0;
			end
			1: begin // INIT
				Y <= 2;
			end
			2: begin // ROTATE X
				Y <= 3;
			end
			3: begin // ROTATE Y
				Y <= 4;
			end
			4: begin // ROTATE z
				Y <= 5;
			end
			5: begin
				Y <= enable ? 5 : 0;
			end
		endcase
		
	end
	
	always@(posedge clk)begin
		if(~rst) begin
			done <= 0;
			y <= 0;
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

		end else begin
			y <= Y;
			
			case(y)
			0: begin 
				done <= 0;
			end
			1: begin
				
				xv0 <= v0[47:32];
				xv1 <= v1[47:32];
				xv2 <= v2[47:32];
				xv3 <= v3[47:32];
				xv4 <= v4[47:32];
				xv5 <= v5[47:32];
				xv6 <= v6[47:32];
				xv7 <= v7[47:32];
				xv8 <= v8[47:32];
				xv9 <= v9[47:32];
				xv10 <= v10[47:32];
				xv11 <= v11[47:32];
				
				yv0 <= v0[31:16];
				yv1 <= v1[31:16];
				yv2 <= v2[31:16];
				yv3 <= v3[31:16];
				yv4 <= v4[31:16];
				yv5 <= v5[31:16];
				yv6 <= v6[31:16];
				yv7 <= v7[31:16];
				yv8 <= v8[31:16];
				yv9 <= v9[31:16];
				yv10 <= v10[31:16];
				yv11 <= v11[31:16];
				
				zv0 <= v0[15:0];
				zv1 <= v1[15:0];
				zv2 <= v2[15:0];
				zv3 <= v3[15:0];
				zv4 <= v4[15:0];
				zv5 <= v5[15:0];
				zv6 <= v6[15:0];
				zv7 <= v7[15:0];
				zv8 <= v8[15:0];
				zv9 <= v9[15:0];
				zv10 <= v10[15:0];
				zv11 <= v11[15:0];

			end
			2: begin // X
				if(rX) begin 
				 yv0 <= (alpha * yv0 - beta * zv0) >> 10;
				 yv1 <= (alpha * yv1 - beta * zv1) >> 10;
				 yv2 <= (alpha * yv2 - beta * zv2) >> 10;
				 yv3 <= (alpha * yv3 - beta * zv3) >> 10;
				 yv4 <= (alpha * yv4 - beta * zv4) >> 10;
				 yv5 <= (alpha * yv5 - beta * zv5) >> 10;
				 yv6 <= (alpha * yv6 - beta * zv6) >> 10;
				 yv7 <= (alpha * yv7 - beta * zv7) >> 10;
				 yv8 <= (alpha * yv8 - beta * zv8) >> 10;
				 yv9 <= (alpha * yv9 - beta * zv9) >> 10;
				 yv10 <= (alpha * yv10 - beta * zv10) >> 10;
				 yv11 <= (alpha * yv11 - beta * zv11) >> 10;

				 zv0 <= (beta * yv0 + alpha * zv0) >> 10;
				 zv1 <= (beta * yv1 + alpha * zv1) >> 10;
				 zv2 <= (beta * yv2 + alpha * zv2) >> 10;
				 zv3 <= (beta * yv3 + alpha * zv3) >> 10;
				 zv4 <= (beta * yv4 + alpha * zv4) >> 10;
				 zv5 <= (beta * yv5 + alpha * zv5) >> 10;
				 zv6 <= (beta * yv6 + alpha * zv6) >> 10;
				 zv7 <= (beta * yv7 + alpha * zv7) >> 10;
				 zv8 <= (beta * yv8 + alpha * zv8) >> 10;
				 zv9 <= (beta * yv9 + alpha * zv9) >> 10;
				 zv10 <= (beta * yv10 + alpha * zv10) >> 10;
				 zv11 <= (beta * yv11 + alpha * zv11) >> 10;
				end
				 
			end

			3: begin // Y
				if(rY) begin
				 xv0 <= (alpha * xv0 + beta * zv0) >> 10;
				 xv1 <= (alpha * xv1 + beta * zv1) >> 10;
				 xv2 <= (alpha * xv2 + beta * zv2) >> 10;
				 xv3 <= (alpha * xv3 + beta * zv3) >> 10;
				 xv4 <= (alpha * xv4 + beta * zv4) >> 10;
				 xv5 <= (alpha * xv5 + beta * zv5) >> 10;
				 xv6 <= (alpha * xv6 + beta * zv6) >> 10;
				 xv7 <= (alpha * xv7 + beta * zv7) >> 10;
				 xv8 <= (alpha * xv8 + beta * zv8) >> 10;
				 xv9 <= (alpha * xv9 + beta * zv9) >> 10;
				 xv10 <= (alpha * xv10 + beta * xv10) >> 10;
				 xv11 <= (alpha * xv11 + beta * xv11) >> 10;

				 zv0 <= (0 - beta * xv0 + alpha * zv0) >> 10;
				 zv1 <= (0 - beta * xv1 + alpha * zv1) >> 10;
				 zv2 <= (0 - beta * xv2 + alpha * zv2) >> 10;
				 zv3 <= (0 - beta * xv3 + alpha * zv3) >> 10;
				 zv4 <= (0 - beta * xv4 + alpha * zv4) >> 10;
				 zv5 <= (0 - beta * xv5 + alpha * zv5) >> 10;
				 zv6 <= (0 - beta * xv6 + alpha * zv6) >> 10;
				 zv7 <= (0 - beta * xv7 + alpha * zv7) >> 10;
				 zv8 <= (0 - beta * xv8 + alpha * zv8) >> 10;
				 zv9 <= (0 - beta * xv9 + alpha * zv9) >> 10;
				 zv10 <= (0 - beta * xv10 + alpha * zv10) >> 10;
				 zv11 <= (0 - beta * xv11 + alpha * zv11) >> 10;
				end
			end

			4: begin // Z
				if(rZ) begin
				 xv0 <= (alpha * xv0 - beta * yv0) >> 10;
				 xv1 <= (alpha * xv1 - beta * yv1) >> 10;
				 xv2 <= (alpha * xv2 - beta * yv2) >> 10;
				 xv3 <= (alpha * xv3 - beta * yv3) >> 10;
				 xv4 <= (alpha * xv4 - beta * yv4) >> 10;
				 xv5 <= (alpha * xv5 - beta * yv5) >> 10;
				 xv6 <= (alpha * xv6 - beta * yv6) >> 10;
				 xv7 <= (alpha * xv7 - beta * yv7) >> 10;
				 xv8 <= (alpha * xv8 - beta * yv8) >> 10;
				 xv9 <= (alpha * xv9 - beta * yv9) >> 10;
				 xv10 <= (alpha * xv10 - beta * yv10) >> 10;
				 xv11 <= (alpha * xv11 - beta * yv11) >> 10;

				 yv0 <= (beta * xv0 + alpha * yv0) >> 10;
				 yv1 <= (beta * xv1 + alpha * yv1) >> 10;
				 yv2 <= (beta * xv2 + alpha * yv2) >> 10;
				 yv3 <= (beta * xv3 + alpha * yv3) >> 10;
				 yv4 <= (beta * xv4 + alpha * yv4) >> 10;
				 yv5 <= (beta * xv5 + alpha * yv5) >> 10;
				 yv6 <= (beta * xv6 + alpha * yv6) >> 10;
				 yv7 <= (beta * xv7 + alpha * yv7) >> 10;
				 yv8 <= (beta * xv8 + alpha * yv8) >> 10;
				 yv9 <= (beta * xv9 + alpha * yv9) >> 10;
				 yv10 <= (beta * xv10 + alpha * yv10) >> 10;
				 yv11 <= (beta * xv11 + alpha * yv11) >> 10;
				 end
			end
			5: begin
				done <= 1;
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
