library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VBC1_Instruction_Decoder is port (
    IR : in std_logic_vector (7 downto 0);
    r0, r1 : in std_logic_vector (3 downto 0);
    IR_7_to_5: out std_logic_vector (7 downto 5);
    IR_3_to_0 : out std_logic_vector(3 downto 0);
    M1,M2,M3,M4,M5,M6,Load_R0,Load_R1,Load_OP,Z1,Z0 : out std_logic
);
end VBC1_Instruction_Decoder;

architecture behavioral of VBC1_Instruction_Decoder is
    signal z0_i,z1_i: std_logic;
    signal not_R0,not_R1: std_logic_vector(3 downto 0);

begin
    IR_7_to_5 <= IR(7 downto  5);
    IR_3_to_0 <= IR(3 downto  0);
    not_R0 <= not r0;
    not_R1 <= not r1;
    z0_i <=  not_R0(0) and not_R0(1) and not_R0(2) and not_R0(3);
    z1_i<= not_R1(0) and not_R1(1) and not_R1(2) and not_R1(3);
    Z0<=z0_i;
    Z1<=z1_i;
    process(IR, z0_i, z1_i)
        
        begin
            M1<='0'; 
            M2<='0';
            M3<='0';
            M4<='0';
            M5<='0';
            M6<='0';
            Load_R0<='0';
            Load_R1<='0';
            Load_OP<='0';
            case IR(7 downto 5) is
                ------------------------------------------------
                when "000" => -- MOV DR, SR OK
                ------------------------------------------------
                    M1 <= '0';
                    M2 <= '0';
                    M3 <= '0';
                    M4 <= '0';
                    M5 <= '0';
                    M6 <= '0';
                    Load_OP <= '0';
                    case IR(4 downto 3) is
                        when "00" =>  -- MOV R0 <- R0
                            Load_R0 <= '1';
                            Load_R1 <= '0';
                        when "01" =>  -- MOV R0 <- R1
                            M2 <= '1';
                            Load_R0 <= '1';
                            Load_R1 <= '0';
                        when "10" =>  -- MOV R1 <- R0 
                            Load_R0 <= '0';
                            Load_R1 <= '1';
                        when "11" =>  -- MOV R1 <- R1
                            M2 <= '1';
                            Load_R0 <= '0';
                            Load_R1 <= '1';
                        when others => null;
                    end case;
                --------------------------------------------------
                when "001" => -- LOADI DR, Data OK
                --------------------------------------------------
                    M1 <= '0';
                    M2 <= '0';
                    M3 <= '1';
                    M4 <= '0';
                    M5 <= '1';
                    M6 <= '0';
                    case IR(4) is
                        when '0' => Load_R0 <= '1';
                        when '1' => Load_R1 <= '1';
                        when others => null;
                    end case;
                --------------------------------------------------
                when "010" => -- ADD DR,SR OK
                --------------------------------------------------
                    M1 <= '0';
                    M2 <= '0';
                    M3 <= '1';
                    M4 <= '0';
                    M5 <= '0';
                    M6 <= '0';
                    case IR(4 downto 3) is
                        when "00" => 
                            M4 <= '0';
                            Load_R0 <= '1';
                        when "01" => 
                            M4 <= '1';
                            Load_R0 <= '1';   
                        when "10" => 
                            M4 <= '1';
                            Load_R1 <= '1';
                        when "11" => 
                            M2 <= '1';
                            Load_R1 <= '1';
                        when others => null;
                    end case;
                --------------------------------------------------
                when "011" => -- ADDI DR, Data OK
                --------------------------------------------------
                    M1 <= '0';
                    M2 <= '0';
                    M3 <= '1';
                    M4 <= '0';
                    M5 <= '1';
                    M6 <= '0';
                    case IR(4) is
                        when '0' => 
                            Load_R0 <= '1' ;
                        when '1' => 
                            M2<= '1' ; 
                            Load_R1 <= '1';
                        when others => null;
                    end case;
                --------------------------------------------------
                when "100" => -- SHIFT DR, SR OK
                --------------------------------------------------
                    M1 <= '0';
                    M2 <= '0';
                    M3 <= '1';
                    M4 <= '0';
                    M5 <= '0';
                    M6 <= '0';
                    case IR(4 downto 3) is
                        when "00" => 
                            Load_R0 <= '1';
                        when "01" => 
                            M4 <='1'; 
                            Load_R0 <= '1';
                        when "10" => 
                            Load_R1 <= '1';
                        when "11" => 
                            M4 <= '1'; 
                            Load_R1 <= '1';
                        when others => null;
                    end case;
                --------------------------------------------------
                when "101" => -- IN DR OK
                --------------------------------------------------
                    M1 <= '1';
                    case IR(4) is
                        when '0' => Load_R0 <= '1';
                        when '1' => Load_R1 <= '1';
                        when others => null;
                    end case;
                --------------------------------------------------
                when "110" => -- OUT DR OK
                --------------------------------------------------
                    Load_OP <= '1';
                    case IR(4) is
                        when '0' =>M2 <= '0';
                        when '1' =>M2 <= '1';
                        when others => null;
                    end case;
                --------------------------------------------------
                when "111" => -- JNZ DR, Address OK
                --------------------------------------------------
                    if (IR(4) = '0' and z1_i = '0' and z0_i = '0' ) then
                        M6<='1';
                    elsif (IR(4) = '0' and z1_i = '1'  and z0_i = '0') then
                        M6 <='1';
                    elsif(IR(4) = '1' and z1_i = '0'  and z0_i = '0') then
                        M6 <='1';
                    elsif(IR(4) = '1' and z1_i = '0'  and z0_i = '1') then
                        M6<='1';
                    end if;
                    when others => null;
                end case;
    end process;
end behavioral;