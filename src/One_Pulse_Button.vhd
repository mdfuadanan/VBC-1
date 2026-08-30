library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity One_Pulse_Button is
    port (
        clk       : in  std_logic;  -- system clock
        btn       : in  std_logic;  -- push button
        pulse_out : out std_logic   -- 1 pulse per press
    );
end One_Pulse_Button;

architecture Behavioral of One_Pulse_Button is

    signal btn_sync0, btn_sync1 : std_logic := '0';
    signal btn_prev             : std_logic := '0';

begin

    -- synchronize button
    process(clk)
    begin
        if rising_edge(clk) then
            btn_sync0 <= btn;
            btn_sync1 <= btn_sync0;
        end if;
    end process;

    -- generate ONE pulse on press
    process(clk)
    begin
        if rising_edge(clk) then
            pulse_out <= '0';
            if (btn_sync1 = '1' and btn_prev = '0') then
                pulse_out <= '1';
            end if;
            btn_prev <= btn_sync1;
        end if;
    end process;

end Behavioral;