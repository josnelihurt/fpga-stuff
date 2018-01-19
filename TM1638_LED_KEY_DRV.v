// TM1638_LED_KEY_DRV.v
// TM1638_LED_KEY_DRV()
//
// TM1638 LED KEY BOARD using driver
// test in aitendo board vvv this
// http://www.aitendo.com/product/12887
// maybe move on many boards used TM1638
//
//
// twitter:@manga_koji
// hatena: id:mangakoji http://mangakoji.hatenablog.com/
// GitHub :@mangakoji
//


module TM1638_LED_KEY_DRV #(
      parameter C_FCK  =  48_000_000  // Hz
    , parameter C_FSCLK =  1_000_000  // Hz
    , parameter C_FPS   =        250  // cycle(Hz)
)(
      input                 clk
    , input              n_rst
    , input   [ 6 :0]    DIRECT7SEG0_i
    , input   [ 6 :0]    DIRECT7SEG1_i
    , input   [ 6 :0]    DIRECT7SEG2_i
    , input   [ 6 :0]    DIRECT7SEG3_i
    , input   [ 6 :0]    DIRECT7SEG4_i
    , input   [ 6 :0]    DIRECT7SEG5_i
    , input   [ 6 :0]    DIRECT7SEG6_i
    , input   [ 6 :0]    DIRECT7SEG7_i
    , input   [ 7 :0]    dots_input
    , input   [ 7 :0]    leds_input
    , input   [31 :0]    BIN_DAT_i
    , input   [ 7 :0]    SUP_DIGITS_i
    , input              BIN2BCD_ON_i   
    , input              MISO_i
    , output                FRAME_REQ_o
    , output                EN_CK_o
    , output                tm1638_data
    , output                MOSI_OE_o
    , output                tm1638_clk
    , output                tm1638_strobe
    , output    [ 7:0]      KEYS_o
) ;
    function time log2;             //time is reg unsigned [63:0]
        input time value ;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end endfunction

wire ENCBIN_XDIRECT_i;
assign ENCBIN_XDIRECT_i = 1;

    //
    // ctl part
    //

    // clock divider
    //
    // if there is remainder ,round up
    localparam C_HALF_DIV_LEN = //24
        C_FCK / (C_FSCLK * 2) 
        + 
        ((C_FCK % (C_FSCLK * 2)) ? 1 : 0) 
    ;
    localparam C_HALF_DIV_W = log2( C_HALF_DIV_LEN ) ;
//    reg EN_HSCLK ;
    reg EN_SCLK ;
    reg EN_XSCLK ;
    reg EN_SCLK_D ;
    wire EN_CK ;
    reg [C_HALF_DIV_W-1 :0] H_DIV_CTR ;
    reg                     DIV_CTR ;
    wire    H_DIV_CTR_cy ;
    assign H_DIV_CTR_cy = &(H_DIV_CTR | ~(C_HALF_DIV_LEN-1)) ;
    always @(posedge clk or negedge n_rst) 
        if (~n_rst) begin
            H_DIV_CTR <= 'd0 ;
            DIV_CTR  <=  1'd0 ;
//            EN_HSCLK <=  1'b0 ;
            EN_SCLK  <=  1'b0 ;
            EN_XSCLK <=  1'b0 ;
            EN_SCLK_D <= 1'b0 ;
        end else begin
