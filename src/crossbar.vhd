library ieee;
use ieee.std_logic_1164.all;
use work.tipos.all;

entity crossbar is 
    generic (
        constant num_slaves : positive := 1
    );
    port (
        bus_maddr : in std_logic_vector(31 downto 0);
        bus_mdms : in std_logic_vector (31 downto 0);
        bus_mtwidth : in std_logic_vector (2 downto 0);
        bus_mtms : in std_logic;
        bus_sact : in std_logic_vector (num_slaves - 1 downto 0);
        bus_sdsm : in word_array(num_slaves - 1 downto 0);
        bus_mdsm : out std_logic_vector (31 downto 0);
        bus_saddr : out std_logic_vector (31 downto 0);
        bus_sdms : out std_logic_vector (31 downto 0);
        bus_stwidth : out std_logic_vector (2 downto 0);
        bus_stms : out std_logic
    );
end entity;

architecture arch of crossbar is
begin
    -- Señales controladas por el maestro
    bus_saddr <= bus_maddr;
    bus_sdms  <= bus_mdms;
    bus_stwidth <= bus_mtwidth;
    bus_stms <= bus_mtms;

    -- Mux
    dsm_mux : process (all)
        variable mux_out : std_logic_vector(31 downto 0);
    begin
        mux_out := 32x"0";
        for i in num_slaves - 1 downto 0 loop
            if bus_sact(i) then
                mux_out := mux_out or bus_sdsm(i);
            end if;
        end loop;
        bus_mdsm <= mux_out;
    end process;

end arch ; -- arch