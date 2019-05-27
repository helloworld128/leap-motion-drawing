library ieee;
use ieee.std_logic_1164.all;

entity computation is
    port(
        clk : in std_logic;
        rst : in std_logic;
        gesture_con : in std_logic_vector(15 downto 0);
        color_out : out std_logic_vector(31 downto 0)
    );
end entity computation;

architecture beh of computation is
	begin
	process(clk)
	begin
		color_out <= (others=>'0');
	end process;

end architecture beh;
