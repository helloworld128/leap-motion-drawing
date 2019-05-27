library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VGA_Controller is
	port (
	--VGA Side
		VGA_CLK	: out std_logic;
		hs,vs	: out std_logic;		--琛屽悓姝ャ€佸満鍚屾淇″彿
		oRed	: out std_logic_vector (2 downto 0);--浣嶅�?
		oGreen	: out std_logic_vector (2 downto 0);--浣嶅�?
		oBlue	: out std_logic_vector (2 downto 0);--浣嶅�?
	--RAM side
		R,G,B	: in  std_logic_vector (2 downto 0);
		addr	: out std_logic_vector (19 downto 0);
	--Control Signals
		reset	: in  std_logic;--澶嶄�?
		CLK_in	: in  std_logic	--鏃堕�?		--100M鏃堕挓杈撳叆
	);		
end entity VGA_Controller;

architecture behave of VGA_Controller is

--VGA
	signal CLK,CLK_2,CLK_4	: std_logic;
	signal rt,gt,bt	: std_logic_vector (2 downto 0);--棰滆壊淇″彿
	signal hst,vst	: std_logic;
	signal x		: std_logic_vector (9 downto 0);		--X鍧愭�?
	signal y		: std_logic_vector (8 downto 0);		--Y鍧愭�?

begin
--reset<=not reset_in;

	--VGA_CLK	<= CLK; -- 鎶奀LK鐨勫€艰祴鍊肩粰VGA_CLK
	CLK<=CLK_4;
 -----------------------------------------------------------------------
	process (CLK_in)
	begin
		if CLK_in'event and CLK_in = '1' then	--�?00M杈撳叆淇″彿浜屽垎棰鍗褰撴椂閽熶俊鍙峰彉鍖骞朵笖鏄笂鍗囨部
			CLK_2 <= not CLK_2;                 -- 鎶奀LK鍙嶈祴缁機LK2
		end if;
	end process;
	
	process (CLK_2)
	begin
		if CLK_2'event and CLK_2 = '1' then     --鍥涘垎棰
			CLK_4 <= not CLK_4;
			VGA_CLK <= CLK_4;
		end if;
	end process;	

 -----------------------------------------------------------------------
	process (CLK, reset)	--琛屽尯闂村儚绱犳暟锛堝惈娑堥殣鍖猴級
	begin
		if reset = '0' then
			x <= (others => '0');
		elsif CLK'event and CLK = '1' then
			if x = 799 then --褰揦=799鏃鎶璧嬪€肩粰X
				x <= (others => '0');
			else
				x <= x + 1; --鏃堕挓淇″彿姣忎笂鍗囦竴娆X璁板綍涓€娆
			end if;
		end if;
	end process;

  -----------------------------------------------------------------------
	 process (CLK, reset)	--鍦哄尯闂磋鏁帮紙鍚秷闅愬尯锛
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
	 process (CLK, reset)	--琛屽悓姝ヤ俊鍙蜂骇鐢燂紙鍚屾瀹藉�?96锛屽墠娌6�?
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
	 process (CLK, reset)	--鍦哄悓姝ヤ俊鍙蜂骇鐢燂紙鍚屾瀹藉�?2锛屽墠娌0�?
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
	 process (CLK, reset)	--琛屽悓姝ヤ俊鍙疯緭鍑
	 begin
	  	if reset = '0' then
	   		hs <= '0';
	  	elsif CLK'event and CLK = '1' then
	   		hs <=  hst;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process (CLK, reset)	--鍦哄悓姝ヤ俊鍙疯緭鍑
	 begin
	  	if reset = '0' then
	   		vs <= '0';
	  	elsif CLK'event and CLK='1' then
	   		vs <=  vst;
	  	end if;
	 end process;

------------------------------------------------------------------------
------------------------------------------------------------------------
	process (CLK, reset) -- XY鍧愭爣瀹氫綅鎺у�?
	begin	  	
		if reset = '1' then
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
	-- process(reset,clk,x,y) -- XY鍧愭爣瀹氫綅鎺у�?
	-- begin  
	-- 	if reset='1' then
	-- 		      rt <= "000";
	-- 				gt	<= "000";
	-- 				bt	<= "000";	
	-- 	elsif(clk'event and clk='1')then 
	-- 		if x>0 and x<213 then   -- X鏂瑰悜鎺у�?,鍒嗕�?3鍒楋�?	
	-- 			rt <="000";				  	
	-- 			bt <="111";
	-- 		elsif x>=213 and x<426 then
	-- 			rt <="111";
	-- 			bt <="000";
	-- 		else
	-- 			rt <="111";
	-- 			bt <="111";
	-- 		end if;
		    
	-- 		if y<240 then				-- Y鏂瑰悜鎺у埗锛屽垎涓琛
	-- 		    gt   <="111";
	-- 		else
	-- 		    gt	<= "000";
	-- 		end if;		
	-- 	end if;		 
	--     end process;	

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
	process (hst, vst, rt, gt, bt)	--鑹插僵杈撳嚭
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