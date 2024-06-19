module Design (

input  wire        rst,
input  wire        clk,
//newly added
input wire		i_idle,
input wire	 	i_lang,
input reg[4:0] i_dep,
input wire		i_with, 
input wire		i_bal, 
input reg [4:0]	i_transfer, 
input wire		i_depConf, 
input wire		i_withConf, 
input wire		i_transferConf, 
input reg [4:0]	i_chooseBal, 
input reg[4:0]	i_addVal, 
input wire		i_balNotEnough, 
input wire		i_balEnq,
input reg[3:0]	i_passwd,
input reg [2:0] i_transactionMenu,

//newly added
output reg 		o_transferConf,
output reg		o_depConf,
output reg		o_withConf,
output reg		o_balEnq,
output reg		o_balNotEnough,
output reg		o_pin




);
reg [4:0] balance=5'b10000; /////to be reviewed 


localparam  [3:0]    IDLE = 4'b0000,
                     Lang = 4'b0001,
                     Pin = 4'b0010,
					 Transaction = 4'b0011,
					 Deposit = 4'b0100,
					 Withdraw = 4'b0101 ,
					 Balance_inq = 4'b0110 ,
					 Balance_notenough = 4'b0111 ,
					 Transfer = 4'b1000,
					 Transfer_confirm = 4'b1001 ,
					 Deposit_confirm = 4'b1010 ,
					 withdraw_confirm = 4'b1011 ,
					 with_another = 4'b1100 ,
					 chooseBal = 4'b1101;


reg    [3:0]         current_state,
                     next_state ;
		
// state transition 		
always @(posedge clk or negedge rst)
 begin
  if(!rst) 
   begin
     current_state <= IDLE ;
   end
  else
   begin
    current_state <= next_state;
	 
   end
 end
 
