library ieee;
use ieee.std_logic_1164.all;

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
        ogreen: out std_logic_vector(2 downto 0);
        LEDRX: out std_logic_vector(7 downto 0);
		  WE  : out std_logic;
        OE  : out std_logic;
        CE  : out std_logic;
        addr_sram   : out std_logic_vector(19 downto 0);
        data_sram   : inout std_logic_vector(31 downto 0)
    );
end entity top;

architecture bha of top is

    signal midRed   : std_logic_vector(2 downto 0) := "000";
    signal midBlue  : std_logic_vector(2 downto 0) := "000";
    signal midGreen : std_logic_vector(2 downto 0) := "000";
    signal VGA_RAM_addr : std_logic_vector(19 downto 0);
    signal Uart_RAM_addr: std_logic_vector(19 downto 0);
    signal RAM_to_VGA_data  : std_logic_vector(31 downto 0);
    signal Uart_to_RAM_data : std_logic_vector(31 downto 0); 
	 signal bufferdata : std_logic_vector(31 downto 0);
    signal uart_clk : std_logic := '0';
    signal vga_clk : std_logic := '0';
    signal rwmode : std_logic_vector(1 downto 0) := "00";
    signal addr_for_ram_read : std_logic_vector(19 downto 0);
    signal addr_for_ram_write : std_logic_vector(19 downto 0);
    signal data_for_ram : std_logic_vector(31 downto 0);
    signal cnt: integer range 0 to 250 := 0;
	 
	type rwstate is (idle, readram, writeram, rwend);
    signal stat : rwstate := idle;
    signal draw_uart : std_logic := '1';
     
    
    component VGA_Controller is
        port(
            VGA_CLK : out std_logic;
            hs,vs   : out std_logic;
            oRed    : out std_logic_vector(2 downto 0);
            oGreen  : out std_logic_vector(2 downto 0);
            oBlue   : out std_logic_vector(2 downto 0);

            R,G,B	: in  std_logic_vector (2 downto 0);
            addr	: out std_logic_vector (19 downto 0);

            reset   : in std_logic;
            CLK_in  : in std_logic
        );
    end component;
    
    component VGActSRAM is
        port(
            clk : in std_logic;
            rst : in std_logic;
            vR, vG, vB  : out std_logic_vector(2 downto 0);
            -- addrs : inout std_logic_vector(15 downto 0);
            -- addr_out : out std_logic_vector(19 downto 0);
            RAMdata :in std_logic_vector(31 downto 0)
        );
    end component;


    component uart is
        port(
            clk : in std_logic; --100MHz
            rst : in std_logic;
            rx : in std_logic;
        ---  to delete
            LEDRX: out std_logic_vector(7 downto 0);--
            tx : out std_logic;
            RamAddr	: out std_logic_vector(19 downto 0);
            RamData	: out std_logic_vector(31 downto 0);
            uart_clk_out : out std_logic;
            draw : out std_logic
        );
    end component;
    
    component SRAM is
        port(
        --- reset & clk 
            clk      : in std_logic;
            reset    : in std_logic;

            mode    : in std_logic_vector(1 downto 0);
            addr_read : in std_logic_vector(19 downto 0);
            addr_write : in std_logic_vector(19 downto 0);
            data_in : in std_logic_vector(31 downto 0);
            rwdata : out std_logic_vector(31 downto 0);
        --- memory 	to CFPGA
            BASERAMWE           : out std_logic;   --write                    
            BASERAMOE           : out std_logic;    --read                   
            BASERAMCE           : out std_logic;		--cs
            BASERAMADDR         : out std_logic_vector(19 downto 0);                                                              
            BASERAMDATA         : inout std_logic_vector(31 downto 0)
        );
    end component;


	begin
		v2:VGA_Controller port map(CLK_in=>clk100, reset=>rst, hs=>hso, vs=>vso, oRed=>ored, oGreen=>ogreen, oBlue=>oblue, R=>midRed, G=>midGreen, B=>midBlue, addr=>VGA_RAM_addr, VGA_CLK=>vga_clk);
        vtran:VGActSRAM port map(clk=>vga_clk, rst=>rst, vR=>midRed, vG=>midGreen, vB=>midBlue, RAMdata=>bufferdata);
        -- ra:ramsin port map(data=>Uart_to_RAM_data, rdaddress=>VGA_RAM_addr, rdclock=>vga_clk, wraddress=> Uart_RAM_addr, wrclock=>uart_clk, wren=>'0', q=>bufferdata);
		u2:uart port map(clk=>clk11,rst=>rst, rx=>rx, tx=>tx, LEDRX=>LEDRX ,RamAddr=>Uart_RAM_addr, RamData=>Uart_to_RAM_data, uart_clk_out=>uart_clk,draw=>draw_uart);
		--LEDRX<="11111111";
        rm:SRAM port map(clk=>clk100, reset=>rst, mode=>rwmode, addr_read=>addr_for_ram_read, addr_write=>addr_for_ram_write,data_in=>data_for_ram, rwdata=>bufferdata,BASERAMWE=>WE, BASERAMCE=>CE, BASERAMOE=>OE, BASERAMADDR=>addr_sram, BASERAMDATA=>data_sram);

	-- process(uart_clk)
	-- begin
	-- 	if(uart_clk'event and uart_clk = '1') then
	-- 		RAMDATA <= bufferdata;
	-- 		from_uart_data <= Uart_to_RAM_data;
	-- 		from_uart_addr <= Uart_RAM_addr;
	-- 		--LEDRX <= bufferdata(7 downto 0);
	-- 	end if;
    -- end process;
    
    -- process(uart_clk, vga_clk)
    -- begin
    --     if(uart_clk'event and uart_clk = '1') then
    --         rwmode <= "10";
    --         addr_for_ram_read <= Uart_RAM_addr;
    --         data_for_ram <= Uart_to_RAM_data;
    --     -- elsif (vga_clk'event and vga_clk = '1') then
    --     --     rwmode <= "01";
    --     --     addr_for_ram_read <= VGA_RAM_addr;
    --     else
    --         rwmode <= "00";
    --         -- addr_for_ram_read <= VGA_RAM_addr;
    --     end if;
    -- end process;


    -- process(clk100, uart_clk)
    -- begin
    --     if(clk100'event and clk100='1') then
    --         if (cnt = 900) then
    --             rwmode <= "10";
    --             addr_for_ram_read <= Uart_RAM_addr;
    --             data_for_ram <= Uart_to_RAM_data;
    --             cnt <= 0;
    --         else
    --             rwmode <= "01"; 
    --             addr_for_ram_read <= VGA_RAM_addr;
    --             cnt <= cnt + 1;
    --         end if;
    --     end if;
    -- end process ;
                

    -- process(uart_clk,vga_clk)
    -- begin
    --     if(uart_clk'event and uart_clk = '1') then
    --         cnt <= 1;
    --     end if;
    -- end process;
    
    process(vga_clk)
    begin
        if(vga_clk'event and vga_clk = '1') then
            cnt <= cnt + 1;
        end if;
        end process;

    process(vga_clk)
    begin
        if(vga_clk'event and vga_clk = '1') then
            if(cnt = 250) then
                if(draw_uart = '1') then
                    rwmode <= "10";
                    addr_for_ram_write <= Uart_RAM_addr;
                    data_for_ram <= Uart_to_RAM_data;
                else
                    rwmode <= "01";
                end if;
            else
                rwmode <= "01"; 
                addr_for_ram_read <= VGA_RAM_addr;
            end if;
        end if;
    end process;

end architecture bha;