//            EN_HSCLK <= H_DIV_CTR_cy ;
            EN_SCLK  <= H_DIV_CTR_cy & ~ DIV_CTR ;
            EN_XSCLK <= H_DIV_CTR_cy &   DIV_CTR ;
            EN_SCLK_D <= EN_SCLK ;
            if (H_DIV_CTR_cy) begin
                H_DIV_CTR <= 'd0  ;
                DIV_CTR  <= ~ DIV_CTR ;
            end else begin
                H_DIV_CTR <= H_DIV_CTR + 'd1 ;
            end 
        end
    assign EN_CK = EN_XSCLK ;
    assign EN_CK_o = EN_CK ;

    // gen cyclic FRAME_request
    //
    // fps define
    // output_clk_reg CK count = C_HALF_DIV_LEN * 2
    // FCK / output_clk_reg / FPS = output_clk_reg clocks
    localparam C_FRAME_SCLK_N = C_FCK / (C_HALF_DIV_LEN * C_FPS) ; //8000
    localparam C_F_CTR_W = log2( C_FRAME_SCLK_N ) ;
    reg [C_F_CTR_W-1:0] F_CTR ;
    reg                 FRAME_REQ ;
    wire                F_CTR_cy ;
    assign F_CTR_cy = &(F_CTR | ~( C_FRAME_SCLK_N-1)) ;
    always @(posedge clk or negedge n_rst) 
        if (~ n_rst) begin
            F_CTR <= 'd0 ;
            FRAME_REQ <= 1'b0 ;
        end else if (EN_CK) begin
            FRAME_REQ <= F_CTR_cy ;
            if (F_CTR_cy)
                F_CTR<= 'd0 ;
            else
                F_CTR <= F_CTR + 1 ;
        end
    assign FRAME_REQ_o = FRAME_REQ ;
    reg     BIN2BCD_ON_D    ;
    always @(posedge clk or negedge n_rst) 
        if (~ n_rst)
            BIN2BCD_ON_D <= 1'b0 ;
        else if ( EN_CK )
            if (FRAME_REQ)
                BIN2BCD_ON_D <= BIN2BCD_ON_i ;
    wire    BCD_DONE        ;
    reg     BCD_DONE_D       ;
    always @(posedge clk or negedge n_rst) 
        if (~ n_rst)
            BCD_DONE_D <= 1'b0 ;

    // inter byte seqenser
    //
    localparam S_STARTUP    = 'hFF ;
    localparam S_IDLE       =   0 ;    
    localparam S_LOAD       =   1 ;
    localparam S_BIT0       = 'h20 ;
    localparam S_BIT1       = 'h21 ;
    localparam S_BIT2       = 'h22 ;
    localparam S_BIT3       = 'h23 ;
    localparam S_BIT4       = 'h24 ;
    localparam S_BIT5       = 'h25 ;
    localparam S_BIT6       = 'h26 ;
    localparam S_BIT7       = 'h27 ;
    localparam S_FINISH     = 'h3F ;

    localparam S_KEY3      = 'h23 ;
    reg [ 7 :0] FRAME_STATE ;

    reg [7:0]   BYTE_STATE ;
    always @(posedge clk or negedge n_rst) 
        if (~ n_rst)
            BYTE_STATE <= S_STARTUP ;
        else if (EN_CK)
            if ( FRAME_REQ |  BCD_DONE)
                BYTE_STATE <= S_LOAD ;
            else case (BYTE_STATE)
                S_STARTUP    :
                    BYTE_STATE <= S_IDLE ;
                S_IDLE       : 
                    case ( FRAME_STATE )
                          S_IDLE :
                            ; //pass 
                        default :
                            BYTE_STATE <= S_LOAD ;
                    endcase
                S_LOAD       :
                    BYTE_STATE <= S_BIT0 ;
                S_BIT0       :
                    BYTE_STATE <= S_BIT1 ;
                S_BIT1       :
                    BYTE_STATE <= S_BIT2 ;
                S_BIT2       :
                    BYTE_STATE <= S_BIT3 ;
                S_BIT3       : 
                    BYTE_STATE <= S_BIT4 ;
                S_BIT4       :
                    BYTE_STATE <= S_BIT5 ;
                S_BIT5       :
                    BYTE_STATE <= S_BIT6 ;
                S_BIT6       :
                    BYTE_STATE <= S_BIT7 ;
                S_BIT7       :
                    BYTE_STATE <= S_FINISH ; 
                S_FINISH       :
                    BYTE_STATE <= S_IDLE ; 
                default :
                    BYTE_STATE <= S_IDLE ;
            endcase


    // frame sequenser
    //