// next_state logic
always @(*)
 begin
  case(current_state)
  IDLE     : begin
              if(!i_idle)
			   next_state = IDLE ;
			  else if (i_idle)
               next_state = Lang ;
              else
               next_state = IDLE ;			  
             end
  Lang       : begin
              if(!i_lang)
			   next_state = Lang ;
			  else if (i_lang)
               next_state = Pin ;
              else
               next_state = Lang ;	   
            end
  Pin         : begin
              if(i_passwd!=4'b1111)
			   next_state = Pin ;
			  else if (i_passwd==4'b1111)
               next_state = Transaction ;
              else
               next_state = Pin ;	   
            end
			
 Transaction    : begin
              if(i_transactionMenu==3'b000)
			   next_state = Transaction ;
			  else if (i_transactionMenu==3'b011)
               next_state = Balance_inq ;
              else if (i_transactionMenu==3'b010)
               next_state = Withdraw ;	
			  else if (i_transactionMenu==3'b001)
			  next_state= Deposit;
			  else if (i_transactionMenu==3'b100)
			  next_state= Transfer;
			  else 
			  next_state=Transaction;
            end
Transfer        : begin
              if(i_transfer > balance)
			
			   next_state = Balance_notenough ;
			  else if (i_transfer< balance || i_transfer==balance)
			  begin
			  balance = balance - i_transfer;
              next_state = Transfer_confirm ;
			   end
              else
               next_state = Transfer ;	    
            end
Balance_inq    : begin
              if(!i_balEnq)
			   next_state = IDLE ;
			  else if (i_balEnq)
               next_state = Transaction ;
              else
               next_state = Balance_inq ;	    
            end
Withdraw   : begin
             if(!i_with)
			   next_state = with_another ;
		     else if (i_with)
               next_state = chooseBal ;
             else
               next_state = Withdraw ;	   
            end	
//check 
chooseBal         : begin
             if(i_chooseBal>balance)
			   next_state = Balance_notenough;
		     else if (i_chooseBal<=balance)
			 begin
				balance = balance - i_chooseBal;
               next_state =withdraw_confirm;
			   end
			 else
               next_state = chooseBal ;	   
            end	

withdraw_confirm : begin
					if (!i_withConf)
						next_state=IDLE;
					else if (i_withConf)
						next_state= Transaction;
					else 
						next_state=withdraw_confirm;
					end
with_another : begin 
					if (i_addVal>balance)
						next_state=Balance_notenough;
					else if (i_addVal<=balance)
					begin
						balance= balance-i_addVal;
						next_state= withdraw_confirm;
					end
					else 
						next_state=with_another;
					end
Deposit : begin
					if (i_dep==5'b00000)
						next_state=Deposit;
					else if (i_dep>5'b00000)
					begin
						balance= balance +i_dep;
						next_state=Deposit_confirm;
					end
					else 
						next_state=Deposit;
					end
Deposit_confirm : begin
					if (!i_depConf)
						next_state=IDLE;
					else if (i_depConf)
						next_state=Transaction;
					else 
						next_state=Deposit_confirm ;
					end
Balance_notenough : begin
					if (!i_balNotEnough)
						next_state=IDLE;
					else if (i_balNotEnough)
						next_state=Transaction;
					else 
						next_state=Balance_notenough;
					end
Transfer_confirm  : begin
					if (!i_transferConf)
						next_state=IDLE;
					else if (i_transferConf)
						next_state=Transaction;
					else 
						next_state=Transfer_confirm;
					end
					
						
  default :   next_state = IDLE ;		 
  
  endcase
end	


// next_state logic
always @(*)
 begin
  case(current_state)
  IDLE     : begin
			o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
  Lang     : begin
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end	
  Pin      : begin ///leh feeh output lel pin aslan?
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b1;	   
             end
 Transaction : begin
			o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
  Transfer    : begin
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;		   
             end			 
Transfer_confirm  : begin
            o_transferConf=1'b1;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
Balance_inq : begin 
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b1;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
Balance_notenough : begin
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b1;
			o_pin=1'b0;
             end
Withdraw  : begin
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
with_another    : begin
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
  chooseBal    : begin
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
withdraw_confirm     : begin
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b1;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
  Deposit     : begin
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
  Deposit_confirm    : begin
            o_transferConf=1'b0;
			o_depConf=1'b1;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
             end
			 
  default  : begin
           
            o_transferConf=1'b0;
			o_depConf=1'b0;
			o_withConf=1'b0;
			o_balEnq=1'b0;
			o_balNotEnough=1'b0;
			o_pin=1'b0;
          
             end			  
  endcase
end


//psl assert always((current_state==4'b1010)-> (o_depConf) )@(posedge clk);
//psl assert always((current_state==4'b1011)-> (o_withConf) )@(posedge clk);	
//psl assert always((current_state==4'b0111)-> (o_balNotEnough)) @(posedge clk);	
//psl assert always((current_state==4'b1001)-> (o_transferConf)) @(posedge clk);	
//psl assert always((current_state==4'b0010)-> (o_pin)) @(posedge clk);	



//psl assert always((current_state==4'b0110 && i_balEnq)-> next(current_state==4'b0011)) @(posedge clk);
//psl assert always((current_state==4'b0110 && !i_balEnq)-> next(current_state==4'b0000)) @(posedge clk);

//psl assert always((current_state==4'b1010 && i_depConf)-> next(current_state==4'b0011)) @(posedge clk);
//psl assert always((current_state==4'b1010 && !i_depConf)-> next(current_state==4'b0000)) @(posedge clk);

//psl assert always((current_state==4'b0011 && i_transactionMenu==3'b001)-> next(current_state==4'b0100)) @(posedge clk);
//psl assert always((current_state==4'b0011 && i_transactionMenu==3'b010)-> next(current_state==4'b0101)) @(posedge clk);
//psl assert always((current_state==4'b0011 && i_transactionMenu==3'b011)-> next(current_state==4'b0110)) @(posedge clk);
//psl assert always((current_state==4'b0011 && i_transactionMenu==3'b100)-> next(current_state==4'b1000)) @(posedge clk);
//psl assert always((current_state==4'b0011 && i_transactionMenu==3'b000)-> next(current_state==4'b0011)) @(posedge clk);
endmodule