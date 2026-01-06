library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity alu is
    generic (
        constant W : positive := 32
    );
    port (
        A : in std_logic_vector (W-1 downto 0);
        B : in std_logic_vector (W-1 downto 0);
        sel_fn : in std_logic_vector (3 downto 0);
        Y : out std_logic_vector (W-1 downto 0);
        Z : out std_logic
    );
    constant Ws : positive := positive(ceil(log2(real(W))));
end alu;

architecture arch of alu is
    signal UA,UB,UY : unsigned(W-1 downto 0);
    signal SA,SB : signed(W-1 downto 0);
begin
    Z <= nor Y;
    Y <= std_logic_vector(UY);
    UA <= unsigned(A);
    UB <= unsigned(B);
    SA <= signed(A);
    SB <= signed(B);
    with sel_fn select UY <=
        UA + UB when "0000",
        UA - UB when "0001",
        UA sll to_integer(UB(Ws-1 downto 0)) when "0010" | "0011",
        (W-1 downto 1 => '0')&(SA ?< SB) when "0100" | "0101",
        (W-1 downto 1 => '0')&(UA ?< UB) when "0110" | "0111",
        UA xor UB when "1000" | "1001",
        UA srl to_integer(UB(Ws-1 downto 0)) when "1010",
        unsigned(shift_right(SA,to_integer(UB(Ws-1 downto 0)))) when "1011",
        UA or UB when "1100" | "1101",
        UA and UB when others; -- "1110" | "1111"
end arch ; -- arch