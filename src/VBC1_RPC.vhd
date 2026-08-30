library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity VBC1_RPC is port (
    rst, speed, load_new_a : in std_logic;
    new_a : in std_logic_vector (3 downto 0);
    prog_a : out std_logic_vector (3 downto 0)
);
end VBC1_RPC;

architecture mixed of VBC1_RPC is

    signal inc: std_logic;
    signal sel_a: std_logic_vector(3 downto 0);
    signal sum: std_logic_vector(3 downto 0);
begin
    sel_a <= prog_a when load_new_a = '0' else new_a;
    inc <= not load_new_a;
    sum <= STD_LOGIC_VECTOR(unsigned(sel_a) + "0001") when inc = '1' else sel_a;
    
    process(rst, speed)
    begin
        if rst = '1' then
            prog_a <= "0000";
        elsif rising_edge(speed) then
            prog_a <= sum;
        end if;
    end process;
end mixed;