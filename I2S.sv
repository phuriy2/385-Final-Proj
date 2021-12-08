module I2S (
	input I2S_LRCLK, // LEFT-RIGHT STEREO CLOCK
	input I2S_SCLK,  // AUDIO SIGNAL CLOCK
	input I2S_DOUT,  // INPUT FROM ADC
	input [31:0] keycode, // INPUT FROM KEYBOARD
	output I2S_DIN   // OUTPUT TO DAC
);

	
//	always_ff @(posedge I2S_SCLK) begin
//		I2S_DIN <= I2S_DOUT;
//	end
//	assign I2S_DIN = I2S_DOUT;
	logic [10:0] read_address0, read_address1, read_address2, read_address3;
	logic [15:0] data_out0, data_out1, data_out2, data_out3, avg_data, temp_data;
	logic [17:0] sum_data;
	logic temp_din;
	logic [7:0] keycode_0, keycode_1, keycode_2, keycode_3;
	
	assign keycode_0 = keycode[31:24];
	assign keycode_1 = keycode[23:16];
	assign keycode_2 = keycode[15:8];
	assign keycode_3 = keycode[7:0];
	
	// use two 2-port RAMs to access notes on the fourth octave
	piano_ram piano_ram0(.clock(I2S_SCLK),
				 .address_a(read_address0), .address_b(read_address1), 
				 .data_a(16'bz), .data_b(16'bz), // no writes allowed
				 .wren_a(1'b0), .wren_b(1'b0),   // no writes allowed
				 .q_a(data_out0), .q_b(data_out1));
	
	piano_ram piano_ram1(.clock(I2S_SCLK),
				 .address_a(read_address2), .address_b(read_address3), 
				 .data_a(16'bz), .data_b(16'bz), // no writes allowed
				 .wren_a(1'b0), .wren_b(1'b0),   // no writes allowed
				 .q_a(data_out2), .q_b(data_out3));
		
	// deal with multiple keycodes by averaging the note value
	assign sum_data = data_out0 + data_out1 + data_out2 + data_out3;
	assign avg_data = sum_data[17:2];
	
	always_ff @(negedge I2S_LRCLK) begin
		if (data_out0 == 16'hFFFF) begin
				case (keycode_0)
					8'h04 : read_address0 <= 16'h0000; // A
					8'h16 : read_address0 <= 16'h0100; // S
					8'h07 : read_address0 <= 16'h0200; // D
					8'h09 : read_address0 <= 16'h0300; // F
					8'h0B : read_address0 <= 16'h0400; // H
					8'h0D : read_address0 <= 16'h0500; // J
					8'h0E : read_address0 <= 16'h0600; // K
					8'h0F : read_address0 <= 16'h0700; // L
					default : ;
				endcase
			end
		else
			read_address0 <= read_address0 + 1;
		
		if (data_out1 == 16'hFFFF) begin
				case (keycode_1)
					8'h04 : read_address1 <= 16'h0000; // A
					8'h16 : read_address1 <= 16'h0100; // S
					8'h07 : read_address1 <= 16'h0200; // D
					8'h09 : read_address1 <= 16'h0300; // F
					8'h0B : read_address1 <= 16'h0400; // H
					8'h0D : read_address1 <= 16'h0500; // J
					8'h0E : read_address1 <= 16'h0600; // K
					8'h0F : read_address1 <= 16'h0700; // L
					default : ;
				endcase
			end
		else
			read_address1 <= read_address1 + 1;
			
		if (data_out2 == 16'hFFFF) begin
				case (keycode_2)
					8'h04 : read_address2 <= 16'h0000; // A
					8'h16 : read_address2 <= 16'h0100; // S
					8'h07 : read_address2 <= 16'h0200; // D
					8'h09 : read_address2 <= 16'h0300; // F
					8'h0B : read_address2 <= 16'h0400; // H
					8'h0D : read_address2 <= 16'h0500; // J
					8'h0E : read_address2 <= 16'h0600; // K
					8'h0F : read_address2 <= 16'h0700; // L
					default : ;
				endcase
			end
		else
			read_address2 <= read_address2 + 1;
			
		if (data_out3 == 16'hFFFF) begin
				case (keycode_3)
					8'h04 : read_address3 <= 16'h0000; // A
					8'h16 : read_address3 <= 16'h0100; // S
					8'h07 : read_address3 <= 16'h0200; // D
					8'h09 : read_address3 <= 16'h0300; // F
					8'h0B : read_address3 <= 16'h0400; // H
					8'h0D : read_address3 <= 16'h0500; // J
					8'h0E : read_address3 <= 16'h0600; // K
					8'h0F : read_address3 <= 16'h0700; // L
					default : ;
				endcase
			end
		else
			read_address3 <= read_address3 + 1;
	end
	
	always_ff @(posedge I2S_SCLK) begin
		temp_din <= temp_data[15];
		temp_data <= avg_data << 1;
	end
	
	assign I2S_DIN = temp_din;
	
endmodule
