module wishbone_master #(
    parameter int WB_ADDR_W      = 32,
    parameter int WB_DATA_W      = 32,
    parameter int TIMEOUT_CYCLES = 64,
    parameter int MAX_RETRY      = 4
)(
    input  logic                     clk_i,
    input  logic                     rst_n,

    //------------------------------------------------
    // Control Interface
    //------------------------------------------------
    input  logic                     start_req_i,
    input  logic [31:0]              reg_ctrl_i,
    input  logic [WB_ADDR_W-1:0]     reg_addr_i,
    input  logic [WB_DATA_W-1:0]     wr_data_i,

    output logic [WB_DATA_W-1:0]     rd_data_o,

    output logic                     busy_o,
    output logic                     done_o,
    output logic                     error_o,

    //------------------------------------------------
    // Wishbone Interface
    //------------------------------------------------
    input  logic [WB_DATA_W-1:0]     dat_i,

    output logic [WB_ADDR_W-1:0]     adr_o,
    output logic [WB_DATA_W-1:0]     dat_o,
    output logic [(WB_DATA_W/8)-1:0] sel_o,
    output logic                     we_o,
    output logic                     stb_o,
    output logic                     cyc_o,

    input  logic                     ack_i,
    input  logic                     err_i,
    input  logic                     rty_i,

    output logic [2:0]               cti_o,
    output logic [1:0]               bte_o,

    //------------------------------------------------
    // Statistics
    //------------------------------------------------
    output logic [31:0]              read_count_o,
    output logic [31:0]              write_count_o,
    output logic [31:0]              error_count_o,
    output logic [31:0]              retry_count_o
);

    //------------------------------------------------
    // Wishbone Constants
    //------------------------------------------------
    localparam logic [2:0] CTI_CLASSIC      = 3'b000;
    localparam logic [2:0] CTI_CONST_ADDR   = 3'b001;
    localparam logic [2:0] CTI_INCR_ADDR    = 3'b010;
    localparam logic [2:0] CTI_END_OF_BURST = 3'b111;

    localparam logic [1:0] BTE_LINEAR = 2'b00;
    localparam logic [1:0] BTE_WRAP4  = 2'b01;
    localparam logic [1:0] BTE_WRAP8  = 2'b10;
    localparam logic [1:0] BTE_WRAP16 = 2'b11;

    localparam int BYTE_OFFSET = WB_DATA_W / 8;

    //------------------------------------------------
    // FSM
    //------------------------------------------------
    typedef enum logic [2:0] {
        IDLE,
        ALIGN_CHECK,
        SEND_REQ,
        WAIT_ACK,
        COMPLETE,
        ERROR_STATE,
        RETRY_STATE
    } state_t;

    state_t curr_state, next_state;

    //------------------------------------------------
    // Decoded Register Fields
    //------------------------------------------------
    logic [2:0] cti;
    logic [1:0] bte;
    logic       req_type;
    logic [9:0] req_num;
    logic [7:0] burst_len;

    assign cti       = reg_ctrl_i[2:0];
    assign bte       = reg_ctrl_i[4:3];
    assign req_type  = reg_ctrl_i[5];
    assign req_num   = reg_ctrl_i[15:6];
    assign burst_len = reg_ctrl_i[23:16];

    //------------------------------------------------
    // Internal Registers
    //------------------------------------------------
    logic [WB_ADDR_W-1:0] current_addr;
    logic [WB_ADDR_W-1:0] base_addr;

    logic [9:0] request_count;
    logic [7:0] timeout_counter;
    logic [3:0] retry_counter;

    logic alignment_error;
    logic pending;

    logic [31:0] read_count;
    logic [31:0] write_count;
    logic [31:0] error_count;
    logic [31:0] retry_count;

    //------------------------------------------------
    // Alignment Check
    //------------------------------------------------
    assign alignment_error =
        (reg_addr_i % BYTE_OFFSET != 0);

    //------------------------------------------------
    // Pending Request Check
    //------------------------------------------------
    assign pending =
        (request_count < req_num);

    //------------------------------------------------
    // State Register
    //------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    //------------------------------------------------
    // Next State Logic
    //------------------------------------------------
    always_comb begin

        next_state = curr_state;

        case (curr_state)

            IDLE: begin
                if (start_req_i)
                    next_state = ALIGN_CHECK;
            end

            ALIGN_CHECK: begin
                if (alignment_error)
                    next_state = ERROR_STATE;
                else
                    next_state = SEND_REQ;
            end

            SEND_REQ: begin
                next_state = WAIT_ACK;
            end

            WAIT_ACK: begin
                if (ack_i)
                    next_state = COMPLETE;

                else if (err_i)
                    next_state = ERROR_STATE;

                else if (rty_i)
                    next_state = RETRY_STATE;

                else if (timeout_counter >= TIMEOUT_CYCLES)
                    next_state = ERROR_STATE;
            end

            COMPLETE: begin
                if (pending)
                    next_state = SEND_REQ;
                else
                    next_state = IDLE;
            end

            RETRY_STATE: begin
                if (retry_counter >= MAX_RETRY)
                    next_state = ERROR_STATE;
                else
                    next_state = SEND_REQ;
            end

            ERROR_STATE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    //------------------------------------------------
    // Sequential Logic
    //------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_n) begin

        if (!rst_n) begin

            current_addr    <= '0;
            base_addr       <= '0;
            request_count   <= '0;
            timeout_counter <= '0;
            retry_counter   <= '0;

            rd_data_o       <= '0;

            read_count      <= '0;
            write_count     <= '0;
            error_count     <= '0;
            retry_count     <= '0;

        end
        else begin

            case (curr_state)

                IDLE: begin

                    timeout_counter <= 0;
                    retry_counter   <= 0;

                    if (start_req_i) begin
                        base_addr     <= reg_addr_i;
                        current_addr  <= reg_addr_i;
                        request_count <= 0;
                    end
                end

                WAIT_ACK: begin

                    timeout_counter <= timeout_counter + 1;

                    //------------------------------------------------
                    // ACK Received
                    //------------------------------------------------
                    if (ack_i) begin

                        timeout_counter <= 0;

                        if (!req_type)
                            rd_data_o <= dat_i;

                        request_count <= request_count + 1;

                        //------------------------------------------------
                        // Statistics
                        //------------------------------------------------
                        if (req_type)
                            write_count <= write_count + 1;
                        else
                            read_count <= read_count + 1;

                        //------------------------------------------------
                        // Address Update
                        //------------------------------------------------
                        case (cti)

                            CTI_CLASSIC: begin
                                current_addr <=
                                    current_addr + BYTE_OFFSET;
                            end

                            CTI_CONST_ADDR: begin
                                current_addr <= current_addr;
                            end

                            CTI_INCR_ADDR: begin

                                case (bte)

                                    BTE_LINEAR: begin
                                        current_addr <=
                                            current_addr + BYTE_OFFSET;
                                    end

                                    BTE_WRAP4: begin
                                        current_addr <=
                                            base_addr +
                                            (((request_count + 1) % 4) *
                                            BYTE_OFFSET);
                                    end

                                    BTE_WRAP8: begin
                                        current_addr <=
                                            base_addr +
                                            (((request_count + 1) % 8) *
                                            BYTE_OFFSET);
                                    end

                                    BTE_WRAP16: begin
                                        current_addr <=
                                            base_addr +
                                            (((request_count + 1) % 16) *
                                            BYTE_OFFSET);
                                    end

                                    default: begin
                                        current_addr <=
                                            current_addr + BYTE_OFFSET;
                                    end

                                endcase
                            end

                            default: begin
                                current_addr <=
                                    current_addr + BYTE_OFFSET;
                            end

                        endcase
                    end

                    //------------------------------------------------
                    // Retry Handling
                    //------------------------------------------------
                    else if (rty_i) begin

                        retry_counter <=
                            retry_counter + 1;

                        retry_count <=
                            retry_count + 1;
                    end

                    //------------------------------------------------
                    // Error Handling
                    //------------------------------------------------
                    else if (err_i ||
                             timeout_counter >= TIMEOUT_CYCLES) begin

                        error_count <=
                            error_count + 1;
                    end
                end

                default: begin
                    timeout_counter <= 0;
                end

            endcase
        end
    end

    //------------------------------------------------
    // Wishbone Outputs
    //------------------------------------------------
    always_comb begin

        adr_o = '0;
        dat_o = '0;
        sel_o = '0;
        we_o  = 1'b0;
        stb_o = 1'b0;
        cyc_o = 1'b0;

        cti_o = cti;
        bte_o = bte;

        case (curr_state)

            SEND_REQ,
            WAIT_ACK: begin

                adr_o = current_addr;
                dat_o = wr_data_i;
                sel_o = {(WB_DATA_W/8){1'b1}};

                we_o  = req_type;
                stb_o = 1'b1;
                cyc_o = 1'b1;

                //------------------------------------------------
                // End of Burst CTI
                //------------------------------------------------
                if ((request_count == req_num - 1) && ack_i)
                    cti_o = CTI_END_OF_BURST;
            end

            default: begin
                adr_o = '0;
            end

        endcase
    end

    //------------------------------------------------
    // Status Outputs
    //------------------------------------------------
    assign busy_o =
        (curr_state != IDLE);

    assign done_o =
        (curr_state == COMPLETE) &&
        !pending;

    assign error_o =
        (curr_state == ERROR_STATE);

    //------------------------------------------------
    // Statistics Outputs
    //------------------------------------------------
    assign read_count_o  = read_count;
    assign write_count_o = write_count;
    assign error_count_o = error_count;
    assign retry_count_o = retry_count;

endmodule
module wishbone_slave #(
    parameter int WB_ADDR_W = 32,
    parameter int WB_DATA_W = 32,
    parameter int MEM_DEPTH = 256
)(
    //------------------------------------------------
    // Global Signals
    //------------------------------------------------
    input  logic                     CLK_I,
    input  logic                     RST_N,

    //------------------------------------------------
    // Wishbone Signals
    //------------------------------------------------
    input  logic [WB_ADDR_W-1:0]     ADR_I,
    input  logic [WB_DATA_W-1:0]     DAT_I,
    output logic [WB_DATA_W-1:0]     DAT_O,

    input  logic [(WB_DATA_W/8)-1:0] SEL_I,

    input  logic                     WE_I,
    input  logic                     STB_I,
    input  logic                     CYC_I,

    output logic                     ACK_O,
    output logic                     ERR_O,
    output logic                     RTY_O,

    input  logic [2:0]               CTI_I,
    input  logic [1:0]               BTE_I
);

    //------------------------------------------------
    // Wishbone Constants
    //------------------------------------------------
    localparam logic [2:0] CTI_CLASSIC      = 3'b000;
    localparam logic [2:0] CTI_CONST_ADDR   = 3'b001;
    localparam logic [2:0] CTI_INCR_ADDR    = 3'b010;
    localparam logic [2:0] CTI_END_OF_BURST = 3'b111;

    localparam int BYTE_WIDTH = WB_DATA_W / 8;
    localparam int ADDR_LSB   = $clog2(BYTE_WIDTH);

    //------------------------------------------------
    // Simple Internal Memory
    //------------------------------------------------
    logic [WB_DATA_W-1:0] mem [0:MEM_DEPTH-1];

    //------------------------------------------------
    // Internal Registers
    //------------------------------------------------
    logic [WB_DATA_W-1:0] rd_data_reg;
    logic                  ack_reg;

    logic [$clog2(MEM_DEPTH)-1:0] word_addr;

    //------------------------------------------------
    // Word Address Extraction
    //------------------------------------------------
    assign word_addr =
        ADR_I[ADDR_LSB + $clog2(MEM_DEPTH)-1 : ADDR_LSB];

    //------------------------------------------------
    // Error / Retry
    //------------------------------------------------
    assign ERR_O = 1'b0;
    assign RTY_O = 1'b0;

    //------------------------------------------------
    // ACK Generation
    //------------------------------------------------
    always_ff @(posedge CLK_I or negedge RST_N) begin

        if (!RST_N)
            ack_reg <= 1'b0;

        else
            ack_reg <= (CYC_I && STB_I && !ack_reg);
    end

    assign ACK_O = ack_reg;

    //------------------------------------------------
    // Read / Write Logic
    //------------------------------------------------
    integer i;

    always_ff @(posedge CLK_I or negedge RST_N) begin

        if (!RST_N) begin

            rd_data_reg <= '0;

            //------------------------------------------------
            // Optional Memory Initialization
            //------------------------------------------------
            for (i = 0; i < MEM_DEPTH; i = i + 1)
                mem[i] <= '0;
        end

        else begin

            //------------------------------------------------
            // Valid Wishbone Transaction
            //------------------------------------------------
            if (CYC_I && STB_I && !ack_reg) begin

                //------------------------------------------------
                // WRITE Operation
                //------------------------------------------------
                if (WE_I) begin

                    for (i = 0; i < BYTE_WIDTH; i = i + 1) begin

                        if (SEL_I[i]) begin
                            mem[word_addr][8*i +: 8] <=
                                DAT_I[8*i +: 8];
                        end
                    end
                end

                //------------------------------------------------
                // READ Operation
                //------------------------------------------------
                else begin
                    rd_data_reg <= mem[word_addr];
                end
            end
        end
    end

    //------------------------------------------------
    // Read Data Output
    //------------------------------------------------
    assign DAT_O = rd_data_reg;

endmodule
