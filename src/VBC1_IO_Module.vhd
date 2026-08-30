library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VBC1_IO_Module is
    Port (
        load_dr, load_led, load_seg, clk, rst : in std_logic;
        sw : in std_logic_vector(3 downto 0);
        di, ld : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0)
    );
end VBC1_IO_Module;

architecture Behavioral of VBC1_IO_Module is
    signal di_int : std_logic_vector(3 downto 0);
    signal dr     : std_logic_vector(3 downto 0);
    signal op1    : std_logic_vector(3 downto 0);
    signal op2    : std_logic_vector(3 downto 0);
    signal d7s    : std_logic_vector(6 downto 0);

begin

    di_int <= sw;
    di <= di_int;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                dr <= "0000";
            elsif load_dr = '1' then
                dr <= di_int;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                op1 <= "0000";
            elsif load_led = '1' then
                op1 <= dr;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                op2 <= "0000";
            elsif load_seg = '1' then
                op2 <= dr;
            end if;
        end if;
    end process;

    ld <= op1;

    d7s <= "0111111" when op2 = "0000" else
           "0000110" when op2 = "0001" else
           "1011011" when op2 = "0010" else
           "1001111" when op2 = "0011" else
           "1100110" when op2 = "0100" else
           "1101101" when op2 = "0101" else
           "1111101" when op2 = "0110" else
           "0000111" when op2 = "0111" else
           "1111111" when op2 = "1000" else
           "1101111" when op2 = "1001" else
           "1110111" when op2 = "1010" else
           "1111100" when op2 = "1011" else
           "0111001" when op2 = "1100" else
           "1011110" when op2 = "1101" else
           "1111001" when op2 = "1110" else
           "1110001";

    seg <= d7s;

end Behavioral;