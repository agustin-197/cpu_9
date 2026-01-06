library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.all;
use work.tipos.all;

entity crossbar_tb is
end crossbar_tb ;

architecture tb of crossbar_tb is
    constant periodo : time := 10 ns;
    constant num_slaves : positive := 4;
    signal bus_maddr : std_logic_vector(31 downto 0);
    signal bus_mdms : std_logic_vector (31 downto 0);
    signal bus_mtwidth : std_logic_vector (2 downto 0);
    signal bus_mtms : std_logic;
    signal bus_sdsm : word_array (num_slaves-1 downto 0);
    signal bus_sact : std_logic_vector (num_slaves-1 downto 0);
    signal bus_saddr : std_logic_vector (31 downto 0);
    signal bus_sdms : std_logic_vector (31 downto 0);
    signal bus_stwidth : std_logic_vector (2 downto 0);
    signal bus_stms : std_logic;
    signal bus_mdsm : std_logic_vector (31 downto 0);
begin
    U_CROSSBAR : entity crossbar generic map (
        num_slaves => num_slaves
    ) port map (
        bus_maddr => bus_maddr,
        bus_mdms => bus_mdms,
        bus_mtwidth => bus_mtwidth,
        bus_mtms => bus_mtms,
        bus_sdsm => bus_sdsm,
        bus_sact => bus_sact,
        bus_saddr => bus_saddr,
        bus_sdms => bus_sdms,
        bus_stwidth => bus_stwidth,
        bus_stms => bus_stms,
        bus_mdsm => bus_mdsm
    );

    estimulo : process
    begin
        bus_maddr <= 32x"0";
        bus_mdms <= 32x"0";
        bus_mtwidth <= "000";
        bus_mtms <= '0';
        for i in 0 to num_slaves - 1 loop
            bus_maddr <= std_logic_vector(to_unsigned(i,32));
            wait for periodo;
            assert unsigned(bus_sact) =  2 ** i
                report "bus_sact distinto al esperado"
                severity error;
            assert unsigned(bus_mdsm) = i
                report "bus_mdsm distinto al esperado"
                severity error;
        end loop;
        wait for periodo;
        finish;
    end process;

    logica_sel : for i in num_slaves - 1 downto 0 generate
        bus_sdsm(i) <= std_logic_vector(to_unsigned(i,32));
        bus_sact(i) <= bus_saddr ?= bus_sdsm(i);
    end generate;

end architecture ; -- tb