//    localparam S_STARTUP    = 'hFF ;
//    localparam S_IDLE       =   0 ;
//    localparam S_LOAD       =   1 ;
    localparam S_BCD        = 7 ;
    localparam S_SEND_SET   =   2 ;
    localparam S_LED_ADR_SET=   4 ;
    localparam S_LED0L     = 'h10 ;
    localparam S_LED0H     = 'h11 ;
    localparam S_LED1L     = 'h12 ;
    localparam S_LED1H     = 'h13 ;
    localparam S_LED2L     = 'h14 ;
    localparam S_LED2H     = 'h15 ;
    localparam S_LED3L     = 'h16 ;
    localparam S_LED3H     = 'h17 ;
    localparam S_LED4L     = 'h18 ;
    localparam S_LED4H     = 'h19 ;
    localparam S_LED5L     = 'h1A ;
    localparam S_LED5H     = 'h1B ;
    localparam S_LED6L     = 'h1C ;
    localparam S_LED6H     = 'h1D ;
    localparam S_LED7L     = 'h1E ;
    localparam S_LED7H     = 'h1F ;
    localparam S_LEDPWR_SET = 'h05 ;
    localparam S_KEY_ADR_SET = 'h06 ;
    localparam S_KEY0      = 'h20 ;
    localparam S_KEY1      = 'h21 ;
    localparam S_KEY2      = 'h22 ;
