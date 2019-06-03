library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VGA_Controller is
	port (
	--VGA Side
		VGA_CLK	: out std_logic;
		hs,vs	: out std_logic;		
		oRed	: out std_logic_vector (2 downto 0);
		oGreen	: out std_logic_vector (2 downto 0);
		oBlue	: out std_logic_vector (2 downto 0);
	--RAM side
		R,G,B	: in  std_logic_vector (2 downto 0);
		addr	: out std_logic_vector (19 downto 0);
	--Control Signals
		reset	: in  std_logic;
		CLK_in	: in  std_logic
	);		
end entity VGA_Controller;

architecture behave of VGA_Controller is

--VGA
	signal CLK,CLK_2,CLK_4	: std_logic;
	signal rt,gt,bt	: std_logic_vector (2 downto 0);
	signal hst,vst	: std_logic;
	signal x		: std_logic_vector (9 downto 0);	
	signal y		: std_logic_vector (8 downto 0);		

begin
--reset<=not reset_in;

	--VGA_CLK	<= CLK; 
	CLK<=CLK_4;
 -----------------------------------------------------------------------
	process (CLK_in)
	begin
		if CLK_in'event and CLK_in = '1' then	
			CLK_2 <= not CLK_2;                 
		end if;
	end process;
	
	process (CLK_2)
	begin
		if CLK_2'event and CLK_2 = '1' then     
			CLK_4 <= not CLK_4;
			VGA_CLK <= CLK_4;
		end if;
	end process;	

 -----------------------------------------------------------------------
	process (CLK, reset)	
	begin
		if reset = '0' then
			x <= (others => '0');
		elsif CLK'event and CLK = '1' then
			if x = 799 then 
				x <= (others => '0');
			else
				x <= x + 1; 
			end if;
		end if;
	end process;

  -----------------------------------------------------------------------
	 process (CLK, reset)	
	 begin
	  	if reset = '0' then
	   		y <= (others => '0');
	  	elsif CLK'event and CLK = '1' then
	   		if x = 799 then
	    		if y = 524 then
	     			y <= (others => '0');
	    		else
	     			y <= y + 1;
	    		end if;
	   		end if;
	  	end if;
	 end process;
 
  -----------------------------------------------------------------------
	 process (CLK, reset)	
	 begin
		  if reset = '0' then
		   hst <= '1'; 
		  elsif CLK'event and CLK = '1' then
		   	if x >= 656 and x < 752 then
		    	hst <= '0';
		   	else
		    	hst <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process (CLK, reset)	
	 begin
	  	if reset = '0' then
	   		vst <= '1';
	  	elsif CLK'event and CLK = '1' then
	   		if y >= 490 and y< 492 then
	    		vst <= '0';
	   		else
	    		vst <= '1';
	   		end if;
	  	end if;
	 end process;
 -----------------------------------------------------------------------
	 process (CLK, reset)	
	 begin
	  	if reset = '0' then
	   		hs <= '0';
	  	elsif CLK'event and CLK = '1' then
	   		hs <=  hst;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process (CLK, reset)	
	 begin
	  	if reset = '0' then
	   		vs <= '0';
	  	elsif CLK'event and CLK='1' then
	   		vs <=  vst;
	  	end if;
	 end process;

------------------------------------------------------------------------
------------------------------------------------------------------------
	process (CLK, reset) 
	begin	  	
		if reset = '0' then
			rt		<=	(others => '0');
			gt		<=	(others => '0');
			bt		<=	(others => '0');
			addr	<=	(others => '0');
      elsif CLK'event and CLK='1' then
            if (x > 0 and x < 680) then
                if(y > 0 and y < 480) then
						  addr	<=	"0"&x&y;
						--   addr <= x(7 downto 0) & y(7 downto 0);
                    rt		<=	R;
                    gt		<=	G;
                    bt		<=	B;
						  --rt <= "111";
						  --gt <= "111";
						  --bt <= "111";
                else
                    rt <= "000";
                    gt <= "000";
                    bt <= "000";
                end if;
            else
                rt <= "000";
                gt <= "000";
                bt <= "000";
            end if;
	  	end if;
	end process;
-----------------------------------------------------------------------	
-----------------------------------------------------------------------
-----------------------------------------------------------------------
	-- process(reset,clk,x,y) 
	-- begin  
	-- 	if reset='1' then
	-- 		      rt <= "000";
	-- 				gt	<= "000";
	-- 				bt	<= "000";	
	-- 	elsif(clk'event and clk='1')then 
	-- 		if x>0 and x<213 then   
	-- 			rt <="000";				  	
	-- 			bt <="111";
	-- 		elsif x>=213 and x<426 then
	-- 			rt <="111";
	-- 			bt <="000";
	-- 		else
	-- 			rt <="111";
	-- 			bt <="111";
	-- 		end if;
		    
	-- 		if y<240 then				
	-- 		    gt   <="111";
	-- 		else
	-- 		    gt	<= "000";
	-- 		end if;		
	-- 	end if;		 
	--     end process;	

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
	process (hst, vst, rt, gt, bt)	
	begin
		if hst = '1' and vst = '1' then
			oRed	<= rt;
			oGreen	<= gt;
			oBlue	<= bt;
		else
			oRed	<= (others => '0');
			oGreen	<= (others => '0');
			oBlue	<= (others => '0');
		end if;
	end process;

end behave;