module finalproj (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);

//	logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
//	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
//	logic [1:0] signs;
//	logic [1:0] hundreds;
//	logic [7:0] Red, Blue, Green;
	logic [31:0] keycode;
	logic [1:0] AUD_MCLK_CTR; // counter for CODEC mclk
	logic I2C_SCL, I2C_SDA, I2C_SCL_OE, I2C_SDA_OE; // I2C signals
	logic I2S_SCLK, I2S_LRCLK, I2S_DOUT, I2S_DIN; // I2S signals
	// ADC Logic
	logic [4:0] cmd_ch; 		// Input: ADC Command channels, determine output
	logic [4:0] res_ch;
	logic [11:0] res_data; // Output: ADC outputs
	logic res_valid;
	logic [11:0] adc_data;
	logic [4:0] adc_ch;
	logic [12:0] vol; //Debug

//=======================================================
//  Structural coding
//=======================================================
	// creating a 12.5 MHz Clk for SGTL5000
	assign ARDUINO_IO[3] = AUD_MCLK_CTR[1];
	always_ff @(posedge MAX10_CLK1_50) begin
		if (AUD_MCLK_CTR == 2'b11)
			AUD_MCLK_CTR <= 2'b00;
		else
			AUD_MCLK_CTR <= AUD_MCLK_CTR + 1;
	end
	
	// used for I2S module
	assign ARDUINO_IO[5] = 1'bZ;
	assign I2S_SCLK = ARDUINO_IO[5];
	assign ARDUINO_IO[4] = 1'bZ;
	assign I2S_LRCLK = ARDUINO_IO[4];
	assign ARDUINO_IO[1] = 1'bZ;
	assign I2S_DOUT = ARDUINO_IO[1];
	assign ARDUINO_IO[2] = I2S_DIN;
	
	// instantiate I2S module as audio processor
	I2S audio (.*);
	
	// used for I2C interface i.e. SGTL5000
	assign I2C_SCL = ARDUINO_IO[15];
	assign I2C_SDA = ARDUINO_IO[14];
	assign ARDUINO_IO[15] = I2C_SCL_OE ? 1'b0 : 1'bz;
	assign ARDUINO_IO[14] = I2C_SDA_OE ? 1'b0 : 1'bz;
	
	// used for SPI interface i.e. keyboards
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	//	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	//	assign HEX4[7] = 1'b1;
	//	
	//	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	//	assign HEX3[7] = 1'b1;
	//	
	//	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	//	assign HEX1[7] = 1'b1;
	//	
	//	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	//	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	//	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	//	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	//	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	//	assign VGA_R = Red[7:4];
	//	assign VGA_B = Blue[7:4];
	//	assign VGA_G = Green[7:4];

	// ADC Debug
// 	always @ (posedge MAX10_CLK1_50)
// 	begin
// 		if (res_valid)
// 		begin
// 			adc_data <= res_data;
// 			adc_ch <= res_ch;
			
// 			//vol <= res_data * 2 * 2500 / 4095;
// 		end
// 	end	
	//assign LEDR[9:0] = vol[12:3];
	assign cmd_ch = 4'b0001;
	
	//Debug HEX
	
	
	final_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
//		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//ADC
		.modular_adc_0_command_valid(1'b1),          		// modular_adc_0_command.valid
		.modular_adc_0_command_channel(cmd_ch),        		// .channel
		.modular_adc_0_command_startofpacket(1'b1),  		// .startofpacket
		.modular_adc_0_command_endofpacket(1'b1),    		// .endofpacket
		.modular_adc_0_command_ready(),          		// .ready
		.modular_adc_0_response_valid(res_valid),         	//modular_adc_0_response.valid
		.modular_adc_0_response_channel(res_ch),       		//                             .channel
		.modular_adc_0_response_data(res_data),          	//                             .data
		.modular_adc_0_response_startofpacket(1'b1), //                             .startofpacket
		.modular_adc_0_response_endofpacket(1'b1),   //    
		.adc_data_export(res_data),
		
		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
//		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
//		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		
		//I2C
		.i2c0_sda_in(I2C_SDA),
		.i2c0_scl_in(I2C_SCL),
		.i2c0_sda_oe(I2C_SDA_OE),
		.i2c0_scl_oe(I2C_SCL_OE)
	);


endmodule
