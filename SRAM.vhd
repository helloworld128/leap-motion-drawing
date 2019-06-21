LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

entity SRAM is 
port(
--- reset & clk 
	clk      : in std_logic;
	reset    : in std_logic;

    mode    : in std_logic_vector(1 downto 0);
    addr_read : in std_logic_vector(19 downto 0);
    addr_write: in std_logic_vector(19 downto 0);
	data_in : in std_logic_vector(31 downto 0);
    rwdata : out std_logic_vector(31 downto 0);
--- memory 	to CFPGA
	BASERAMWE           : out std_logic;   --write                    
	BASERAMOE           : out std_logic;    --read                   
	BASERAMCE           : out std_logic;		--cs
	BASERAMADDR         : out std_logic_vector(19 downto 0);                                                              
	BASERAMDATA         : inout std_logic_vector(31 downto 0)
);
end SRAM;

architecture beh of SRAM is
    type memory_state is  (idle,mem_read,mem_write,mem_end);
    signal state : memory_state;
    signal data_out : std_logic_vector(31 downto 0);
    signal in_addr : std_logic_vector(19 downto 0);
    signal clk50M : std_logic := '0';

    begin
        process(clk)
        begin
            if clk'event and clk = '1' then
                clk50M <= not clk50M;
            end if;
        end process;

        process( clk,reset,clk50M )
        begin
            if(reset = '0') then
                state <= idle;
            elsif(clk'event and clk = '1') then
                case state is
                    when idle => 
                                 if(mode = "01") then   -- 01 read   10 write  else null
                                         state <= mem_read;
                                 elsif(mode = "10") then
                                         state <= mem_write;
                                 else
                                     state <= idle;
                                 end if;
                                --state <= mem_read;
                    when mem_read =>
                        state <= mem_end;
                    when mem_write =>
                        state <= mem_end;
                    when mem_end =>
                        state <= idle;   
                    end case;
					end if;
        end process ;
    
        process(reset,clk,clk50M)
        begin
            if reset='0' then
                BASERAMCE <= '1';
                BASERAMOE <= '1';
                BASERAMWE <= '1';
            elsif clk'event and clk = '1' then
                case state is
                    when idle =>
                        BASERAMCE <= '1';
                        BASERAMWE <= '1';
                        BASERAMOE <= '1';
                        BASERAMDATA <= (others=>'Z');
                        BASERAMADDR <= (others=>'Z');
                    when mem_read =>
                        BASERAMWE <= '1';
                        BASERAMCE <= '0';
                        BASERAMOE <= '0';
                        BASERAMADDR <= addr_read;
                        -- data_out <= BASERAMDATA;
                        rwdata <= BASERAMDATA;
                    when mem_write =>
                        BASERAMWE <= '0';
                        BASERAMOE <= '1';
                        BASERAMCE <= '0';
                        BASERAMADDR <= addr_write;
                        BASERAMDATA <= data_in;
                    when mem_end => 
                        BASERAMCE <= '1';
                        BASERAMOE <= '1';
                        BASERAMWE <= '1';
                        BASERAMADDR<=(others=>'Z');                                                                    
                        BASERAMDATA<=(others=>'Z');
                    when others => 
                        BASERAMCE <= '1';
                        BASERAMOE <= '1';
                        BASERAMWE <= '1';
                        BASERAMADDR<=(others=>'Z');                                                                    
                        BASERAMDATA<=(others=>'Z');    
                    end case;
				end if;
         end process;
    end architecture;
            