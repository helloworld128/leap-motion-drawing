library ieee;
use ieee.std_logic_1164.all;

entity VGActSRAM is
    port(
        clk : in std_logic;
        rst : in std_logic;
        -- mode : in std_logic; -- '0' 向VGA写   '1'从SRAM读 
        vR,vG,vB : out std_logic_vector(2 downto 0);
        -- addrs : inout std_logic_vector(15 downto 0);
        -- addr_out : out std_logic_vector(19 downto 0);
        RAMdata : in std_logic_vector(31 downto 0)
    );
end entity VGActSRAM;

architecture beha of VGActSRAM is
begin
    process(clk,rst)
    begin
        if(rst = '0') then
            vR <= "000";
            vB <= "000";
            vG <= "000";
            -- addrs <= (others => '0');
        elsif (clk'event and clk = '1') then
            -- addr_out <= addr_in;
            vR <= RAMdata(8 downto 6);
            vG <= RAMdata(5 downto 3);
            vB <= RAMdata(2 downto 0);  
        end if;
    end process;

end architecture beha;