module UART (
    input wire clk,
    input wire rst,
    input wire gpio_0,

    output reg [7:0] motion_state,
    output reg [7:0] lidar_x_upper,
	 output reg [7:0] lidar_x_lower,
    output reg [7:0] lidar_y_upper,
	 output reg [7:0] lidar_y_lower,
	 output reg [7:0] rx_byte1,
    output reg       packet_valid
);

    parameter CLK_FREQ   = 50000000;
    parameter BAUD_RATE  = 9600;
    parameter PAYLOAD_BITS = 8;

    // FSM states
    localparam IDLE   = 3'd0;
    localparam HEADER = 3'd1;
    localparam BYTE1  = 3'd2;
    localparam BYTE2  = 3'd3;
    localparam BYTE3  = 3'd4;
    localparam BYTE4  = 3'd5;
	 localparam BYTE5  = 3'd6;
	 localparam BYTE6  = 3'd7;

    reg [2:0] s, ns;

    // UART receiver interface
    wire rx_dv;
    wire [7:0] rx_byte;

    uart_rx #(
        .CLK_HZ(CLK_FREQ),
        .BIT_RATE(BAUD_RATE),
        .PAYLOAD_BITS(PAYLOAD_BITS)
    ) uart_rx_inst (
        .clk(clk),
        .resetn(~rst),
        .uart_rxd(gpio_0),
        .uart_rx_en(1'b1),
        .uart_rx_break(),
        .uart_rx_valid(rx_dv),
        .uart_rx_data(rx_byte)
    );
	 
	 always @(posedge clk) begin
       rx_byte1 <= rx_byte;
    end

    // FSM next state logic
    always @(*) begin
        ns = s;
        case (s)
            IDLE  : if (rx_byte == 8'hAA) ns = HEADER;
            HEADER: if (rx_dv) ns = BYTE1;
            BYTE1 : if (rx_dv) ns = BYTE2;
            BYTE2 : if (rx_dv) ns = BYTE3;
            BYTE3 : if (rx_dv) ns = BYTE4;
				BYTE4 : if (rx_dv) ns = BYTE5;
				BYTE5 : if (rx_dv) ns = BYTE6;
            BYTE6 : if (rx_dv) ns = IDLE;
            default: ns = IDLE;
        endcase
    end

    // FSM state register
    always @(posedge clk) begin
        if (rst)
            s <= IDLE;
        else
            s <= ns;
    end

    // Register capture logic
    always @(posedge clk) begin
        if (rst) begin
            motion_state <= 8'd0;
            lidar_x_upper      <= 8'd0;
				lidar_x_lower      <= 8'd0;
            lidar_y_upper      <= 8'd0;
				lidar_y_lower      <= 8'd0;
            packet_valid <= 1'b0;
        end else begin
            packet_valid <= 1'b0; // Default: clear valid

            if (rx_dv) begin
                case (s)
                    BYTE1: motion_state <= rx_byte;
                    BYTE2: lidar_x_upper      <= rx_byte;
						  BYTE3: lidar_x_lower      <= rx_byte;
                    BYTE4: lidar_y_upper      <= rx_byte;
						  BYTE5: lidar_y_lower      <= rx_byte;
                    BYTE6: packet_valid <= 1'b1; // Full packet received
                endcase
            end
        end
    end

endmodule



