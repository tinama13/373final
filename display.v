`timescale 1ns / 1ps

// image generator of a road and a sky 640x480 @ 60 fps

////////////////////////////////////////////////////////////////////////
module display(
	input CLOCK_50,           // 50 MHz
	input [17:0] SW,
	input [3:0] KEY,
	output VGA_HS,
	output VGA_VS,
	output VGA_CLK,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B
);

	reg [9:0] counter_x = 0;  // horizontal counter
	reg [9:0] counter_y = 0;  // vertical counter
	reg [7:0] r_red = 0;
	reg [7:0] r_blue = 0;
	reg [7:0] r_green = 0;
	
	reg reset = 0;  // for PLL
	
	wire clk25MHz;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// clk divider 50 MHz to 25 MHz
	ip ip1(
		.areset(reset),
		.inclk0(CLOCK_50),
		.c0(clk25MHz),
		.locked()
		);  
	// end clk divider 50 MHz to 25 MHz

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// counter and sync generation
	always @(posedge clk25MHz)  // horizontal counter
		begin 
			if (counter_x < 799)
				counter_x <= counter_x + 1;  // horizontal counter (including off-screen horizontal 160 pixels) total of 800 pixels 
			else
				counter_x <= 0;              
		end  // always 
	
	always @ (posedge clk25MHz)  // vertical counter
		begin 
			if (counter_x == 799)  // only counts up 1 count after horizontal finishes 800 counts
				begin
					if (counter_y < 525)  // vertical counter (including off-screen vertical 45 pixels) total of 525 pixels
						counter_y <= counter_y + 1;
					else
						counter_y <= 0;              
				end  // if (counter_x...
		end  // always
	// end counter and sync generation  

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// hsync and vsync output assignments
	assign VGA_HS = (counter_x >= 0 && counter_x < 96) ? 1:0;  // hsync high for 96 counts                                                 
	assign VGA_VS = (counter_y >= 0 && counter_y < 2) ? 1:0;   // vsync high for 2 counts
	assign VGA_CLK = clk25MHz;
	// end hsync and vsync output assignments
	
	parameter DOT_RADIUS = 3;
	parameter origin_x = 170;
	parameter origin_y = 141;
	parameter max_x = 580;
	parameter max_y = 218;
	
	wire [8:0] input_x = SW[17:9];
	wire [8:0] input_y = SW[8:0];
	
	wire [9:0] dot_x = origin_x + input_x;
	wire [9:0] dot_y = origin_y + input_y;
	
	wire [19:0] digit_x100 [0:5];
	wire [19:0] digit_x10 [0:5];
	wire [19:0] digit_x1 [0:5];
	
	wire [3:0] x_100 = input_x / 100;
	wire [3:0] x_10 = (input_x % 100) / 10;
	wire [3:0] x_1 = input_x % 10;
	
	digit digit1(.number(x_100), .digit(digit_x100));
	digit digit2(.number(x_10), .digit(digit_x10));
	digit digit3(.number(x_1), .digit(digit_x1));
	
	wire [19:0] digit_y100 [0:5];
	wire [19:0] digit_y10 [0:5];
	wire [19:0] digit_y1 [0:5];
	
	wire [3:0] y_100 = input_y / 100;
	wire [3:0] y_10 = (input_y % 100) / 10;
	wire [3:0] y_1 = input_y % 10;
	
	digit digit4(.number(y_100), .digit(digit_y100));
	digit digit5(.number(y_10), .digit(digit_y10));
	digit digit6(.number(y_1), .digit(digit_y1));

	parameter letter_G = 71;
	wire [19:0] digit_G [0:5];
	letter letter1(.number(letter_G), .digit(digit_G));
	
	parameter letter_E = 69;
	wire [19:0] digit_E [0:5];
	letter letter2(.number(letter_E), .digit(digit_E));
	
	parameter letter_S = 83;
	wire [19:0] digit_S [0:5];
	letter letter3(.number(letter_S), .digit(digit_S));
	
	parameter letter_T = 84;
	wire [19:0] digit_T [0:5];
	letter letter4(.number(letter_T), .digit(digit_T));
	
	parameter letter_U = 85;
	wire [19:0] digit_U [0:5];
	letter letter5(.number(letter_U), .digit(digit_U));
	
	parameter letter_R = 82;
	wire [19:0] digit_R [0:5];
	letter letter6(.number(letter_R), .digit(digit_R));
	
	parameter letter_A = 65;
	wire [19:0] digit_A [0:5];
	letter letter7(.number(letter_A), .digit(digit_A));
	
	parameter letter_P = 80;
	wire [19:0] digit_P [0:5];
	letter letter8(.number(letter_P), .digit(digit_P));
	
	parameter letter_D = 68;
	wire [19:0] digit_D [0:5];
	letter letter9(.number(letter_D), .digit(digit_D));
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// pattern generate
		always @ (posedge CLOCK_50)
		begin
			
			////////////////////////////////////////////////////////////////////////////////////// SECTION 1
			if (counter_y < 136)
				begin              
					r_red <= 8'hFFFF;    // white
					r_blue <= 8'hFFFF;
					r_green <= 8'hFFFF;
				end  // if (counter_y < 135)
			////////////////////////////////////////////////////////////////////////////////////// END SECTION 1
			
			////////////////////////////////////////////////////////////////////////////////////// SECTION 2
			else if (counter_y >= 136 && counter_y < 141)
				begin 
					if (counter_x < 165)
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
					else if (counter_x < 755)
						begin 
							r_red <= 8'h0;    // black
							r_blue <= 8'h0;
							r_green <= 8'h0;
						end
					else
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
				end
			////////////////////////////////////////////////////////////////////////////////////// END SECTION 2

			////////////////////////////////////////////////////////////////////////////////////// SECTION 3
			else if (counter_y >= 141 && counter_y < 359)
				begin 
					if (counter_x < 165)
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
					else if (counter_x < 170)
						begin 
							r_red <= 8'h00;    // black
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					else if (counter_x < 750)
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
					else if (counter_x < 755)
						begin 
							r_red <= 8'h00;    // black
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					else
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
				end
			////////////////////////////////////////////////////////////////////////////////////// END SECTION 3

			////////////////////////////////////////////////////////////////////////////////////// SECTION 4
			else if (counter_y >= 359 && counter_y < 364)
				begin 
					if (counter_x < 165)
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
					else if (counter_x < 755)
						begin 
							r_red <= 8'h0;    // black
							r_blue <= 8'h0;
							r_green <= 8'h0;
						end
					else
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
				end
			////////////////////////////////////////////////////////////////////////////////////// END SECTION 4
			
			////////////////////////////////////////////////////////////////////////////////////// SECTION 5
			else
				begin
					r_red <= 8'hFFFF;    // white
					r_blue <= 8'hFFFF;
					r_green <= 8'hFFFF;
				end
			////////////////////////////////////////////////////////////////////////////////////// END SECTION 5
			
			if (counter_x >= (dot_x - DOT_RADIUS) && counter_x <= (dot_x + DOT_RADIUS) &&
					counter_y >= (dot_y - DOT_RADIUS) && counter_y <= (dot_y + DOT_RADIUS))
					begin
						r_red <= 8'hFFFF;    // red
						r_blue <= 8'h00;
						r_green <= 8'h00;
					end
			
			if (counter_y >= 74 && counter_y < 79)
				begin
					if (counter_x >= 468 && counter_x < 473)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 488 && counter_x < 493)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 338 && counter_x < 343)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 348 && counter_x < 353)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 358 && counter_x < 363)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 583 && counter_x < 588)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
				end

			if (counter_y >= 79 && counter_y < 84)
				begin
					if (counter_x >= 468 && counter_x < 473)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 488 && counter_x < 493)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 498 && counter_x < 503)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 333 && counter_x < 338)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 348 && counter_x < 353)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 358 && counter_x < 363)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 368 && counter_x < 373)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 588 && counter_x < 593)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
				end

			if (counter_y >= 84 && counter_y < 89)
				begin
					if (counter_x >= 473 && counter_x < 478)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 483 && counter_x < 488)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 333 && counter_x < 338)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 353 && counter_x < 358)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 588 && counter_x < 593)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
				end

			if (counter_y >= 89 && counter_y < 94)
				begin
					if (counter_x >= 478 && counter_x < 483)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 333 && counter_x < 338)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 348 && counter_x < 353)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 358 && counter_x < 363)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 588 && counter_x < 593)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
				end

			if (counter_y >= 94 && counter_y < 99)
				begin
					if (counter_x >= 478 && counter_x < 483)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 498 && counter_x < 503)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 333 && counter_x < 338)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 348 && counter_x < 353)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 358 && counter_x < 363)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 368 && counter_x < 373)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 588 && counter_x < 593)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
				end

			if (counter_y >= 99 && counter_y < 104)
				begin
					if (counter_x >= 478 && counter_x < 483)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 458 && counter_x < 463)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 338 && counter_x < 343)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 348 && counter_x < 353)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 358 && counter_x < 363)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					if (counter_x >= 583 && counter_x < 588)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
				end
			
			if (counter_y >= 104 && counter_y < 109)
				begin
					if (counter_x >= 453 && counter_x < 458)
						begin 
							r_red <= 8'h00;
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
				end
			
			// X INPUT
			if (counter_y >= 74 && counter_y < 104 && counter_x >= 428 && counter_x < 448) begin
					  case (counter_y)
							74, 75, 76, 77, 78: begin
								 if (digit_x1[0][19 - (counter_x - 428)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							79, 80, 81, 82, 83: begin
								 if (digit_x1[1][19 - (counter_x - 428)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							84, 85, 86, 87, 88: begin
								 if (digit_x1[2][19 - (counter_x - 428)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							89, 90, 91, 92, 93: begin
								 if (digit_x1[3][19 - (counter_x - 428)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							94, 95, 96, 97, 98: begin
								 if (digit_x1[4][19 - (counter_x - 428)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							99, 100, 101, 102, 103: begin
								 if (digit_x1[5][19 - (counter_x - 428)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
			if (counter_y >= 74 && counter_y < 104 && counter_x >= 403 && counter_x < 423) begin
					  case (counter_y)
							74, 75, 76, 77, 78: begin
								 if (digit_x10[0][19 - (counter_x - 403)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							79, 80, 81, 82, 83: begin
								 if (digit_x10[1][19 - (counter_x - 403)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							84, 85, 86, 87, 88: begin
								 if (digit_x10[2][19 - (counter_x - 403)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							89, 90, 91, 92, 93: begin
								 if (digit_x10[3][19 - (counter_x - 403)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							94, 95, 96, 97, 98: begin
								 if (digit_x10[4][19 - (counter_x - 403)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							99, 100, 101, 102, 103: begin
								 if (digit_x10[5][19 - (counter_x - 403)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
			
			if (counter_y >= 74 && counter_y < 104 && counter_x >= 378 && counter_x < 398) begin
					  case (counter_y)
							74, 75, 76, 77, 78: begin
								 if (digit_x100[0][19 - (counter_x - 378)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							79, 80, 81, 82, 83: begin
								 if (digit_x100[1][19 - (counter_x - 378)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							84, 85, 86, 87, 88: begin
								 if (digit_x100[2][19 - (counter_x - 378)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							89, 90, 91, 92, 93: begin
								 if (digit_x100[3][19 - (counter_x - 378)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							94, 95, 96, 97, 98: begin
								 if (digit_x100[4][19 - (counter_x - 378)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							99, 100, 101, 102, 103: begin
								 if (digit_x100[5][19 - (counter_x - 378)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
			// Y INPUT
			if (counter_y >= 74 && counter_y < 104 && counter_x >= 558 && counter_x < 578) begin
					  case (counter_y)
							74, 75, 76, 77, 78: begin
								 if (digit_y1[0][19 - (counter_x - 558)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							79, 80, 81, 82, 83: begin
								 if (digit_y1[1][19 - (counter_x - 558)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							84, 85, 86, 87, 88: begin
								 if (digit_y1[2][19 - (counter_x - 558)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							89, 90, 91, 92, 93: begin
								 if (digit_y1[3][19 - (counter_x - 558)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							94, 95, 96, 97, 98: begin
								 if (digit_y1[4][19 - (counter_x - 558)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							99, 100, 101, 102, 103: begin
								 if (digit_y1[5][19 - (counter_x - 558)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
			if (counter_y >= 74 && counter_y < 104 && counter_x >= 533 && counter_x < 553) begin
					  case (counter_y)
							74, 75, 76, 77, 78: begin
								 if (digit_y10[0][19 - (counter_x - 533)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							79, 80, 81, 82, 83: begin
								 if (digit_y10[1][19 - (counter_x - 533)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							84, 85, 86, 87, 88: begin
								 if (digit_y10[2][19 - (counter_x - 533)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							89, 90, 91, 92, 93: begin
								 if (digit_y10[3][19 - (counter_x - 533)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							94, 95, 96, 97, 98: begin
								 if (digit_y10[4][19 - (counter_x - 533)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							99, 100, 101, 102, 103: begin
								 if (digit_y10[5][19 - (counter_x - 533)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
			
			if (counter_y >= 74 && counter_y < 104 && counter_x >= 508 && counter_x < 528) begin
					  case (counter_y)
							74, 75, 76, 77, 78: begin
								 if (digit_y100[0][19 - (counter_x - 508)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							79, 80, 81, 82, 83: begin
								 if (digit_y100[1][19 - (counter_x - 508)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							84, 85, 86, 87, 88: begin
								 if (digit_y100[2][19 - (counter_x - 508)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							89, 90, 91, 92, 93: begin
								 if (digit_y100[3][19 - (counter_x - 508)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							94, 95, 96, 97, 98: begin
								 if (digit_y100[4][19 - (counter_x - 508)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							99, 100, 101, 102, 103: begin
								 if (digit_y100[5][19 - (counter_x - 508)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
			// Gesture
			if (counter_y >= 422 && counter_y < 452 && counter_x >= 200 && counter_x < 220) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_G[0][19 - (counter_x - 200)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_G[1][19 - (counter_x - 200)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_G[2][19 - (counter_x - 200)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_G[3][19 - (counter_x - 200)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_G[4][19 - (counter_x - 200)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_G[5][19 - (counter_x - 200)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
				if (counter_y >= 422 && counter_y < 452 && counter_x >= 224 && counter_x < 244) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_E[0][19 - (counter_x - 224)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_E[1][19 - (counter_x - 224)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_E[2][19 - (counter_x - 224)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_E[3][19 - (counter_x - 224)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_E[4][19 - (counter_x - 224)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_E[5][19 - (counter_x - 224)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
				if (counter_y >= 422 && counter_y < 452 && counter_x >= 248 && counter_x < 268) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_S[0][19 - (counter_x - 248)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_S[1][19 - (counter_x - 248)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_S[2][19 - (counter_x - 248)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_S[3][19 - (counter_x - 248)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_S[4][19 - (counter_x - 248)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_S[5][19 - (counter_x - 248)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
				if (counter_y >= 422 && counter_y < 452 && counter_x >= 273 && counter_x < 293) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_T[0][19 - (counter_x - 273)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_T[1][19 - (counter_x - 273)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_T[2][19 - (counter_x - 273)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_T[3][19 - (counter_x - 273)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_T[4][19 - (counter_x - 273)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_T[5][19 - (counter_x - 273)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
				if (counter_y >= 422 && counter_y < 452 && counter_x >= 298 && counter_x < 318) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_U[0][19 - (counter_x - 298)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_U[1][19 - (counter_x - 298)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_U[2][19 - (counter_x - 298)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_U[3][19 - (counter_x - 298)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_U[4][19 - (counter_x - 298)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_U[5][19 - (counter_x - 298)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
				if (counter_y >= 422 && counter_y < 452 && counter_x >= 323 && counter_x < 343) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_R[0][19 - (counter_x - 323)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_R[1][19 - (counter_x - 323)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_R[2][19 - (counter_x - 323)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_R[3][19 - (counter_x - 323)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_R[4][19 - (counter_x - 323)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_R[5][19 - (counter_x - 323)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
				if (counter_y >= 422 && counter_y < 452 && counter_x >= 348 && counter_x < 368) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_E[0][19 - (counter_x - 348)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_E[1][19 - (counter_x - 348)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_E[2][19 - (counter_x - 348)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_E[3][19 - (counter_x - 348)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_E[4][19 - (counter_x - 348)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_E[5][19 - (counter_x - 348)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
				if (counter_y >= 427 && counter_y < 432 && counter_x >= 373 && counter_x < 378) begin
						r_red   <= 8'h00;
						r_blue  <= 8'h00;
						r_green <= 8'h00;
				end
				
				if (counter_y >= 442 && counter_y < 447 && counter_x >= 373 && counter_x < 378) begin
						r_red   <= 8'h00;
						r_blue  <= 8'h00;
						r_green <= 8'h00;
				end
				
				if (~KEY[0]) begin
					if (counter_y >= 422 && counter_y < 452 && counter_x >= 383 && counter_x < 403) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_T[0][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_T[1][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_T[2][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_T[3][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_T[4][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_T[5][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
					end
					
					if (counter_y >= 422 && counter_y < 452 && counter_x >= 408 && counter_x < 428) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_A[0][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_A[1][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_A[2][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_A[3][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_A[4][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_A[5][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
					end
					
					if (counter_y >= 422 && counter_y < 452 && counter_x >= 433 && counter_x < 453) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_P[0][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_P[1][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_P[2][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_P[3][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_P[4][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_P[5][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
					end
				end
				
				if (~KEY[1]) begin
					if (counter_y >= 422 && counter_y < 452 && counter_x >= 383 && counter_x < 403) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_D[0][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_D[1][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_D[2][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_D[3][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_D[4][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_D[5][19 - (counter_x - 383)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
					end
					
					if (counter_y >= 422 && counter_y < 452 && counter_x >= 408 && counter_x < 428) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_R[0][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_R[1][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_R[2][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_R[3][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_R[4][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_R[5][19 - (counter_x - 408)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
					end
					
					if (counter_y >= 422 && counter_y < 452 && counter_x >= 433 && counter_x < 453) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_A[0][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_A[1][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_A[2][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_A[3][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_A[4][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_A[5][19 - (counter_x - 433)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
					end
					
					if (counter_y >= 422 && counter_y < 452 && counter_x >= 458 && counter_x < 478) begin
					  case (counter_y)
							422, 423, 424, 425, 426: begin
								 if (digit_G[0][19 - (counter_x - 458)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							427, 428, 429, 430, 431: begin
								 if (digit_G[1][19 - (counter_x - 458)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							432, 433, 434, 435, 436: begin
								 if (digit_G[2][19 - (counter_x - 458)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							437, 438, 439, 440, 441: begin
								 if (digit_G[3][19 - (counter_x - 458)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							442, 443, 444, 445, 446: begin
								 if (digit_G[4][19 - (counter_x - 458)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							447, 448, 449, 450, 451: begin
								 if (digit_G[5][19 - (counter_x - 458)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
					end
				end
		end  // always
						
	// end pattern generate

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// color output assignments
	// only output the colors if the counters are within the adressable video time constraints
	assign VGA_R = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_red : 8'h0;
	assign VGA_B = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_blue : 8'h0;
	assign VGA_G = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_green : 8'h0;
	// end color output assignments
	
endmodule  // VGA_image_gen