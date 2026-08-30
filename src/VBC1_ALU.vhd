library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Standard arithmetic package

entity VBC1_ALU is port (
    IR : in std_logic_vector (2 downto 0);
    r_ir, r0_r1 : in std_logic_vector (3 downto 0);
    ALU_OUT : out std_logic_vector (3 downto 0)
);
end VBC1_ALU;

architecture behavior of VBC1_ALU is
begin
    process(IR, r_ir, r0_r1)
    begin
         ALU_OUT <= "0000";
         case IR is
            when "001" => ALU_OUT <= r_ir; --LOADI
            when "011" => ALU_OUT <= std_logic_vector(unsigned(r0_r1) + unsigned(r_ir)); --ADD
            when "010" => ALU_OUT <= std_logic_vector(unsigned(r0_r1) + unsigned(r_ir)); --ADD
            when "100" => ALU_OUT <= '0' & r_ir(3 downto 1); -- SR0
            when others => ALU_OUT <= "0000";
        end case;
    end process;
end behavior;