//    localparam S_KEY3      = 'h23 ;
//    reg [ 7 :0] FRAME_STATE ;
    always @(posedge clk or negedge n_rst) 
        if (~ n_rst)
            FRAME_STATE <= S_STARTUP ;
        else if (EN_CK)
            if (FRAME_REQ)
                FRAME_STATE <= S_BCD ;
            else case (FRAME_STATE)
                S_STARTUP    :
                    FRAME_STATE <= S_IDLE ;
                S_IDLE       :
                    if ( FRAME_REQ )
                        FRAME_STATE <= S_BCD ;
                S_BCD :
                    if ( BCD_DONE )
                        FRAME_STATE <= S_LOAD ;
                S_LOAD       : //7seg convert
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_SEND_SET ;
                    endcase
                S_SEND_SET   :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED_ADR_SET ;
                    endcase
                S_LED_ADR_SET:
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED0L ;
                    endcase
                S_LED0L     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED0H ;
                    endcase
                S_LED0H     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED1L ;
                    endcase
                S_LED1L     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED1H ;
                    endcase
                S_LED1H     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED2L ;
                    endcase
                S_LED2L     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED2H ;
                    endcase
                S_LED2H     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED3L ;
                    endcase
                S_LED3L     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED3H ;
                    endcase
                S_LED3H     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED4L ;
                    endcase
                S_LED4L     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED4H ;
                    endcase
                S_LED4H     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED5L ;
                    endcase
                S_LED5L     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED5H ;
                    endcase
                S_LED5H     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED6L ;
                    endcase
                S_LED6L     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED6H ;
                    endcase
                S_LED6H     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED7L ;
                    endcase
                S_LED7L     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LED7H ;
                    endcase
                S_LED7H     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_LEDPWR_SET ;
                    endcase
                S_LEDPWR_SET :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_KEY_ADR_SET ;
                    endcase
                S_KEY_ADR_SET :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_KEY0 ;
                    endcase
                S_KEY0      : 
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_KEY1 ;
                    endcase
                S_KEY1      :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_KEY2 ;
                    endcase
                S_KEY2      :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_KEY3 ;
                    endcase
                S_KEY3     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_IDLE ;
                    endcase
                S_FINISH     :
                    case ( BYTE_STATE )
                        S_FINISH :
                            FRAME_STATE <= S_IDLE ;
                    endcase
            endcase


    reg BUSY ;
    always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            BUSY <= 1'b0 ;
        else
            case (FRAME_STATE)
                S_IDLE :
                    ;//pas
                default :
                    case (BYTE_STATE )
                        S_IDLE :
                            BUSY <= 1'b0 ;
                        default :
                            BUSY <= 1'b1 ;
                    endcase
            endcase
    reg BYTE_BUSY ;
    always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            BYTE_BUSY <= 1'b0 ;
        else
            case ( BYTE_STATE )
                S_IDLE :
                    BYTE_BUSY <= 1'b0 ;
                default :
                    BYTE_BUSY <= 1'b1 ;
            endcase
    reg KEY_STATE ;
    always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            KEY_STATE <= 1'b0 ;
        else
            case ( FRAME_STATE )
                  S_KEY0
                , S_KEY1
                , S_KEY2
                , S_KEY3 :
                    KEY_STATE <= 1'b1 ;
                default :
                    KEY_STATE <= 1'b0 ;
            endcase
    

    reg MOSI_OE  ;
    always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            MOSI_OE <= 1'b0 ;
        else if( EN_CK) begin // EN_XSCLK
            case ( BYTE_STATE )
                S_BIT7 :
                    MOSI_OE <= 1'b0 ;
                S_LOAD : 
                    case ( FRAME_STATE )
                          S_SEND_SET
                        , S_LED_ADR_SET
                        , S_LED0L
                        , S_LED0H
                        , S_LED1L
                        , S_LED1H
                        , S_LED2L
                        , S_LED2H
                        , S_LED3L
                        , S_LED3H
                        , S_LED4L
                        , S_LED4H
                        , S_LED5L
                        , S_LED5H
                        , S_LED6L
                        , S_LED6H
                        , S_LED7L
                        , S_LED7H
                        , S_LEDPWR_SET
                        , S_KEY_ADR_SET :
                            MOSI_OE <= 1'b1 ;
                    endcase
            endcase
        end

    reg output_clk_reg ;
    always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            output_clk_reg <= 1'b1 ;
        else if( EN_SCLK )
            output_clk_reg <= 1'b1 ;
        else if (EN_XSCLK)
            case ( FRAME_STATE)
                  S_IDLE 
                , S_BCD
                , S_LOAD
                , S_FINISH :
                    output_clk_reg <= 1'b1 ;
                default :
                    case (BYTE_STATE)
                          S_LOAD
                        , S_BIT0
                        , S_BIT1
                        , S_BIT2
                        , S_BIT3
                        , S_BIT4
                        , S_BIT5
                        , S_BIT6 :
                            output_clk_reg <= 1'b0 ;
                    endcase
            endcase


    reg SS ;
    always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            SS <= 1'b1 ;
        else begin
            if( EN_SCLK )
                case (BYTE_STATE)
                    S_LOAD :
                        case ( FRAME_STATE )
                              S_SEND_SET
                            , S_LED_ADR_SET
                            , S_LEDPWR_SET
                            , S_KEY_ADR_SET :
                                SS <= 1'b0 ;
                        endcase
                    endcase
            else if ( EN_XSCLK ) begin
                if ( FRAME_REQ )
                    SS <= 1'b1 ;
                case (BYTE_STATE)
                    S_FINISH :
                        case ( FRAME_STATE )
                              S_SEND_SET
                            , S_LED7H
                            , S_LEDPWR_SET
                            , S_KEY3 :
                                SS <= 1'b1 ;
                        endcase
                endcase
            end
        end
    assign tm1638_clk    = output_clk_reg  ;
    assign MOSI_OE_o = MOSI_OE ;
    assign tm1638_strobe      = SS ;



    // main data part
    //
    //
    wire    [31:0]  BCDS    ;
    BIN2BCD #(
          .C_MILLIONAIRE( 0 )   //1:Millionaire code  0:normal shift regs
        , .C_WO_LATCH   ( 1 )   //0:BCD latch, increse 32FF, 1:less FF but
    ) BIN2BCD (
          .CK_i     ( clk              )
        , .XARST_i  ( n_rst           )
        , .EN_CK_i  ( EN_CK             )
        , .DAT_i    ( BIN_DAT_i [26 :0] )
        , .REQ_i    ( FRAME_REQ         )
        , .QQ_o     ( BCDS              )
        , .DONE_o   ( BCD_DONE          )
    ) ;
    
