library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity loadable_reg_4_bit is 
    port (
        rst, clk, load_r : in std_logic;
        d : in std_logic_vector (3 downto 0);
        q : out std_logic_vector (3 downto 0)
    );
end loadable_reg_4_bit;

architecture behavioral of loadable_reg_4_bit is
begin

    process(clk, rst)
    begin
        if rst = '1' then
            q <= "0000";
        elsif rising_edge(clk) then
            if load_r = '1' then
                q <= d;
            end if;
        end if;
    end process;

end behavioral;