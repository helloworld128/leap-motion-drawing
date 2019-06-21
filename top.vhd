library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

    entity top is
    port(
        clk11 : in std_logic;
        rst : in std_logic;
        rx : in std_logic;
        tx : out std_logic;
        clk100 : in std_logic;
			
        hso,vso : out std_logic;
        ored : out std_logic_vector(2 downto 0);
        oblue: out std_logic_vector(2 downto 0);
        ogreen: out std_logic_vector(2 downto 0)
    );
end entity top;

architecture bha of top is
    
    signal vgadata : std_logic_vector(8 downto 0);
    signal vga_x : std_logic_vector(8 downto 0);
    signal vga_y : std_logic_vector(8 downto 0);
    signal read_addr : std_logic_vector(16 downto 0);

    signal uartdata : std_logic_vector(8 downto 0);
    signal uart_x : std_logic_vector(8 downto 0);
    signal uart_y : std_logic_vector(8 downto 0);
    signal write_addr : std_logic_vector(16 downto 0);

    signal rw : std_logic;
    signal vga_clk : std_logic;
    signal uart_clk: std_logic;
    signal wren : std_logic := '1';

    signal cur_x : std_logic_vector(8 downto 0);
    signal cur_y : std_logic_vector(8 downto 0);
     
    component ram
        PORT(
            data        : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
            rdaddress        : IN STD_LOGIC_VECTOR (16 DOWNTO 0);
            rdclock        : IN STD_LOGIC ;
            wraddress        : IN STD_LOGIC_VECTOR (16 DOWNTO 0);
            wrclock        : IN STD_LOGIC  := '1';
            wren        : IN STD_LOGIC  := '0';
            q        : OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
        );
    end component;
    
    component VGA_Controller is
        port(
            VGA_CLK : out std_logic;
            hs,vs   : out std_logic;
            oRed    : out std_logic_vector(2 downto 0);
            oGreen  : out std_logic_vector(2 downto 0);
            oBlue   : out std_logic_vector(2 downto 0);

            rgbin   : in std_logic_vector(8 downto 0);
            x_out   : out std_logic_vector(8 downto 0);
            y_out   : out std_logic_vector(8 downto 0);

            cursor_x : in std_logic_vector(8 downto 0);
            cursor_y : in std_logic_vector(8 downto 0);
            reset   : in std_logic;
            CLK_in  : in std_logic
        );
    end component;
    

    component uart is
        port(
            clk : in std_logic; -- 11.0592MHz
            rst : in std_logic;
            rx  : in std_logic;
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
    end component;


begin
    v2:VGA_Controller port map(x_out=>vga_x, y_out=>vga_y, rgbin=>vgadata, CLK_in=>clk100, reset=>rst, hs=>hso, vs=>vso, oRed=>ored, oGreen=>ogreen, oBlue=>oblue, VGA_CLK=>vga_clk,cursor_x=>cur_x, cursor_y=>cur_y);
    u2:uart port map(x=>uart_x, y=>uart_y, color=>uartdata, clk=>clk11,rst=>rst, rx=>rx, tx=>tx, uart_clk_out=>uart_clk, cursor_x=>cur_x, cursor_y=>cur_y);
    mem:ram port map(data=>uartdata, rdaddress=>read_addr, rdclock=>vga_clk, wraddress=>write_addr, wrclock=>uart_clk, wren=>wren, q=>vgadata);

    process (clk100)
    begin
        if clk100'event and clk100 = '1' then -- calculate read & write address
            --read_addr <= std_logic_vector(resize(unsigned(vga_y) * 320 + unsigned(vga_x), 17));
            --write_addr <= std_logic_vector(resize(unsigned(uart_y) * 320 + unsigned(uart_x), 17));
				read_addr <= vga_x & vga_y(7 downto 0);
            --write_addr <= uart_x & uart_y(7 downto 0);
        end if;
    end process;
	
	 process(uart_clk)
	 begin
		if rising_edge(uart_clk) then
			 write_addr <= uart_x & uart_y(7 downto 0);
		end if;
	end process;
	 
end architecture bha;