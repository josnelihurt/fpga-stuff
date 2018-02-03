module tm1638_keys_display
(
	input		clk_5MHz,
	input		n_rst,
	input 		display_off,
    input [2:0] display_level,
	input [7:0] digit1,
    input [7:0] digit2,
    input [7:0] digit3,
    input [7:0] digit4,
    input [7:0] digit5,
    input [7:0] digit6,
    input [7:0] digit7,
    input [7:0] digit8,
	input [7:0] leds_green,
	input [7:0] leds_red,
		
    output reg [7:0] keys,
    output reg tm1638_strobe,
    output tm1638_clk,
    inout  tm1638_data_io
);
	localparam 
        HIGH    = 1'b1,
        LOW     = 1'b0;

    localparam [7:0]
        C_READ  = 8'b0100_0010,
        C_WRITE = 8'b0100_0000,
        C_DISP  = 8'b1000_1111,
        C_ADDR  = 8'b1100_0000;

    reg [5:0] instruction_step;
    wire [5:0] instruction_step_next;
    reg flush_reg;

    // set up tristate IO pin for display
	reg tm1638_data_oe ;
	wire tm1638_data_input;
	wire tm1638_data_output;
		
	assign tm1638_data_io = ( tm1638_data_oe ) ? tm1638_data_output : 1'bZ ; //DIO
	assign tm1638_data_input = tm1638_data_io;
    // setup tm1638 module with it's tristate IO
    //   tm_in      is read from module
    //   tm_out     is written to module
    //   tm_latch   triggers the module to read/write display
    //   tm1638_data_oe      selects read or write mode to display
    //   busy       indicates when module is busy
    //                (another latch will interrupt)
    //   tm_clk     is the data clk
    //   dio_in     for reading from display
    //   dio_out    for sending to display
    //
    //   tm_data    the tristate io pin to module
    reg tm_latch;
    wire busy;
    wire [7:0] tm_data, tm_in;
    reg [7:0] tm_out;


    assign tm_in = tm_data;
    assign tm_data = tm1638_data_oe ? tm_out : 8'hZZ;


    tm1638 u_tm1638 (
        .clk(clk_5MHz),
        .rst(n_rst),
        .data_latch(tm_latch),
        .data(tm_data),
        .rw(tm1638_data_oe),
        .busy(busy),
        .sclk(tm1638_clk),
        .dio_in(tm1638_data_input),
        .dio_out(tm1638_data_output)
    );

	assign instruction_step_next = instruction_step + 1;
    always @(posedge clk_5MHz, posedge n_rst) begin
        if (n_rst) begin
            instruction_step <= 6'b0;
            tm1638_strobe <= HIGH;
            tm1638_data_oe <= HIGH;

            flush_reg <= 0;
            keys <= 8'b0;

        end else 
        begin

            if (flush_reg && ~busy) 
            begin
                case (instruction_step)
                    // *** KEYS ***
                    1:  {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    2:  {tm_latch, tm_out} <= {HIGH, C_READ}; // read mode
                    3:  {tm_latch, tm1638_data_oe}  <= {HIGH, LOW};

                    //  read back keys S1 - S8
                    4:  {keys[7],keys[3]} <= {tm_in[0], tm_in[4]};
                    5:  {tm_latch}         <= {HIGH};
                    6:  {keys[6],keys[2]} <= {tm_in[0], tm_in[4]};
                    7:  {tm_latch}         <= {HIGH};
                    8:  {keys[5],keys[1]} <= {tm_in[0], tm_in[4]};
                    9:  {tm_latch}         <= {HIGH};
                    10: {keys[4],keys[0]} <= {tm_in[0], tm_in[4]};
                    11: {tm1638_strobe}    <= {HIGH};

                    // *** DISPLAY ***
                    12: {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    13: {tm_latch, tm_out} <= {HIGH, C_WRITE}; // write mode
                    14: {tm1638_strobe}            <= {HIGH};

                    15: {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    16: {tm_latch, tm_out} <= {HIGH, C_ADDR}; // set addr 0 pos

                    17: {tm_latch, tm_out} <= {HIGH, digit1};           // Digit 
                    18: {tm_latch, tm_out} <= {HIGH, {6'b0, leds_red[7], leds_green[7]}}; // LED
                    
                    19: {tm_latch, tm_out} <= {HIGH, digit2};           // Digit 
                    20: {tm_latch, tm_out} <= {HIGH, {6'b0, leds_red[6], leds_green[6]}}; // LED

                    21: {tm_latch, tm_out} <= {HIGH, digit3};           // Digit 
                    22: {tm_latch, tm_out} <= {HIGH, {6'b0, leds_red[5], leds_green[5]}}; // LED

                    23: {tm_latch, tm_out} <= {HIGH, digit4};           // Digit 
                    24: {tm_latch, tm_out} <= {HIGH, {6'b0, leds_red[4], leds_green[4]}}; // LED

                    25: {tm_latch, tm_out} <= {HIGH, digit5};           // Digit 
                    26: {tm_latch, tm_out} <= {HIGH, {6'b0, leds_red[3], leds_green[3]}}; // LED

                    27: {tm_latch, tm_out} <= {HIGH, digit6};           // Digit 
                    28: {tm_latch, tm_out} <= {HIGH, {6'b0, leds_red[2], leds_green[2]}}; // LED

                    29: {tm_latch, tm_out} <= {HIGH, digit7};           // Digit 
                    30: {tm_latch, tm_out} <= {HIGH, {6'b0, leds_red[1], leds_green[1]}}; // LED

                    31: {tm_latch, tm_out} <= {HIGH, digit8};           // Digit 
                    32: {tm_latch, tm_out} <= {HIGH, {6'b0, leds_red[0], leds_green[0]}}; // LED

                    33: {tm1638_strobe}            <= {HIGH};

                    34: {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    35: {tm_latch, tm_out} <= {HIGH, 4'b1000, ~display_off, display_level};
                    36: {tm1638_strobe, instruction_step} <= {HIGH, 6'b0};

                endcase

                instruction_step <= instruction_step_next;

            end else if (busy) 
            begin
                // pull latch low next clock cycle after module has been
                // latched
                tm_latch <= LOW;
            end

            flush_reg <= ~flush_reg;
        end
    end
    
endmodule
