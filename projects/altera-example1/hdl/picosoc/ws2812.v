`default_nettype none
module ws2812 (
    input [23:0] rgb_data,
    input [7:0] led_num,
    input write,
    input reset,
    input clk,  //12MHz

    output reg data
);
    parameter NUM_LEDS = 8;

    /*
    great information here:

    * https://cpldcpu.wordpress.com/2014/01/14/light_ws2812-library-v2-0-part-i-understanding-the-ws2812/
    * https://github.com/japaric/ws2812b/blob/master/firmware/README.md

    period 1200ns:
        * t on  800ns
        * t off 400ns

    end of frame/reset is > 50us. I had a bug at 50us, so increased to 65us

    clock period at 12MHz = 83ns:
        * t on  counter = 10, makes t_on  = 833ns
        * t off counter = 5,  makes t_off = 416ns
        * reset is 800 counts             = 65us

    clock period at 16MHz = 62.5ns:
        * t on  counter = 13, makes t_on  = 812ns
        * t off counter = 7,  makes t_off = 437
        * reset is 960 counts             = 63us
    */
    parameter t_on = 13;
    parameter t_off = 7;
    parameter t_reset = 1020;
    localparam t_period = t_on + t_off;

    initial data = 0;

    reg [23:0] led_reg [NUM_LEDS-1:0];

    reg [3:0] led_counter = 0;
    reg [9:0] bit_counter = 0;
    reg [4:0] rgb_counter = 0;

    localparam STATE_DATA  = 0;
    localparam STATE_RESET = 1;

    reg [1:0] state = STATE_RESET;

    // handle reading new led data
    always @(posedge clk)
        if(write)
            led_reg[led_num] <= rgb_data;

    integer i;

    always @(posedge clk)
        // reset
        if(reset) begin
            // initialise led data to 0
            //for (i=0; i<NUM_LEDS; i=i+1)
                //led_reg[i] <= 0;

            state <= STATE_RESET;
            bit_counter <= t_reset;
            rgb_counter <= 23;
            led_counter <= NUM_LEDS - 1;
            data <= 0;

        // state machine to generate the data output
        end else case(state)

            STATE_RESET: begin
                // register the input values
                rgb_counter <= 5'd23;
                led_counter <= NUM_LEDS - 1;
                data <= 0;

                bit_counter <= bit_counter - 1;

                if(bit_counter == 0) begin
                    state <= STATE_DATA;
                    bit_counter <= t_period;
                end
            end

            STATE_DATA: begin
                // output the data
                if(led_reg[led_counter][rgb_counter])
                    data <= bit_counter > (t_period - t_on);
                else
                    data <= bit_counter > (t_period - t_off);

                // count the period
                bit_counter <= bit_counter - 1;

                // after each bit, increment rgb counter
                if(bit_counter == 0) begin
                    bit_counter <= t_on + t_off;
                    rgb_counter <= rgb_counter - 1;

                    if(rgb_counter == 0) begin
                        led_counter <= led_counter - 1;
                        bit_counter <= t_period;
                        rgb_counter <= 23;

                        if(led_counter == 0) begin
                            state <= STATE_RESET;
                            led_counter <= NUM_LEDS - 1;
                            bit_counter <= t_reset;
                        end
                    end
                end 
            end

        endcase

    `ifdef FORMAL
        // start in reset
        initial restrict(reset);

        // past valid signal
        reg f_past_valid = 0;
        always @(posedge clk)
            f_past_valid <= 1'b1;

        // check everything is zeroed on the reset signal
        always @(posedge clk)
            if (f_past_valid)
                if ($past(reset)) begin
                    assert(bit_counter == t_reset);
                    assert(rgb_counter == 23);
                end

        always @(posedge clk) begin
            assert(bit_counter <= t_reset);
            assert(rgb_counter <= 23);
            assert(led_counter <= NUM_LEDS - 1);

            if(state == STATE_DATA) begin
                assert(bit_counter <= t_period);
                // led counter decrements
                if($past(state) == STATE_DATA && $past(rgb_counter) == 0 && $past(bit_counter) == 0)
                    assert(led_counter == $past(led_counter) - 1);
            end

            if(state == STATE_RESET) begin
                assert(data == 0);
                assert(bit_counter <= t_reset);
            end
        end

        // leds < NUM_LEDSs
        always @(posedge clk)
            assume(led_num < NUM_LEDS);

        // check that writes end up in the led register
        always @(posedge clk)
            if (f_past_valid)
                if(!$past(reset) && $past(write))
                    assert(led_reg[$past(led_num)] == $past(rgb_data));
            
    `endif
    
endmodule
