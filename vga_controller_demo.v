`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga640x480 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga640x480(
  input [26:0] grid_test,
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
  input wire lose,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
parameter d_width = 24;
parameter d_height = 48;
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
function integer d_offset_x (input integer di);
  d_offset_x = 7 + 7*(2-di) + 24*(2-di);
endfunction

function integer d_offset_y (input integer di);
  d_offset_y = 26;
endfunction

function integer offset_x (input integer tx,di);
  offset_x = 100*tx + d_offset_x(di);
endfunction

function integer offset_y (input integer ty,di);
  offset_y = 100*ty + d_offset_y(di);
endfunction

integer px, py, tx, ty, di;
integer digit = 'd3;
integer digit0 = 'd4;
integer digit1 = 'd6;
integer digit2 = 'd8;
//reg [26:0] grid_test = 'b000001010011100101110101110;

always @(*) begin
	// first check if we're within vertical active video range
  if (vc >= vbp && vc < vfp && hc >= hbp && hc < hfp) begin
    px = hc - hbp;
    py = vc - vbp;
    if (px < 300 && py < 300) begin
      for (tx = 0; tx < 3; tx = tx + 1) begin
        for (ty = 0; ty < 3; ty = ty + 1) begin
          if (px >= tx*100 && px < (tx*100+100) && py >= ty*100 && py < (ty*100+100)) begin
            case (tx+ty*3)
              'd0: begin 
                  // code below is supposed to take the number to be displayed in the first tile and turn it into 3 digits based on its value
                  case (grid_test[3*((2-tx)+ty*3) +: 3])
                      'b000: begin digit0 = 0; digit1 = 0; digit2 = 0; end
                      'b001: begin digit0 = 0; digit1 = 'd2; digit2 = 0; end
                      'b010: begin digit0 = 0; digit1 = 'd4; digit2 = 0; end
                      'b011: begin digit0 = 0; digit1 = 'd8; digit2 = 0; end
                      'b100: begin digit0 = 0; digit1 = 'd1; digit2 = 'd6; end
                      'b101: begin digit0 = 0; digit1 = 'd3; digit2 = 'd2; end
                      'b110: begin digit0 = 0; digit1 = 'd6; digit2 = 'd4; end
                      'b111: begin digit0 = 'd1; digit1 = 'd2; digit2 = 'd8; end
                  endcase
                red = 3'b111; green = 3'b111; blue = 2'b11;
                for (di = 0; di < 3; di = di + 1) begin
                    // The line below is supposed to use a different digit for the case statement based on which iteration through the loop we are in (commented out and replaced with a basic hardcoded input digit for testing tomorrow)
                    case (di==0 ? digit0 : di==1 ? digit1 : digit2)
                    //case (digit)
                        'd1: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di) + 10) && px < (tx*100 + 7*(di+1) + 24*(di+1) - 10) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd2: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd3: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd4: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd6: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd8: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                    endcase
                end
              end
              'd1: begin 
                // code below is supposed to take the number to be displayed in the first tile and turn it into 3 digits based on its value
                  case (grid_test[3*((2-tx)+ty*3) +: 3])
                      'b000: begin digit0 = 0; digit1 = 0; digit2 = 0; end
                      'b001: begin digit0 = 0; digit1 = 'd2; digit2 = 0; end
                      'b010: begin digit0 = 0; digit1 = 'd4; digit2 = 0; end
                      'b011: begin digit0 = 0; digit1 = 'd8; digit2 = 0; end
                      'b100: begin digit0 = 0; digit1 = 'd1; digit2 = 'd6; end
                      'b101: begin digit0 = 0; digit1 = 'd3; digit2 = 'd2; end
                      'b110: begin digit0 = 0; digit1 = 'd6; digit2 = 'd4; end
                      'b111: begin digit0 = 'd1; digit1 = 'd2; digit2 = 'd8; end
                  endcase
                red = 3'b110; green = 3'b110; blue = 2'b10;
                for (di = 0; di < 3; di = di + 1) begin
                    // The line below is supposed to use a different digit for the case statement based on which iteration through the loop we are in (commented out and replaced with a basic hardcoded input digit for testing tomorrow)
                    case (di==0 ? digit0 : di==1 ? digit1 : digit2)
                    //case (digit)
                        'd1: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di) + 10) && px < (tx*100 + 7*(di+1) + 24*(di+1) - 10) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd2: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd3: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd4: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd6: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd8: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                    endcase
                end
              end
              'd2: begin 
                // code below is supposed to take the number to be displayed in the first tile and turn it into 3 digits based on its value
                  case (grid_test[3*((2-tx)+ty*3) +: 3])
                      'b000: begin digit0 = 0; digit1 = 0; digit2 = 0; end
                      'b001: begin digit0 = 0; digit1 = 'd2; digit2 = 0; end
                      'b010: begin digit0 = 0; digit1 = 'd4; digit2 = 0; end
                      'b011: begin digit0 = 0; digit1 = 'd8; digit2 = 0; end
                      'b100: begin digit0 = 0; digit1 = 'd1; digit2 = 'd6; end
                      'b101: begin digit0 = 0; digit1 = 'd3; digit2 = 'd2; end
                      'b110: begin digit0 = 0; digit1 = 'd6; digit2 = 'd4; end
                      'b111: begin digit0 = 'd1; digit1 = 'd2; digit2 = 'd8; end
                  endcase
                red = 3'b111; green = 3'b111; blue = 2'b11;
                for (di = 0; di < 3; di = di + 1) begin
                    // The line below is supposed to use a different digit for the case statement based on which iteration through the loop we are in (commented out and replaced with a basic hardcoded input digit for testing tomorrow)
                    case (di==0 ? digit0 : di==1 ? digit1 : digit2)
                    //case (digit)
                        'd1: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di) + 10) && px < (tx*100 + 7*(di+1) + 24*(di+1) - 10) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd2: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd3: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd4: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd6: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd8: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                    endcase
                end
              end
              'd3: begin 
                // code below is supposed to take the number to be displayed in the first tile and turn it into 3 digits based on its value
                  case (grid_test[3*((2-tx)+ty*3) +: 3])
                      'b000: begin digit0 = 0; digit1 = 0; digit2 = 0; end
                      'b001: begin digit0 = 0; digit1 = 'd2; digit2 = 0; end
                      'b010: begin digit0 = 0; digit1 = 'd4; digit2 = 0; end
                      'b011: begin digit0 = 0; digit1 = 'd8; digit2 = 0; end
                      'b100: begin digit0 = 0; digit1 = 'd1; digit2 = 'd6; end
                      'b101: begin digit0 = 0; digit1 = 'd3; digit2 = 'd2; end
                      'b110: begin digit0 = 0; digit1 = 'd6; digit2 = 'd4; end
                      'b111: begin digit0 = 'd1; digit1 = 'd2; digit2 = 'd8; end
                  endcase
                red = 3'b110; green = 3'b110; blue = 2'b10;
                for (di = 0; di < 3; di = di + 1) begin
                    // The line below is supposed to use a different digit for the case statement based on which iteration through the loop we are in (commented out and replaced with a basic hardcoded input digit for testing tomorrow)
                    case (di==0 ? digit0 : di==1 ? digit1 : digit2)
                    //case (digit)
                        'd1: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di) + 10) && px < (tx*100 + 7*(di+1) + 24*(di+1) - 10) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd2: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd3: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd4: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd6: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd8: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                    endcase
                end
              end
              'd4: begin 
                // code below is supposed to take the number to be displayed in the first tile and turn it into 3 digits based on its value
                  case (grid_test[3*((2-tx)+ty*3) +: 3])
                      'b000: begin digit0 = 0; digit1 = 0; digit2 = 0; end
                      'b001: begin digit0 = 0; digit1 = 'd2; digit2 = 0; end
                      'b010: begin digit0 = 0; digit1 = 'd4; digit2 = 0; end
                      'b011: begin digit0 = 0; digit1 = 'd8; digit2 = 0; end
                      'b100: begin digit0 = 0; digit1 = 'd1; digit2 = 'd6; end
                      'b101: begin digit0 = 0; digit1 = 'd3; digit2 = 'd2; end
                      'b110: begin digit0 = 0; digit1 = 'd6; digit2 = 'd4; end
                      'b111: begin digit0 = 'd1; digit1 = 'd2; digit2 = 'd8; end
                  endcase
                red = 3'b111; green = 3'b111; blue = 2'b11;
                for (di = 0; di < 3; di = di + 1) begin
                    // The line below is supposed to use a different digit for the case statement based on which iteration through the loop we are in (commented out and replaced with a basic hardcoded input digit for testing tomorrow)
                    case (di==0 ? digit0 : di==1 ? digit1 : digit2)
                    //case (digit)
                        'd1: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di) + 10) && px < (tx*100 + 7*(di+1) + 24*(di+1) - 10) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd2: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd3: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd4: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd6: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd8: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                    endcase
                end
              end
              'd5: begin
                // code below is supposed to take the number to be displayed in the first tile and turn it into 3 digits based on its value
                  case (grid_test[3*((2-tx)+ty*3) +: 3])
                      'b000: begin digit0 = 0; digit1 = 0; digit2 = 0; end
                      'b001: begin digit0 = 0; digit1 = 'd2; digit2 = 0; end
                      'b010: begin digit0 = 0; digit1 = 'd4; digit2 = 0; end
                      'b011: begin digit0 = 0; digit1 = 'd8; digit2 = 0; end
                      'b100: begin digit0 = 0; digit1 = 'd1; digit2 = 'd6; end
                      'b101: begin digit0 = 0; digit1 = 'd3; digit2 = 'd2; end
                      'b110: begin digit0 = 0; digit1 = 'd6; digit2 = 'd4; end
                      'b111: begin digit0 = 'd1; digit1 = 'd2; digit2 = 'd8; end
                  endcase
                red = 3'b110; green = 3'b110; blue = 2'b10;
                for (di = 0; di < 3; di = di + 1) begin
                    // The line below is supposed to use a different digit for the case statement based on which iteration through the loop we are in (commented out and replaced with a basic hardcoded input digit for testing tomorrow)
                    case (di==0 ? digit0 : di==1 ? digit1 : digit2)
                    //case (digit)
                        'd1: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di) + 10) && px < (tx*100 + 7*(di+1) + 24*(di+1) - 10) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd2: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd3: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd4: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd6: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd8: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                    endcase
                end
              end
              'd6: begin 
                // code below is supposed to take the number to be displayed in the first tile and turn it into 3 digits based on its value
                  case (grid_test[3*((2-tx)+ty*3) +: 3])
                      'b000: begin digit0 = 0; digit1 = 0; digit2 = 0; end
                      'b001: begin digit0 = 0; digit1 = 'd2; digit2 = 0; end
                      'b010: begin digit0 = 0; digit1 = 'd4; digit2 = 0; end
                      'b011: begin digit0 = 0; digit1 = 'd8; digit2 = 0; end
                      'b100: begin digit0 = 0; digit1 = 'd1; digit2 = 'd6; end
                      'b101: begin digit0 = 0; digit1 = 'd3; digit2 = 'd2; end
                      'b110: begin digit0 = 0; digit1 = 'd6; digit2 = 'd4; end
                      'b111: begin digit0 = 'd1; digit1 = 'd2; digit2 = 'd8; end
                  endcase
                red = 3'b111; green = 3'b111; blue = 2'b11;
                for (di = 0; di < 3; di = di + 1) begin
                    // The line below is supposed to use a different digit for the case statement based on which iteration through the loop we are in (commented out and replaced with a basic hardcoded input digit for testing tomorrow)
                    case (di==0 ? digit0 : di==1 ? digit1 : digit2)
                    //case (digit)
                        'd1: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di) + 10) && px < (tx*100 + 7*(di+1) + 24*(di+1) - 10) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd2: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd3: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd4: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd6: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd8: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                    endcase
                end
              end
              'd7: begin 
                // code below is supposed to take the number to be displayed in the first tile and turn it into 3 digits based on its value
                  case (grid_test[3*((2-tx)+ty*3) +: 3])
                      'b000: begin digit0 = 0; digit1 = 0; digit2 = 0; end
                      'b001: begin digit0 = 0; digit1 = 'd2; digit2 = 0; end
                      'b010: begin digit0 = 0; digit1 = 'd4; digit2 = 0; end
                      'b011: begin digit0 = 0; digit1 = 'd8; digit2 = 0; end
                      'b100: begin digit0 = 0; digit1 = 'd1; digit2 = 'd6; end
                      'b101: begin digit0 = 0; digit1 = 'd3; digit2 = 'd2; end
                      'b110: begin digit0 = 0; digit1 = 'd6; digit2 = 'd4; end
                      'b111: begin digit0 = 'd1; digit1 = 'd2; digit2 = 'd8; end
                  endcase
                red = 3'b110; green = 3'b110; blue = 2'b10;
                for (di = 0; di < 3; di = di + 1) begin
                    // The line below is supposed to use a different digit for the case statement based on which iteration through the loop we are in (commented out and replaced with a basic hardcoded input digit for testing tomorrow)
                    case (di==0 ? digit0 : di==1 ? digit1 : digit2)
                    //case (digit)
                        'd1: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di) + 10) && px < (tx*100 + 7*(di+1) + 24*(di+1) - 10) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd2: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd3: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd4: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd6: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd8: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                    endcase
                end
              end
              'd8: begin 
                // code below is supposed to take the number to be displayed in the first tile and turn it into 3 digits based on its value
                  case (grid_test[3*((2-tx)+ty*3) +: 3])
                      'b000: begin digit0 = 0; digit1 = 0; digit2 = 0; end
                      'b001: begin digit0 = 0; digit1 = 'd2; digit2 = 0; end
                      'b010: begin digit0 = 0; digit1 = 'd4; digit2 = 0; end
                      'b011: begin digit0 = 0; digit1 = 'd8; digit2 = 0; end
                      'b100: begin digit0 = 0; digit1 = 'd1; digit2 = 'd6; end
                      'b101: begin digit0 = 0; digit1 = 'd3; digit2 = 'd2; end
                      'b110: begin digit0 = 0; digit1 = 'd6; digit2 = 'd4; end
                      'b111: begin digit0 = 'd1; digit1 = 'd2; digit2 = 'd8; end
                  endcase
                red = 3'b111; green = 3'b111; blue = 2'b11;
                for (di = 0; di < 3; di = di + 1) begin
                    // The line below is supposed to use a different digit for the case statement based on which iteration through the loop we are in (commented out and replaced with a basic hardcoded input digit for testing tomorrow)
                    case (di==0 ? digit0 : di==1 ? digit1 : digit2)
                    //case (digit)
                        'd1: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di) + 10) && px < (tx*100 + 7*(di+1) + 24*(di+1) - 10) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd2: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd3: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00;
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            else if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd4: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 24)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd6: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 24) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                        'd8: begin
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 4)) begin
                              red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 23) && py < (ty*100 + 26 + 27)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26 + 44) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di)) && px < (tx*100 + 7*(di+1) + 24*(di) + 4) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                            if (px >= (tx*100 + 7*(di+1) + 24*(di+1) - 4) && px < (tx*100 + 7*(di+1) + 24*(di+1)) && py >= (ty*100 + 26) && py < (ty*100 + 26 + 48)) begin
                                red = 3'b000; green = 3'b000; blue = 2'b00; 
                            end
                        end
                    endcase
                end
              end
              endcase
          end
        end
      end
    end
    else begin
      red = 3'b000; green = 3'b000; blue = 2'b00;
      if (lose) begin
        red = 3'b111; green = 3'b000; blue = 2'b00;
      end
    end
  end
  else begin
    red = 0; green = 0; blue = 0;
  end
end

endmodule
