module I2S (
	input I2S_LRCLK, // LEFT-RIGHT STEREO CLOCK
	input I2S_SCLK,  // AUDIO SIGNAL CLOCK
	input I2S_DOUT,  // INPUT FROM ADC
	input [9:0] SW,  // INPUT FROM SWITCH
	output I2S_DIN   // OUTPUT TO DAC
);

	
//	always_ff @(posedge I2S_SCLK) begin
//		I2S_DIN <= I2S_DOUT;
//	end
//	assign I2S_DIN = I2S_DOUT;
	logic [10:0] read_address;
	logic [15:0] data_out, temp_data;
	logic temp_din, temp_msb;
	
	assign I2S_DIN = temp_din;
	
	rom rom_inst(.address(read_address), .clock(I2S_SCLK), .q(data_out));
	
	always_ff @(negedge I2S_LRCLK) begin
		if (data_out == 16'hFFFF)
			read_address <= SW[2:0] << 8;
		else
			read_address <= read_address + 1;
	end
	
	always_ff @(posedge I2S_SCLK) begin
		temp_din <= data_out[15];
		temp_data <= data_out << 1;
	end
	
	
endmodule
