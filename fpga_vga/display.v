`timescale 1ns / 1ps

module display(
	input CLOCK_50,           // 50 MHz
	input [17:0] SW,
	input [3:0] KEY,
	input [35:0] GPIO,
	output wire [6:0] HEX0, HEX1, HEX2, HEX5, HEX6, HEX7,
	output wire [7:0] LEDG,
   output wire [7:0] LEDR,
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

	// clk divider 50 MHz to 25 MHz
	ip ip1(
		.areset(reset),
		.inclk0(CLOCK_50),
		.c0(clk25MHz),
		.locked()
		);  
	// end clk divider 50 MHz to 25 MHz

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
	
	// gesture UART
	
	wire [7:0] motion_state;
   wire [15:0] lidar_x;
   wire [15:0] lidar_y;
   wire packet_valid;
   wire gpio_0 = GPIO[0];
	wire gpio_1 = GPIO[1];
	 
	wire [7:0] rx_byte;

   UART uart_inst (
       .clk(CLOCK_50),
       .rst(~KEY[0]),
       .gpio_0(gpio_0),
       .motion_state(motion_state),
       .lidar_x_upper(lidar_x[15:8]),
		 .lidar_x_lower(lidar_x[7:0]),
       .lidar_y_upper(lidar_y[15:8]),
		 .lidar_y_lower(lidar_y[7:0]),
		 .rx_byte1(rx_byte),
       .packet_valid(packet_valid)
   );
	 
	reg [31:0] display_timer;
	reg [7:0] current_motion_state;
	reg display_locked;
	
	parameter CLOCK_FREQ = 50_000_000;
	parameter HOLD_TIME = 1.5 * CLOCK_FREQ;
	
	always @(posedge CLOCK_50 or posedge reset) begin
			if (reset) begin
				display_timer <= 0;
				display_locked <= 0;
				current_motion_state <= 1;
			end else begin
				if (packet_valid && !display_locked && motion_state != current_motion_state) begin
					current_motion_state <= motion_state;

					if (motion_state != 1) begin
						display_timer <= HOLD_TIME;
						display_locked <= 1;
					end
				end else if (display_locked) begin
					if (display_timer > 0) begin
						display_timer <= display_timer - 1;
					end else begin
						display_locked <= 0;
						current_motion_state <= motion_state; // Return to idle after holding
					end
				end
			end
	end
	
	parameter DOT_RADIUS = 20;
	parameter origin_x = 155;
	parameter origin_y = 46;
	parameter max_x = 504;
	parameter max_y = 720;
	
	// wire [8:0] input_x = SW[17:9];
	// wire [8:0] input_y = SW[8:0];
	
	wire [15:0] input_x = lidar_x;
	wire [15:0] input_y = lidar_y;
	
	wire [15:0] dot_x = origin_x + input_x;
	wire [15:0] dot_y = origin_y + input_y;
	
	wire [29:0] digit_x100 [0:3];
	wire [29:0] digit_x10 [0:3];
	wire [29:0] digit_x1 [0:3];
	
	wire [3:0] x_100 = input_x / 100;
	wire [3:0] x_10 = (input_x % 100) / 10;
	wire [3:0] x_1 = input_x % 10;
	
	digit digit1(.number(x_100), .digit(digit_x100));
	digit digit2(.number(x_10), .digit(digit_x10));
	digit digit3(.number(x_1), .digit(digit_x1));
	
	wire [29:0] digit_y100 [0:3];
	wire [29:0] digit_y10 [0:3];
	wire [29:0] digit_y1 [0:3];
	
	wire [3:0] y_100 = input_y / 100;
	wire [3:0] y_10 = (input_y % 100) / 10;
	wire [3:0] y_1 = input_y % 10;
	
	digit digit4(.number(y_100), .digit(digit_y100));
	digit digit5(.number(y_10), .digit(digit_y10));
	digit digit6(.number(y_1), .digit(digit_y1));
	
	parameter letter_X = 88;
	wire [29:0] digit_X [0:3];
	letter letter1(.number(letter_X), .digit(digit_X));
	
	parameter letter_Y = 89;
	wire [29:0] digit_Y [0:3];
	letter letter2(.number(letter_Y), .digit(digit_Y));
	
	parameter letter_T = 84;
	wire [29:0] digit_T [0:3];
	letter letter3(.number(letter_T), .digit(digit_T));
	
	parameter letter_A = 65;
	wire [29:0] digit_A [0:3];
	letter letter4(.number(letter_A), .digit(digit_A));
	
	parameter letter_P = 80;
	wire [29:0] digit_P [0:3];
	letter letter5(.number(letter_P), .digit(digit_P));
	
	parameter letter_D = 68;
	wire [29:0] digit_D [0:3];
	letter letter6(.number(letter_D), .digit(digit_D));
	
	parameter letter_R = 82;
	wire [29:0] digit_R [0:3];
	letter letter7(.number(letter_R), .digit(digit_R));
	
	parameter letter_G = 71;
	wire [29:0] digit_G [0:3];
	letter letter8(.number(letter_G), .digit(digit_G));
	
	parameter letter_I = 73;
	wire [29:0] digit_I [0:3];
	letter letter9(.number(letter_I), .digit(digit_I));

	parameter letter_L = 76;
	wire [29:0] digit_L [0:3];
	letter letter10(.number(letter_L), .digit(digit_L));
	
	parameter letter_E = 69;
	wire [29:0] digit_E [0:3];
	letter letter11(.number(letter_E), .digit(digit_E));
	
	// test 
	/*
	hex_decoder hex0 (.in(lidar_y[3:0]),     .out(HEX0));
   hex_decoder hex1 (.in(lidar_y[7:4]),     .out(HEX1));
   hex_decoder hex2 (.in(lidar_y[11:8]),     .out(HEX2));
	hex_decoder hex3 (.in(lidar_y[15:12]),     .out(HEX3));
	
	hex_decoder hex4 (.in(lidar_x[3:0]),     .out(HEX4));
   hex_decoder hex5 (.in(lidar_x[7:4]),     .out(HEX5));
   hex_decoder hex6 (.in(lidar_x[11:8]),     .out(HEX6));
	hex_decoder hex7 (.in(lidar_x[15:12]),     .out(HEX7));
	*/
	 

   // display raw bytes on LEDs
   assign LEDG = motion_state;
	 
	assign LEDR[0] = ~gpio_0;  // should blink
	assign LEDR[1] = ~packet_valid;
	assign gpio_1 = packet_valid;
	
	wire [8:0] x_dimension = SW[17:9];
	wire [8:0] y_dimension = SW[8:0];
	
	wire [19:0] x_pixels_scaled = 565 * x_dimension;
	wire [9:0] x_pixels = x_pixels_scaled / 512;
	
	wire [19:0] y_pixels_scaled = 458 * y_dimension;
	wire [9:0] y_pixels = y_pixels_scaled / 512;
	
	wire [3:0] hex_x_pix100 = x_pixels / 100;
	wire [3:0] hex_x_pix10 = (x_pixels % 100) / 10;
	wire [3:0] hex_x_pix1 = x_pixels % 10;
	
	wire [3:0] hex_y_pix100 = y_pixels / 100;
	wire [3:0] hex_y_pix10 = (y_pixels % 100) / 10;
	wire [3:0] hex_y_pix1 = y_pixels % 10;
	
	hex_decoder hex5 (.in(hex_x_pix1), .out(HEX5));
	hex_decoder hex6 (.in(hex_x_pix10), .out(HEX6));
	hex_decoder hex7 (.in(hex_x_pix100), .out(HEX7));

	hex_decoder hex0 (.in(hex_y_pix1), .out(HEX0));
	hex_decoder hex1 (.in(hex_y_pix10), .out(HEX1));
	hex_decoder hex2 (.in(hex_y_pix100), .out(HEX2));
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// border generate
		always @ (posedge CLOCK_50)
		begin
			
			////////////////////////////////////////////////////////////////////////////////////// SECTION 1
			if (counter_y < 41)
				begin              
					r_red <= 8'hFFFF;    // white
					r_blue <= 8'hFFFF;
					r_green <= 8'hFFFF;
				end  // if (counter_y < 135)
			////////////////////////////////////////////////////////////////////////////////////// END SECTION 1
			
			////////////////////////////////////////////////////////////////////////////////////// SECTION 2
			else if (counter_y >= 41 && counter_y < 46)
				begin 
					if (counter_x < 150)
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
					else if (counter_x < (150 + x_pixels + 10))
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
			else if (counter_y >= 46 && counter_y < (46 + y_pixels))
				begin 
					if (counter_x < 150)
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
					else if (counter_x < 155)
						begin 
							r_red <= 8'h00;    // black
							r_blue <= 8'h00;
							r_green <= 8'h00;
						end
					else if (counter_x < (155 + x_pixels))
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
					else if (counter_x < (155 + x_pixels + 5)) 
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
			else if (counter_y >= (46 + y_pixels) && counter_y < (46 + y_pixels + 5))
				begin 
					if (counter_x < 150)
						begin 
							r_red <= 8'hFFFF;    // white
							r_blue <= 8'hFFFF;
							r_green <= 8'hFFFF;
						end
					else if (counter_x < (150 + x_pixels + 10))
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
			
			
			
			// semicolons
			if (counter_y >= 120 && counter_y < 125 && counter_x >= 740 && counter_x < 745) begin
					r_red   <= 8'hFF;
					r_blue  <= 8'h00;
					r_green <= 8'h00;
			end
			
			if (counter_y >= 120 && counter_y < 125 && counter_x >= 755 && counter_x < 760) begin
					r_red   <= 8'hFF;
					r_blue  <= 8'h00;
					r_green <= 8'h00;
			end
			
			if (counter_y >= 240 && counter_y < 245 && counter_x >= 740 && counter_x < 745) begin
					r_red   <= 8'hFF;
					r_blue  <= 8'h00;
					r_green <= 8'h00;
			end
			
			if (counter_y >= 240 && counter_y < 245 && counter_x >= 755 && counter_x < 760) begin
					r_red   <= 8'hFF;
					r_blue  <= 8'h00;
					r_green <= 8'h00;
			end
			
			
			// Write letter X
			if (counter_y >= 95 && counter_y < 115 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							95, 96, 97, 98, 99: begin
								 if (digit_X[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							100, 101, 102, 103, 104: begin
								 if (digit_X[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							105, 106, 107, 108, 109: begin
								 if (digit_X[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							110, 111, 112, 113, 114: begin
								 if (digit_X[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
			// Write letter Y 
			if (counter_y >= 215 && counter_y < 235 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							215, 216, 217, 218, 219: begin
								 if (digit_Y[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							220, 221, 222, 223, 224: begin
								 if (digit_Y[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							225, 226, 227, 228, 229: begin
								 if (digit_Y[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							230, 231, 232, 233, 234: begin
								 if (digit_Y[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
			// Write Gesture data 
			// TAP
			if (current_motion_state == 2) begin
					if (counter_y >= 400 && counter_y < 420 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							400, 401, 402, 403, 404: begin
								 if (digit_T[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							405, 406, 407, 408, 409: begin
								 if (digit_T[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							410, 411, 412, 413, 414: begin
								 if (digit_T[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							415, 416, 417, 418, 419: begin
								 if (digit_T[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (counter_y >= 425 && counter_y < 445 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							425, 426, 427, 428, 429: begin
								 if (digit_A[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							430, 431, 432, 433, 434: begin
								 if (digit_A[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							435, 436, 437, 438, 439: begin
								 if (digit_A[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							440, 441, 442, 443, 444: begin
								 if (digit_A[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (counter_y >= 450 && counter_y < 470 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							450, 451, 452, 453, 454: begin
								 if (digit_P[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							455, 456, 457, 458, 459: begin
								 if (digit_P[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							460, 461, 462, 463, 464: begin
								 if (digit_P[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							465, 466, 467, 468, 469: begin
								 if (digit_P[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					// Dot
					if (((counter_x - dot_x)*(counter_x - dot_x) + (counter_y - dot_y)*(counter_y - dot_y)) <= (DOT_RADIUS * DOT_RADIUS))
						begin
								if(!((lidar_x == 0) && (lidar_y == 0))) begin
									r_red   <= 8'hFF;
									r_blue  <= 8'h00;
									r_green <= 8'h00;
								end
						end
				end
			
			// DRAG
			if (current_motion_state == 3) begin
					if (counter_y >= 400 && counter_y < 420 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							400, 401, 402, 403, 404: begin
								 if (digit_D[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							405, 406, 407, 408, 409: begin
								 if (digit_D[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							410, 411, 412, 413, 414: begin
								 if (digit_D[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							415, 416, 417, 418, 419: begin
								 if (digit_D[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (counter_y >= 425 && counter_y < 445 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							425, 426, 427, 428, 429: begin
								 if (digit_R[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							430, 431, 432, 433, 434: begin
								 if (digit_R[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							435, 436, 437, 438, 439: begin
								 if (digit_R[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							440, 441, 442, 443, 444: begin
								 if (digit_R[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (counter_y >= 450 && counter_y < 470 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							450, 451, 452, 453, 454: begin
								 if (digit_A[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							455, 456, 457, 458, 459: begin
								 if (digit_A[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							460, 461, 462, 463, 464: begin
								 if (digit_A[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							465, 466, 467, 468, 469: begin
								 if (digit_A[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (counter_y >= 475 && counter_y < 495 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							475, 476, 477, 478, 479: begin
								 if (digit_G[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							480, 481, 482, 483, 484: begin
								 if (digit_G[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							485, 486, 487, 488, 489: begin
								 if (digit_G[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							490, 491, 492, 493, 494: begin
								 if (digit_G[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (((counter_x - dot_x)*(counter_x - dot_x) + (counter_y - dot_y)*(counter_y - dot_y)) <= (DOT_RADIUS * DOT_RADIUS))
						begin
								if(!((lidar_x == 0) && (lidar_y == 0))) begin
									r_red   <= 8'hFF;
									r_blue  <= 8'h00;
									r_green <= 8'h00;
								end
						end
				end
			
			// IDLE
			if (current_motion_state == 1) begin
					if (counter_y >= 400 && counter_y < 420 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							400, 401, 402, 403, 404: begin
								 if (digit_I[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							405, 406, 407, 408, 409: begin
								 if (digit_I[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							410, 411, 412, 413, 414: begin
								 if (digit_I[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							415, 416, 417, 418, 419: begin
								 if (digit_I[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (counter_y >= 425 && counter_y < 445 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							425, 426, 427, 428, 429: begin
								 if (digit_D[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							430, 431, 432, 433, 434: begin
								 if (digit_D[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							435, 436, 437, 438, 439: begin
								 if (digit_D[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							440, 441, 442, 443, 444: begin
								 if (digit_D[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (counter_y >= 450 && counter_y < 470 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							450, 451, 452, 453, 454: begin
								 if (digit_L[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							455, 456, 457, 458, 459: begin
								 if (digit_L[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							460, 461, 462, 463, 464: begin
								 if (digit_L[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							465, 466, 467, 468, 469: begin
								 if (digit_L[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (counter_y >= 475 && counter_y < 495 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							475, 476, 477, 478, 479: begin
								 if (digit_E[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							480, 481, 482, 483, 484: begin
								 if (digit_E[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							485, 486, 487, 488, 489: begin
								 if (digit_E[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							490, 491, 492, 493, 494: begin
								 if (digit_E[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'h00;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							
					  endcase
					end
					
					if (((counter_x - dot_x)*(counter_x - dot_x) + (counter_y - dot_y)*(counter_y - dot_y)) <= (DOT_RADIUS * DOT_RADIUS))
						begin
								if(!((lidar_x == 0) && (lidar_y == 0))) begin
									r_red   <= 8'hFF;
									r_blue  <= 8'h00;
									r_green <= 8'h00;
								end
						end
					
				end
			
			// X INPUT
			if (counter_y >= 180 && counter_y < 200 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							180, 181, 182, 183, 184: begin
								 if (digit_x1[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							185, 186, 187, 188, 189: begin
								 if (digit_x1[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							190, 191, 192, 193, 194: begin
								 if (digit_x1[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							195, 196, 197, 198, 199: begin
								 if (digit_x1[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
			if (counter_y >= 155 && counter_y < 175 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							155, 156, 157, 158, 159: begin
								 if (digit_x10[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							160, 161, 162, 163, 164: begin
								 if (digit_x10[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							165, 166, 167, 168, 169: begin
								 if (digit_x10[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							170, 171, 172, 173, 174: begin
								 if (digit_x10[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
			
			if (counter_y >= 130 && counter_y < 150 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							130, 131, 132, 133, 134: begin
								 if (digit_x100[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							135, 136, 137, 138, 139: begin
								 if (digit_x100[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							140, 141, 142, 143, 144: begin
								 if (digit_x100[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							145, 146, 147, 148, 149: begin
								 if (digit_x100[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
			// Y INPUT
			if (counter_y >= 300 && counter_y < 320 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							300, 301, 302, 303, 304: begin
								 if (digit_y1[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							305, 306, 307, 308, 309: begin
								 if (digit_y1[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							310, 311, 312, 313, 314: begin
								 if (digit_y1[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							315, 316, 317, 318, 319: begin
								 if (digit_y1[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
				
			if (counter_y >= 275 && counter_y < 295 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							275, 276, 277, 278, 279: begin
								 if (digit_y10[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							280, 281, 282, 283, 284: begin
								 if (digit_y10[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							285, 286, 287, 288, 289: begin
								 if (digit_y10[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							290, 291, 292, 293, 294: begin
								 if (digit_y10[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end
			
			if (counter_y >= 250 && counter_y < 270 && counter_x >= 735 && counter_x < 765) begin
					  case (counter_y)
							250, 251, 252, 253, 254: begin
								 if (digit_y100[0][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							255, 256, 257, 258, 259: begin
								 if (digit_y100[1][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							260, 261, 262, 263, 264: begin
								 if (digit_y100[2][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
							265, 266, 267, 268, 269: begin
								 if (digit_y100[3][29 - (counter_x - 735)]) begin
									  r_red   <= 8'hFF;
									  r_blue  <= 8'h00;
									  r_green <= 8'h00;
								 end
							end
					  endcase
				end	
				
		end  // always
						
	// end pattern generate

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// color output assignments
	assign VGA_R = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_red : 8'h0;
	assign VGA_B = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_blue : 8'h0;
	assign VGA_G = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_green : 8'h0;
	// end color output assignments
	
endmodule  // VGA_image_gen
