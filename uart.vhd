library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart is
    port(
            clk : in std_logic; -- 11.0592MHz
            rst : in std_logic;
            rx : in std_logic;
            tx : out std_logic;
            x : out std_logic_vector(8 downto 0);
            y : out std_logic_vector(8 downto 0);
            color : out std_logic_vector(8 downto 0);
            uart_clk_out : out std_logic;
            draw : out std_logic;
            cursor_x : out std_logic_vector(8 downto 0);
            cursor_y : out std_logic_vector(8 downto 0);
            reset_canvas : out std_logic
        );
end entity;

architecture bev of uart is

signal cnt:integer range 0 to 1151 := 0;
signal uart_clk:std_logic;
signal rx8bit:std_logic_vector(7 downto 0);
signal cnt2   : integer range 0 to 9;
signal reccnt : integer range 0 to 5 :=0;

signal xaxis  : std_logic_vector(15 downto 0) := "0000000000000000";
signal yaxis  : std_logic_vector(15 downto 0) := "0000000000000000";
signal control : std_logic_vector(7 downto 0);
constant cnt_max : integer := 95 ;
signal draw_color : std_logic_vector(8 downto 0) := "101101000";
signal uart_clk_in : std_logic := '0';

signal clean_flag : std_logic := '0';
signal clean_finish : std_logic := '0';
signal clean_x : std_logic_vector(8 downto 0) := "000000000";
signal clean_y : std_logic_vector(8 downto 0) := "000000000";

signal color_x : std_logic_vector(8 downto 0) := "000000000";
signal color_y : std_logic_vector(8 downto 0) := "000000000";
signal pre_x : std_logic_vector(8 downto 0) := "001000000";
signal pre_y : std_logic_vector(8 downto 0) := "001000000";
signal flag : std_logic := '0';


begin 

    process(rst,clk)
    begin
        if rst = '0' then 
            cnt <= 0;
        elsif clk'event and clk = '1' then        
            if cnt = cnt_max then 
                cnt <= 0;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;


    process(clk,rst)
    begin
        if rst = '0' then 
            uart_clk <= '0';
        elsif clk'event and clk = '1' then     
            if cnt = cnt_max then
                uart_clk <= '1';    
					 uart_clk_out <= '1';
            else
                uart_clk <= '0';  
					 uart_clk_out <= '0';	 
  
            end if;
        end if;
    end process;


    -- -- test
    -- process(uart_clk)
    -- begin
    --     if uart_clk'event and uart_clk = '1' then
    --         if yaxis < 240 then
    --             if xaxis < 320 then
    --                 x <= xaxis(8 downto 0);
    --                 y <= yaxis(8 downto 0);
    --                 color <= draw_color(8 downto 0);
    --                 xaxis <= xaxis + 1;
    --             else
    --                 yaxis <= yaxis + 1;
    --                 xaxis <= (others=>'0');
    --             end if;
    --         else
    --             yaxis <= (others=>'0');
    --         end if;
    --     end if;
    -- end process;


    process(rst,uart_clk)
    begin 
        if rst='0' then 
            rx8bit<=(others=>'1');
        elsif uart_clk'event and uart_clk='1' then 
            case cnt2 is
                when 0 => 
                    if rx='0' then
								
                        cnt2<=cnt2+1;
                    end if;
                uart_clk_in <= '0';
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
                                            cnt2 <= cnt2+1;
                when 9 => if(rx = '1') then
                            case( reccnt ) is
                                    when 0 =>  
                                        if rx8bit(7 downto 5) = "000" then
                                            control(4 downto 0) <= rx8bit(4 downto 0); reccnt <= reccnt + 1;
                                            if rx8bit(1) = '1' then
                                                if clean_finish = '1' then
                                                    clean_flag <= '0';
                                                else
                                                    clean_flag <= '1';
                                                end if;
                                             else
                                                clean_flag <= '0';
                                            end if;
                                        else
                                            reccnt <= 0;
                                        end if;
                                    when 1 => 
                                        if rx8bit(7 downto 5) = "001" then
                                            xaxis(4 downto 0) <= rx8bit(4 downto 0); reccnt <= reccnt + 1;
                                        else
                                            reccnt <= 0;
                                        end if;
                                    when 2 => 
                                        if rx8bit(7 downto 5) = "010" then
                                            xaxis(9 downto 5) <= rx8bit(4 downto 0); reccnt <= reccnt + 1;
                                        else
                                            reccnt <= 0;
                                        end if;
                                    when 3 => 
                                        if rx8bit(7 downto 5) = "011" then
                                            yaxis(4 downto 0) <= rx8bit(4 downto 0); reccnt <= reccnt + 1;
                                        else
                                            reccnt <= 0;
                                        end if;
                                    when 4 => 
                                        if rx8bit(7 downto 5) = "100" then
                                            yaxis(9 downto 5) <= rx8bit(4 downto 0); reccnt <= 0;
                                            uart_clk_in <= '1';

                                        else
                                            reccnt <= 0;
                                        end if;
                                    when others => NULL;
                            end case;
                         end if;
                            cnt2<=0;
                when others=> cnt2<=0;
    
            end case ;
        end if ;
    end process;

    -- process(uart_clk_in)
    -- begin
    --     if rising_edge(uart_clk_in) then
    --         x <= xaxis(8 downto 0);
    --         y <= yaxis(8 downto 0);
    --         color <= draw_color;
    --     end if;
    -- end process;

    process(uart_clk)
    begin
        if rising_edge(uart_clk) then
			cursor_x <= xaxis(8 downto 0);
         cursor_y <= yaxis(8 downto 0);
        --  if flag = '0' then
		-- 		pre_x <= xaxis(8 downto 0);
		-- 		pre_y <= yaxis(8 downto 0);
		-- 	else
			  
		-- 	  if pre_x < xaxis(8 downto 0) + 20 and xaxis(8 downto 0)  < pre_x + 20 then
        --    if pre_y < yaxis(8 downto 0) + 20 and yaxis(8 downto 0) < pre_y + 20 then

				
            if control(2) = '1' then
                if color_y < 20 then
                    if color_x < 20 then
                        color_x <= color_x + 1;
                    else
                        color_y <= color_y + 1;
                        color_x <= (others=>'0');
                    end if;
                else
                    color_x <= (others=>'0');
                    color_y <= (others=>'0');
                end if;
                x <= color_x;
                y <= color_y;
                color <= draw_color;
            else    
                if control(0) = '1' then
                    if clean_flag = '0' then
                        x <= xaxis(8 downto 0);
                        y <= yaxis(8 downto 0);
                        color <= draw_color;
                        clean_finish <= '0';

                    else
                        if clean_y < 239 then
                            if clean_x < 319 then
                                clean_x <= clean_x + 1;
                            else
                                clean_y <= clean_y + 1;
                                clean_x <= (others=>'0');
                            end if;
                            clean_finish <= '0';
                        else
                            clean_x <= (others=>'0');
                            clean_y <= (others=>'0');
                            clean_finish <= '1';
                        end if;
                        x <= clean_x;
                        y <= clean_y;
                        color <= (others=>'0');
                    end if;
            --     end if;
            -- end if;
			-- 	end if;
            end if;
				end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if control(2) = '1' then
                draw_color <= xaxis(8 downto 0);
            end if;
        end if;
    end process;


    
end bev;
                            
                    
                            
        