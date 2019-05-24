library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart is
	port(
				clk : in std_logic; --11MHz鏃堕挓
				rst : in std_logic;
				rx : in std_logic;
			---  to delete
				LEDRX: out std_logic_vector(7 downto 0);--鎺ユ敹RX鏁版嵁鏄剧ず鍒版暟鐮佺
				tx : out std_logic;
				RamAddr	: out std_logic_vector(19 downto 0);
				RamData	: out std_logic_vector(31 downto 0);
				uart_clk_out : out std_logic;
				draw : out std_logic
		);
end entity;

architecture bev of uart is

--clock to revise 
-- 9600 per 8 receive 8 + 3 bits
-- instead of 1 bit 
signal cnt:integer range 0 to 1151 := 0;
signal uart_clk:std_logic;
signal rx8bit:std_logic_vector(7 downto 0);
signal tx8bit:std_logic_vector(7 downto 0);
signal cnt1   : integer range 0 to 9;
signal cnt2   : integer range 0 to 9;
signal reccnt : integer range 0 to 5;
-- signal xaxis  : std_logic_vector(9 downto 0) ;
-- signal yaxis  : std_logic_vector(9 downto 0) ;
-- signal tempdata : std_logic_vector(31 downto 0) ;

signal xaxis  : std_logic_vector(15 downto 0);
signal yaxis  : std_logic_vector(15 downto 0);
signal pre_xaxis : std_logic_vector(15 downto 0) := (others=>'0'); 
signal pre_yaxis : std_logic_vector(15 downto 0) := (others=>'0');
constant xy_sub : std_logic_vector(15 downto 0) := "0000000000000000";
signal gesture : std_logic_vector(7 downto 0);

begin 
------------------------------------------娉㈢壒鐜囧彂鐢熷櫒

bps:process(rst,clk)
begin
						if rst='0' then 
							cnt<=0;
						elsif (clk'event and clk='1')    then		--鏃堕挓璁℃暟鍣
								if cnt = 1151  then 
									cnt<=0;
								else
									cnt<=cnt+1;
								end if;
						end if;
end process;

process(clk,rst)
begin
				if rst='0' then 
					uart_clk<='0';
					elsif  clk'event and clk='1' then 	
						if (cnt=1151) then
						uart_clk<='1';	--娉㈢壒鐜囬珮鐢靛钩
						else
						uart_clk<='0';	--娉㈢壒鐜囦綆鐢靛钩
						end if;
				end if;
				uart_clk_out <= uart_clk;
end process;
-------------------------------------------
process(rst,clk)
begin 
	if rst='0' then 
		tx8bit<=(others=>'1');
	elsif clk'event and clk='1' then 
		tx8bit<=b"10000000";--0x80
	end if ;
end process;
-------------------------------------------TX鐘舵€佹満璁℃暟鍣
process(rst,clk)
begin 
	if rst='0' then 
		cnt1<=0;
	elsif uart_clk'event and uart_clk='1' then 
		if cnt1=9 then 
			cnt1<=0;
		else 
			cnt1<=cnt1+1;
		end if ;
	end if ;
end process;
-------------------------------------------鍙戦€佹暟鎹姸鎬佹満
process(rst,clk)
begin 
	if rst='0' then 
		tx<='0';
	elsif clk'event and clk='1' then 
		case cnt1 is
			when 0 =>tx<='0';				--璧峰浣鍙戦€佷綆鐢靛钩浠
			when 1 =>tx<=tx8bit(0);
			when 2 =>tx<=tx8bit(1);
			when 3 =>tx<=tx8bit(2);
			when 4 =>tx<=tx8bit(3);
			when 5 =>tx<=tx8bit(4);
			when 6 =>tx<=tx8bit(5);
			when 7 =>tx<=tx8bit(6);
			when 8 =>tx<=tx8bit(7);
			when 9 =>tx<='1';				--鍋滄浣鍙戦€侀珮鐢靛钩
			when others=> tx<='0';
		end case ;
	end if ;
end process;
--------------------------------------------鎺ユ敹鏁版嵁鐘舵€佹満
process(rst,clk)
begin 
	if rst='0' then 
		rx8bit<=(others=>'1');
	elsif uart_clk'event and uart_clk='1' then 
		case cnt2 is
			when 0 => 
				if rx='0' then
					cnt2<=cnt2+1;
				end if;

			when 1 =>rx8bit(0)<=rx;
										cnt2<=cnt2+1;
			when 2 =>rx8bit(1)<=rx;
										cnt2<=cnt2+1;
			when 3 =>rx8bit(2)<=rx;
										cnt2<=cnt2+1;
			when 4 =>rx8bit(3)<=rx;
										cnt2<=cnt2+1;
			when 5 =>rx8bit(4)<=rx;
										cnt2<=cnt2+1;
			when 6 =>rx8bit(5)<=rx;
										cnt2<=cnt2+1;
			when 7 =>rx8bit(6)<=rx;
										cnt2<=cnt2+1;
			when 8 =>rx8bit(7)<=rx;
							  --to delete
									--LEDRX<=rx8bit;
									--tempdata := tempdata + 1;
									case( reccnt ) is
										-- when 0 => xaxis <= "00" & rx8bit; reccnt <= 1;
										-- when 1 => yaxis <= "00" & rx8bit; reccnt <= 0;
										when 0 =>  gesture <= rx8bit; reccnt <= reccnt + 1;
										when 1 => xaxis(7 downto 0) <= rx8bit; reccnt <= reccnt + 1;
										when 2 => xaxis(15 downto 8) <= rx8bit; reccnt <= reccnt + 1;
										when 3 => yaxis(7 downto 0) <= rx8bit; reccnt <= reccnt + 1;
										when 4 => yaxis(15 downto 8) <= rx8bit; reccnt <= 0;
										when others => NULL;
						   		end case ;
								
								cnt2<=0;
								
								--tempdata <= tempdata + 1;
								--	case( reccnt ) is
								--		--when 0 => xaxis <= rx8bit; reccnt <= 1;
								--		--when 1 => yaxis <= rx8bit; reccnt <= 0;
								--		when 0 => xaxis <= xaxis + 1; reccnt <= 1;
								--		when 1 => yaxis <= yaxis + 1; reccnt <= 0;
								--		when others => NULL;
								--	end case ;
								--cnt2 <= 0;
								
								
			when others=> cnt2<=0;
							 LEDRX <= "11111111";
		end case ;
	end if ;
end process;
--

process(reccnt)
variable tempData : std_logic_vector(31 downto 0) := (others=>'1');

begin
	if(reccnt = 0) then
		if(gesture(0) = '0') then
			draw <= '0';
		else
			draw <= '1';
		end if;
		if (gesture(1) = '0') then
			tempData := (others=>'1');
		else
			if(gesture(2) = '1') then
				tempData := tempData + yaxis - pre_yaxis;
			end if;
		end if;

		pre_xaxis <= xaxis;
		pre_yaxis <= yaxis; 
		RamData <= tempData;
		RamAddr <= "0" & xaxis(9 downto 0) & yaxis(8 downto 0); 
	end if;
end process;

end bev;
							
					
							
		