//    wire    [31:0]  BCDS ;
    reg     [34:0]  DAT_BUFF ;   //5bit downsized, but too complex
    always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            DAT_BUFF <= 35'd0 ;
        else if (EN_CK) begin
            if (FRAME_REQ )
                DAT_BUFF <= {
                      SUP_DIGITS_i  [7]
                    , BIN_DAT_i     [7*4 +:4]
                    , SUP_DIGITS_i  [6]
                    , BIN_DAT_i     [6*4 +:4]
                    , SUP_DIGITS_i  [5]
                    , BIN_DAT_i     [5*4 +:4]
                    , SUP_DIGITS_i  [4]
                    , BIN_DAT_i     [4*4 +:4]
                    , SUP_DIGITS_i  [3]
                    , BIN_DAT_i     [3*4 +:4]
                    , SUP_DIGITS_i  [2]
                    , BIN_DAT_i     [2*4 +:4]
                    , SUP_DIGITS_i  [1]
                    , BIN_DAT_i     [1*4 +:4]
                } ;
            else if( BCD_DONE )
                if ( BIN2BCD_ON_D ) begin
                    DAT_BUFF[6*5 +:4] <= BCDS[7*4 +:4] ;
                    DAT_BUFF[5*5 +:4] <= BCDS[6*4 +:4] ;
                    DAT_BUFF[4*5 +:4] <= BCDS[5*4 +:4] ;
                    DAT_BUFF[3*5 +:4] <= BCDS[4*4 +:4] ;
                    DAT_BUFF[2*5 +:4] <= BCDS[3*4 +:4] ;
                    DAT_BUFF[1*5 +:4] <= BCDS[2*4 +:4] ;
                    DAT_BUFF[0*5 +:4] <= BCDS[1*4 +:4] ;
                end
            case (FRAME_STATE)
                S_LOAD :
                    DAT_BUFF <= {
                          5'b0
                        , DAT_BUFF[34:5]
                    } ;
            endcase
        end

    reg             SUP_DIGIT_0 ;
    reg             BIN_DAT_0   ;
    always @(posedge clk or negedge n_rst)
        if (~ n_rst) begin
            SUP_DIGIT_0 <= 1'b0 ;
            BIN_DAT_0 <= 4'b0 ;
        end else if (FRAME_REQ) begin
            SUP_DIGIT_0 <= SUP_DIGITS_i[0] ;
            BIN_DAT_0 <= BIN_DAT_i[3:0] ;
        end

    wire [ 3 :0] octet_seled ;
    wire        sup_now ;
    assign {sup_now, octet_seled } = 
        ( BCD_DONE ) ? 
                (BIN2BCD_ON_D) ? 
                    {SUP_DIGIT_0 , BCDS[3:0] }
                :
                    {SUP_DIGIT_0 , BIN_DAT_0} 
            : 
                DAT_BUFF[ 4 :0] 
    ;

    // endcoder for  LED7-segment
    //   a 
    // f     b
    //    g
    // e     c
    //    d 
    wire    [ 6 :0] enced_7seg ;
    function [6:0] f_seg_enc ;
        input sup_now ;
        input [3:0] octet;
    begin
        if (sup_now)
            f_seg_enc = 7'b000_0000 ;
        else
          case( octet )
                              //  gfedcba
            4'h0 : f_seg_enc = 7'b0111111 ; //0
            4'h1 : f_seg_enc = 7'b0000110 ; //1
            4'h2 : f_seg_enc = 7'b1011011 ; //2
            4'h3 : f_seg_enc = 7'b1001111 ; //3
            4'h4 : f_seg_enc = 7'b1100110 ; //4
            4'h5 : f_seg_enc = 7'b1101101 ; //5
            4'h6 : f_seg_enc = 7'b1111101 ; //6
            4'h7 : f_seg_enc = 7'b0100111 ; //7
            4'h8 : f_seg_enc = 7'b1111111 ; //8
            4'h9 : f_seg_enc = 7'b1101111 ; //9
            4'hA : f_seg_enc = 7'b1110111 ; //a
            4'hB : f_seg_enc = 7'b1111100 ; //b
            4'hC : f_seg_enc = 7'b0111001 ; //c
            4'hD : f_seg_enc = 7'b1011110 ; //d
            4'hE : f_seg_enc = 7'b1111001 ; //e
            4'hF : f_seg_enc = 7'b1110001 ; //f
            default : f_seg_enc = 7'b1000000 ; //-
          endcase
    end endfunction
    assign enced_7seg = f_seg_enc(sup_now , octet_seled ) ;


