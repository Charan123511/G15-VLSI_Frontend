module can_tx_tb;

  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in time units
  parameter SIM_TIME = 500;   // Simulation time in time units
  
  // Signals
  reg clk = 0;              
  reg baud_clk = 0;          
  reg rst = 1;               
  reg send_data = 0;          
  reg bitstuffed_output = 0;   
  reg clear_to_tx = 1;       
  reg rx = 0;                
  reg [10:0] address = 11'd0; 
  reg [7:0] data = 8'd0;     
  wire tx;                    
  wire can_bitstuff;         
  wire txing;                 
  reg pulse;                 // Pulse signal for OneShot module
  wire out;                   // Output signal from OneShot module
  
  // Instantiate the modules
  can_tx dut (
    .tx(tx),
    .can_bitstuff(can_bitstuff),
    .txing(txing),
    .rx(rx),
    .address(address),
    .clk(clk),
    .baud_clk(baud_clk),
    .rst(rst),
    .data(data),
    .send_data(send_data),
    .bitstuffed_output(bitstuffed_output),
    .clear_to_tx(clear_to_tx)
  );

  OneShot os (
    .pulse(pulse),
    .clk(clk),
    .rst(rst),
    .out(out)
  );
  CRC cr(.data_in(data_in),.crc_en(crc_en),.crc_out(crc_out),.clk(clk),.reset(reset));
  

  // Clock generation
  always #((CLK_PERIOD/2)) clk = ~clk;
  always #5 baud_clk = ~baud_clk; 

  initial begin
    rst = 1;
    #20 rst = 0;
 
    #50 send_data = 1;
    #10 send_data = 0;
   
    #100 rx = 1;
    #10 rx = 0;
    #50 address = 11'd123;

    #70 data = 8'd255;
    
    #150 pulse = 1;
    #10 pulse = 0;
    
    #200 $finish;
  end
  
  

  // Display output
  always @(posedge clk) begin
    $display("Time = %0t: tx = %b, can_bitstuff = %b, txing = %b, out = %b", $time, tx, can_bitstuff, txing, out);
  end
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
endmodule
