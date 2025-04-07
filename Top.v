module Top (
    input wire CLOCK_50,
    input wire [3:0] KEY,
    inout wire [35:0] GPIO,  // UART RX

    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output wire [7:0] LEDG,
    output wire [7:0] LEDR
);

    wire [7:0] motion_state;
    wire [7:0] lidar_x;
    wire [7:0] lidar_y;
    wire packet_valid;
    wire gpio_0 = GPIO[0];
	 wire gpio_1 = GPIO[1];
	 
	 
	 wire [7:0] rx_byte;

    UART uart_inst (
        .clk(CLOCK_50),
        .rst(~KEY[0]),
        .gpio_0(gpio_0),
        .motion_state(motion_state),
        .lidar_x(lidar_x),
        .lidar_y(lidar_y),
		  .rx_byte1(rx_byte),
        .packet_valid(packet_valid)
    );

    //display lower 4 bits on HEX displays
    hex_decoder hex0 (.in(lidar_y[3:0]),     .out(HEX0));
    hex_decoder hex1 (.in(lidar_y[7:4]),     .out(HEX1));
    hex_decoder hex2 (.in(lidar_x[3:0]),     .out(HEX2));
	 hex_decoder hex3 (.in(lidar_x[7:4]),     .out(HEX3));
	 
	 hex_decoder hex4 (.in(rx_byte[3:0]), .out(HEX4));
	 hex_decoder hex5 (.in(rx_byte[7:4]), .out(HEX5));

    // display raw bytes on LEDs
    assign LEDG = motion_state;
    assign LEDR[7:2] = lidar_x[5:0];

    // sanity checker led
    assign LEDR[0] = ~gpio_0;  // should blink
	 assign LEDR[1] = ~packet_valid;
	 assign gpio_1 = packet_valid;

endmodule
