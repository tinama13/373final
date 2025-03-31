`timescale 1ns / 1ps

// image generator of a road and a sky 640x480 @ 60 fps

////////////////////////////////////////////////////////////////////////
module display(
	input CLOCK_50,           // 50 MHz
	input [17:0] SW,
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
	
	parameter origin_x = 170;
	parameter origin_y = 141;
	parameter max_x = 580;
	parameter max_y = 218;
	
	wire [8:0] input_x = SW[17:9];
	wire [8:0] input_y = SW[8:0];
	
	wire [9:0] dot_x = origin_x + input_x;
	wire [9:0] dot_y = origin_y + input_y;

	reg [19:0] digit_0 [0:5];
	initial begin
		digit_0[0] = 19'b00000111111111100000;
		digit_0[1] = 19'b11111000000000011111;
		digit_0[2] = 19'b11111000000000011111;
		digit_0[3] = 19'b11111000000000011111;
		digit_0[4] = 19'b11111000000000011111;
		digit_0[5] = 19'b00000111111111100000;
	end

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// pattern generate
		always @ (posedge CLOCK_50)
		begin
			r_red <= 8'hFF;
			r_blue <= 8'hFF;
			r_green <= 8'hFF;
			
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
			
			if (counter_x == dot_x && counter_y == dot_y) 
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
				
			if (counter_y >= 200 && counter_y < 220 && counter_x >= 200 && counter_x < 220)
				begin 
					
					if (digit_0[counter_y - 200][19-(counter_x - 200)]) begin
						r_red <= 8'h00;
						r_blue <= 8'h00;
						r_green <= 8'h00;
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
