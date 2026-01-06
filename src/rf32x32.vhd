library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rf32x32 is
    port (
        clk     : in  std_logic;
        we      : in  std_logic;
        addr_a  : in  std_logic_vector(4 downto 0);
        addr_b  : in  std_logic_vector(4 downto 0);
        addr_w  : in  std_logic_vector(4 downto 0);
        din     : in  std_logic_vector(31 downto 0);
        dout_a   : out std_logic_vector(31 downto 0);
        dout_b   : out std_logic_vector(31 downto 0)
    );
end entity rf32x32;

architecture rtl of rf32x32 is

    type ram_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(addr_w))) <= din;
            end if;
        end if;
        dout_a <= ram(to_integer(unsigned(addr_a)));
        dout_b <= ram(to_integer(unsigned(addr_b)));
    end process;
end architecture rtl;