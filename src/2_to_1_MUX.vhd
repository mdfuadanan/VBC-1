library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity mux2_1 is port(
    sel: in std_logic; -- select line
    ch0,ch1: in std_logic_vector(3 downto 0); -- inputs
    y: out std_logic_vector(3 downto 0) -- output
);
end mux2_1;

architecture behavior of mux2_1  is
    begin
        y <= ch0 when sel = '0' else ch1;
            

    end behavior;