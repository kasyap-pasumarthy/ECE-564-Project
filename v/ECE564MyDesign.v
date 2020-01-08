//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// DUT

// synopsys translate_off
`include "/afs/eos.ncsu.edu/dist/synopsys_apps/syn_vP-2019.03-SP1/dw/sim_ver/DW02_mult.v"
//synopsys translate_on
module ECE564MyDesign
	    (

            //---------------------------------------------------------------------------
            // Control
            //
            input  wire               xxx__dut__run            ,             
            output reg                dut__xxx__busy           , // high when computing
            input  wire               clk                      ,
            input  wire               reset_b                  ,


            //--------------------------------------------------------------------------- 
            //---------------------------------------------------------------------------
            // SRAM interface
            //
            output reg  [11:0]        dut__sram__write_address  ,
            output reg  [15:0]        dut__sram__write_data     ,
            output reg                dut__sram__write_enable   ,
            output reg  [11:0]        dut__sram__read_address   ,
            input  wire [15:0]        sram__dut__read_data      ,
            
            //---------------------------------------------------------------------------
            // f memory interface
            //
            //output reg  [11:0]        dut__fmem__read_address   , 
            //input  wire [15:0]        fmem__dut__read_data      ,  // read data

            //---------------------------------------------------------------------------
            // g memory interface
            //
            output reg  [11:0]        dut__gmem__read_address   ,
            input  wire [15:0]        gmem__dut__read_data      ,  // read data

            //---------------------------------------------------------------------------
            // i memory interface
            //
           // output reg  [11:0]        dut__imem__read_address   ,
            //input  wire [15:0]        imem__dut__read_data      ,  // read data
            
            //---------------------------------------------------------------------------
            // o memory interface
            //
            //output reg  [11:0]        dut__omem__read_address   ,
            //input  wire [15:0]        omem__dut__read_data      ,  // read data

            //---------------------------------------------------------------------------
            // Tanh look up table tanhmem 
            //
            output reg  [11:0]        dut__tanhmem__read_address     ,
            input  wire [15:0]        tanhmem__dut__read_data          // read data
            //output reg  [11:0]        dut__tanhmem__read_address_2     ,
            //input  wire [15:0]        tanhmem__dut__read_data_2           // read data

            );

  //---------------------------------------------------------------------------
  //
  //<<<<----  YOUR CODE HERE    ---->>>>
//Wg * X. NOT X* Wg

//temp wires and regs and params

reg [15:0] W_inp;
reg [15:0] X_inp;
reg [16:0] W_extended;
reg [16:0] X_extended;
reg [34:0] product_store;
wire[33:0] interim_product;
reg [7:0] counter;
reg [35:0] accumulator [255:0];
reg [15:0] tanh_1;
reg [15:0] tanh_2;
reg [12:0] counter1;
reg [12:0] counter2;
reg [15:0] xcount;
reg [4:0] counter_tan;
reg [35:0] temp_accum;
reg [35:0] temp_accum_compl;
reg [18:0] temp_accum_val;
reg [11:0] tanh_add_1;
reg [11:0] tanh_add_2;
reg [33:0] y;
reg [16:0] x0;
reg [16:0] x1;
reg [15:0] y0;
reg [15:0] y1;
reg [16:0] x;
reg status;
reg [2:0] round_counter;




parameter A_width = 17;
parameter B_width = 17;

wire mult_TC;

integer i,j;

assign mult_TC =1; // used to tell multiplier module to use signed multiply. use 0 for unsigned.
// instantiate floating point Multiplier, 



//address_get A1 (dut__gmem__read_address, gmem_next_address);
//address_get A2 ();
//data_get D1 (gmem_next_address, gmem);
//data_get D2 ();
DW02_mult #(A_width, B_width)			 M1 (
							.A(W_extended), 
							.B(X_extended), 
							.TC(mult_TC), 
							.PRODUCT(interim_product)
							);
//accumulator ac_1 ();

always @ (posedge clk)//checking for reset
begin

if(!reset_b  )
begin
//$display ("I am being reset");

//$display ("round_counter is %d", round_counter);
dut__xxx__busy <=0;

if(round_counter >0)
begin
//$display("not changing rc");
end

else
begin
round_counter <=0;
end


//$display ("i have been reset");
end//end reset block


// if(dut__sram__read_address >= 510 && dut__gmem__read_address >= 510)
//     begin
//       dut__xxx__busy <=0;
//     end

if(xxx__dut__run && !dut__xxx__busy)
begin
  dut__xxx__busy <=1;
  //$display("i am being asked to run");
end
if(dut__sram__write_address >= 1022 && dut__xxx__busy)
begin
  dut__xxx__busy <=0;
  round_counter<= round_counter+1;
  //$display("i am done running");
end

end


//tanh block
always @ (posedge clk)
begin

if(!reset_b)
begin

temp_accum<=0;
temp_accum_compl <=0;
temp_accum_val<=0;
tanh_add_1<=0;
tanh_add_2<=0;
tanh_1<=0;
tanh_2<=0;
dut__tanhmem__read_address<=0;
x<=0;
x0<=0;
x1<=0;
y0<=0;
y1<=0;
y<=0;
dut__sram__write_data <=0;
dut__sram__write_enable<=0;
dut__sram__write_address<=510;

end

else if(reset_b  )
begin
    if(product_store !=0)
    begin
      //$display("counter value %d", counter1);
      //$display ("adding mult out %d to accumulator %d at counter %d",  product_store,accumulator[counter1], counter1 );
      if((counter1 ==0 && counter2 == 16)|| (counter1 !=0 && counter2 == 15))
      begin
        if(counter1==0)
        begin
          temp_accum <= accumulator[counter1];
	  //temp_accum_compl <=~accumulator[counter1] +1 ;
          //$display("accum is is %d", (accumulator[counter1]));
        end
        else
        begin
          temp_accum <= accumulator[counter1]+product_store;
	  //temp_accum_compl <=~(accumulator[counter1]+product_store) +1 ;
         // $display("accum is is %d", (accumulator[counter1]+ product_store));
        end
      end
    end
      if( status && temp_accum)
      begin
	//$display("tan counter is %d", counter_tan);           
	 //$display("temp accum is %d",temp_accum);
          if(temp_accum[34])
          begin   
            temp_accum_compl <= ~temp_accum +1;
            temp_accum_val[18:0] <= temp_accum_compl[33:15];
            //temp_accum_val[18:0] <= {(~temp_accum +1)}[33:15];
           
            tanh_add_1 <= {3'b0,temp_accum_compl[31:24],1'd0};
            //tanh_add_1 <= {3'b0,{(~temp_accum +1)}[31:24],1'd0};
            tanh_add_2 <= {3'b0,temp_accum_compl[31:24],1'd0} + 2;
	    //tanh_add_2 <= {3'b0,{(~temp_accum +1)}[31:24],1'd0} + 2;
           
          end
          else if (!temp_accum[34])
          begin
            temp_accum_compl <= temp_accum;
            
            temp_accum_val[18:0] <= temp_accum[33:15];
            
            //tanh_add_1 <= {3'b0,temp_accum_val[16:9],1'd0};
            tanh_add_1 <= {3'b0,temp_accum_compl[31:24],1'd0};
            //tanh_add_2 <= {3'b0,temp_accum_val[16:9],1'd0} + 2;
            tanh_add_2 <= {3'b0,temp_accum_compl[31:24],1'd0} +2;
          end
      end
            if(counter_tan == 0)
            begin
            //  $display("tan counter %d", counter_tan);
            end
            
            if(counter_tan == 1)
            begin

            // $display("tan counter %d", counter_tan);
            end

            if(counter_tan == 2)
            begin
            // $display("tan counter %d", counter_tan);
            end

            if(counter_tan == 3)
            begin
            // $display("tan counter %d", counter_tan);
            end
            
            if(counter_tan == 4)
            begin
               //$display("temp_accum is %d", temp_accum);
              // $display("temp val is %d",temp_accum_val);
              //$display("add 1 %d",tanh_add_1 );
              //$display("add 2 %d",tanh_add_2 );
              //$display("tan counter %d", counter_tan);
              
            
              dut__tanhmem__read_address <= {3'b0,temp_accum_compl[31:24],1'd0};
              //$display("add 1 %d",dut__tanhmem__read_address );
            end
            
            if(counter_tan == 5)
            begin
              
            // $display("tan counter %d", counter_tan);
            end
            
            if(counter_tan == 6)
            begin
            // $display("tan counter %d", counter_tan);
            //$display("add 1 %d",tanh_add_1 );
              dut__tanhmem__read_address <= {3'b0,temp_accum_compl[31:24],1'd0} +2;
              
              tanh_1 <= tanhmem__dut__read_data;
            end
            
            if(counter_tan == 7)
            begin
              //$display("add 2 %d",dut__tanhmem__read_address );
                //$display("Data 1 %b",tanh_1 );
            // $display("tan counter %d", counter_tan);
            end
            
            if(counter_tan == 8)
            begin
            //$display("add 2 %d",tanh_add_2 );
            //$display("Data 1 %d",tanh_1 );
            // $display("tan counter %d", counter_tan);
              tanh_2 <= tanhmem__dut__read_data;
            end
            
            if(counter_tan == 9)
            begin
              //$display("temp val %d", temp_accum_val);
             //$display("Data 2 %d",tanh_2 );
            // $display("tan counter %d", counter_tan);
            //$display("temp val is %b", temp_accum_val);
              if(temp_accum_val[18:17] == 2)
              begin
                //$display("is 3");
                if(temp_accum[34])
                begin
                  y <= 36'h3c0008000;
                end
                else 
                begin
                  y<= 36'h03fff8000;
                end

              end

              else
              begin
              // $display("is not 3");
                  x <= temp_accum_val[16:0];
                  x0 <= {temp_accum_val[16:9], 9'b0};
                  x1 <= {{temp_accum_val[16:9]+1}, 9'b0};
                  y0 <= tanh_1;
                  y1 <= tanh_2;
              end
            end
            
            if(counter_tan == 10)
            begin

              // $display(", x %d , x0 %d, x1 %d, y0 %d, y1 %d", x, x0, x1, y0, y1);
            // $display("tan counter %d", counter_tan);
              if(temp_accum_val[18:17] == 2)
              begin
                y<= y;
              end
              else
              y <= (y0*(x1-x))+(y1*(x-x0));
            end
            
            if(counter_tan == 11 && y!=0)
            begin
            // $display("tan counter %d", counter_tan);
              if(temp_accum[34])
              begin
                y<= ~y +1;
              end
              else
              begin
                y<= y;
              end
            end
            
            if(counter_tan == 12 && y!=0)
            begin
               
            // $display("tan counter %d", counter_tan);
              y<= y<<9;
            end
            
            if(counter_tan == 13 && y!=0 && dut__xxx__busy)
            begin
//$display ("i am writing");

              //$display("y %d, writing to %d", y, dut__sram__write_address);
              //$display("tan counter %d", counter_tan);
              dut__sram__write_data <= y[33:18];
             // $display("%b, writing at %d", y,dut__sram__write_address );

              dut__sram__write_enable <= 1;
              dut__sram__write_address <= dut__sram__write_address +2;
            end

            if(counter_tan == 14)
            begin
            // $display("tan counter %d", counter_tan);
              dut__sram__write_enable <= 0;
            end
            
            if(counter_tan == 15)
            begin
            // $display("tan counter %d", counter_tan);
            end    

         
        
    


      
    
    end
end





// address block
always @ (posedge clk)
begin

if(!reset_b)
begin

counter<=0;
dut__gmem__read_address<=0;
dut__sram__read_address<=0;
xcount<=0;
end


else if(reset_b )
  begin
    
    //$display("g address %d x address %d ", dut__gmem__read_address, dut__sram__read_address);
    
    counter <= counter +1;
    dut__gmem__read_address <= dut__gmem__read_address +2;
    if(counter[7:0] == 255)
    begin
      //counter1 <= counter1 +1;
      //$display("accumulator %b counter1 %d ", accumulator[counter1], counter1);
      dut__gmem__read_address <=0;
      //x_counter <= x_counter +1;
      dut__sram__read_address <= dut__sram__read_address +2;
    end
    else if(counter[3:0] == 15)
    begin
      //counter1 <= counter1 +1;
      //$display("accumulator %b counter1 %d ", accumulator[counter1], counter1);
      xcount <= xcount +1;
      dut__sram__read_address <= dut__sram__read_address - 30;
    end
    else
    begin
      xcount <= xcount +1;
      dut__sram__read_address <= dut__sram__read_address +2;
    end
  end
end


//tan h counter
always @(posedge clk)

begin
  //accumulator[counter1] <= accumulator[counter1] + product_store;
  if(!reset_b || counter_tan == 15 )
  begin
    counter_tan <= 0;
  end
  else if (product_store !=0)
  begin
    counter_tan  <= counter_tan +1;
  end
end





//multiply block
always @ (posedge clk)
begin

if(!reset_b)
begin

W_inp<=0;
X_inp<=0;
W_extended<=0;
X_extended<=0;
product_store<=0;
counter2<=0;
status<=0;
counter1<=0;

for(i =0; i<256; i = i+1)

begin
accumulator[i]<=0;

end

end


  else if( reset_b   )
  begin
      W_inp <= gmem__dut__read_data;
      X_inp <= sram__dut__read_data;


if(round_counter == 0)
begin
      W_extended <= {{1{gmem__dut__read_data[15]}},gmem__dut__read_data};
      X_extended <= {{1{sram__dut__read_data[15]}},sram__dut__read_data};
end

else
begin
      W_extended <= {{1{W_inp[15]}},W_inp};
      X_extended <= {{1{X_inp[15]}},X_inp};
end
      product_store <=  {{1{interim_product[33]}}, interim_product};

if(round_counter ==0)
begin
      if(interim_product !=0)
      begin
      counter2 <= counter2+1;
      status<=0;
      end
end

else
begin
if(product_store !=0)
      begin
      counter2 <= counter2+1;
      status<=0;
      end
end

      if((counter1 ==0 && counter2 == 16)|| (counter1 !=0 && counter2 == 15))
      begin
      counter2 <= 0;
      counter1 <= counter1 +1;
      status <=1;
      end
      
      if(round_counter == 0)
      begin
     if(counter1 == 0)
     begin
        accumulator[counter1] <= accumulator[counter1] +{{1{interim_product[33]}}, interim_product};
     end
     else 
     begin
        accumulator[counter1] <= accumulator[counter1] +product_store;
     end
end

else
begin
accumulator[counter1] <= accumulator[counter1] +product_store;
 //       accumulator[counter1] <= accumulator[counter1] +{{1{interim_product[33]}}, interim_product};

end
  end
  
end
endmodule