//    wire    ENCBIN_XDIRECT_y ;
    reg     ENCBIN_XDIRECT_D ;
   always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            ENCBIN_XDIRECT_D <= 1'b0 ;
        else if( FRAME_REQ )
            ENCBIN_XDIRECT_D <= 1'b1 ;
//    assign ENCBIN_XDIRECT_y = (FRAME_REQ)? ENCBIN_XDIRECT_i : ENCBIN_XDIRECT

    reg             ENC_SHIFT ;
    always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            ENC_SHIFT <= 1'b0 ;
        else if ( EN_CK )
            if ( BCD_DONE )
                ENC_SHIFT <= 1'b1 ;
            else
                case (BYTE_STATE)
                    S_BIT5 :
                        ENC_SHIFT <= 1'b0 ;
                endcase


    reg     [71 :0] main_buffer_reg ; //7bit downsize but too complex.
    always @(posedge clk or negedge n_rst)
        if (~ n_rst)
            main_buffer_reg <= 72'd0 ;
        else if ( EN_CK )
            if ( FRAME_REQ ) 
            begin
                 main_buffer_reg[71:7] <= {
											leds_input[0] , dots_input[0] , DIRECT7SEG0_i,
											leds_input[1], dots_input[1], DIRECT7SEG1_i, 
											leds_input[2], dots_input[2], DIRECT7SEG2_i,
											leds_input[3], dots_input[3], DIRECT7SEG3_i,
											leds_input[4], dots_input[4], DIRECT7SEG4_i, 
											leds_input[5], dots_input[5], DIRECT7SEG5_i, 
											leds_input[6], dots_input[6], DIRECT7SEG6_i, 
											leds_input[7], dots_input[7]
										} ;
                 main_buffer_reg[6:0] <= enced_7seg ;
            end else if ( BCD_DONE )
            begin
                if( BIN2BCD_ON_D )
                    main_buffer_reg[6:0] <= enced_7seg ;
            end else if (BCD_DONE_D | ENC_SHIFT)
                 case (FRAME_STATE)
                     S_LOAD :
                        if (ENCBIN_XDIRECT_D) 
                            main_buffer_reg <=  {
                                  main_buffer_reg[7*9+7  +:2]
                                , main_buffer_reg[6*9    +:7]
                                , main_buffer_reg[6*9+7  +:2]
                                , main_buffer_reg[5*9    +:7]
                                , main_buffer_reg[5*9+7  +:2]
                                , main_buffer_reg[4*9    +:7]
                                , main_buffer_reg[4*9+7  +:2]
                                , main_buffer_reg[3*9    +:7]
                                , main_buffer_reg[3*9+7  +:2]
                                , main_buffer_reg[2*9    +:7]
                                , main_buffer_reg[2*9+7  +:2]
                                , main_buffer_reg[1*9    +:7]
                                , main_buffer_reg[1*9+7  +:2]
                                , main_buffer_reg[0*9    +:7]
                                , main_buffer_reg[0*9+7  +:2]
                                , enced_7seg 
                            } ;
                endcase
            else 
                case (FRAME_STATE)
                       S_LED0L
                     , S_LED1L
                     , S_LED2L
                     , S_LED3L
                     , S_LED4L
                     , S_LED5L
                     , S_LED6L
                     , S_LED7L :
                        case ( BYTE_STATE )
                               S_BIT0
                             , S_BIT1
                             , S_BIT2
                             , S_BIT3
                             , S_BIT4
                             , S_BIT5
                             , S_BIT6
                             , S_BIT7 :
                                 main_buffer_reg <= {
                                      main_buffer_reg[0]
                                     , main_buffer_reg[71:1]
                                 } ;
                         endcase
                       S_LED0H
                     , S_LED1H
                     , S_LED2H
                     , S_LED3H
                     , S_LED4H
                     , S_LED5H
                     , S_LED6H
                     , S_LED7H :
                         case ( BYTE_STATE )
                               S_BIT0 :
                                 main_buffer_reg <= {
                                       main_buffer_reg[0]
                                     , main_buffer_reg[71:1]
                                 } ;
                         endcase
                endcase


    // output BYTE buffer 
    //
    reg [ 7 :0] BYTE_BUFF ;
    always @(posedge clk or negedge n_rst) 
        if ( ~ n_rst )
            BYTE_BUFF <= 8'h0 ;
        else if ( EN_CK )
            case ( BYTE_STATE )
                S_LOAD :
                    case ( FRAME_STATE )
                        S_SEND_SET :
                            BYTE_BUFF <= 8'h40 ;
                        S_LED_ADR_SET :
                            BYTE_BUFF <= 8'hC0 ;
                        S_LEDPWR_SET :
                            BYTE_BUFF <= 8'h8F ;
                        S_KEY_ADR_SET :
                            BYTE_BUFF <= 8'h42 ;
                          S_LED0L
                        , S_LED1L
                        , S_LED2L
                        , S_LED3L
                        , S_LED4L
                        , S_LED5L
                        , S_LED6L
                        , S_LED7L :
                            BYTE_BUFF <= main_buffer_reg[7:0] ;
                          S_LED0H
                        , S_LED1H
                        , S_LED2H
                        , S_LED3H
                        , S_LED4H
                        , S_LED5H
                        , S_LED6H
                        , S_LED7H :
                            BYTE_BUFF <= {7'b0000_000 , main_buffer_reg[0]} ;
                    endcase
                  S_BIT0
                , S_BIT1
                , S_BIT2
                , S_BIT3
                , S_BIT4
                , S_BIT5
                , S_BIT6
                , S_BIT7 :
                    BYTE_BUFF <= {1'b0 , BYTE_BUFF[7:1]} ;
        endcase

    assign tm1638_data = BYTE_BUFF[0] ;


    reg [ 7 :0] KEYS ;
    always @(posedge clk or negedge n_rst) 
        if ( ~ n_rst )
            KEYS <= 8'd0 ;
        else if ( EN_SCLK_D )
            case (FRAME_STATE)
                S_KEY0 : 
                    case (BYTE_STATE)
                        S_BIT0 :
                            KEYS[7] <= MISO_i ;
                        S_BIT4 :
                            KEYS[6] <= MISO_i ;
                    endcase
                S_KEY1 : 
                    case (BYTE_STATE)
                        S_BIT0 :
                            KEYS[5] <= MISO_i ;
                        S_BIT4 :
                            KEYS[4] <= MISO_i ;
                    endcase
                S_KEY2 : 
                    case (BYTE_STATE)
                        S_BIT0 :
                            KEYS[3] <= MISO_i ;
                        S_BIT4 :
                            KEYS[2] <= MISO_i ;
                    endcase
                S_KEY3 : 
                    case (BYTE_STATE)
                        S_BIT0 :
                            KEYS[1] <= MISO_i ;
                        S_BIT4 :
                            KEYS[0] <= MISO_i ;
                    endcase
            endcase
    assign KEYS_o = KEYS ;

endmodule //TM1638_LED_KEY_DRV()


