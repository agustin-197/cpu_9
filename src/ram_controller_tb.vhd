library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.all;

entity ram_controller_tb is
end ram_controller_tb;

architecture tb of ram_controller_tb is
    constant periodo : time := 10 ns;
    constant archivo_init : string := "../src/ram_controller_tb_init.txt";
    constant ram_addr_nbits : integer := 9;
    constant ram_base : std_logic_vector (31 downto 0) := 32x"abc12000";
    signal clk        : std_logic;
    signal bus_addr   : std_logic_vector (31 downto 0);
    signal bus_dms    : std_logic_vector (31 downto 0);
    signal bus_twidth : std_logic_vector (2 downto 0);
    signal bus_tms    : std_logic;
    signal bus_dsm    : std_logic_vector (31 downto 0);
    signal bus_sact   : std_logic;
    signal ram_we     : std_logic;
    signal ram_mask   : std_logic_vector (3 downto 0);
    signal ram_addr   : std_logic_vector (ram_addr_nbits - 1 downto 0);
    signal ram_din    : std_logic_vector (31 downto 0);
    signal ram_dout   : std_logic_vector (31 downto 0);
begin
    U_RAM_CONTROLLER : entity ram_controller generic map(
        ram_addr_nbits => ram_addr_nbits,
        ram_base => ram_base
    )port map(
        clk => clk,
        bus_addr => bus_addr,
        bus_dms => bus_dms,
        bus_twidth => bus_twidth,
        bus_tms => bus_tms,
        bus_dsm => bus_dsm,
        bus_sact => bus_sact,
        ram_we => ram_we,
        ram_mask => ram_mask,
        ram_addr => ram_addr,
        ram_din => ram_din,
        ram_dout => ram_dout
    );

    U_RAM : entity ram512x32 generic map (
        archivo_init => archivo_init 
    ) port map (
        clk => clk,
        we => ram_we,
        mask => ram_mask,
        addr => ram_addr,
        din => ram_din,
        dout => ram_dout
    );

    PROC_RELOJ : process
    begin
        clk <= '0';
        wait for periodo/2;
        clk <= '1';
        wait for periodo/2;
    end process;

    PROC_TEST : process
    begin
        -- Lee dirección no controlada por el ram_controller
        bus_addr <= 32x"0";
        bus_dms <= 32x"0";
        bus_twidth <= "010";
        bus_tms <= '0';
        wait until rising_edge(clk);
        wait for periodo/4;
        assert bus_sact = '0';
        -- Lee palabra en dirección 0 de la ram (valor inicial)
        bus_addr <= ram_base;
        wait for periodo;
        assert bus_sact = '1';
        assert bus_dsm = 32x"1";
        -- Escribe byte 2 de la ram
        bus_addr(1 downto 0) <= 2x"2";
        bus_dms <= 32x"23456789";
        bus_twidth <= "000";
        bus_tms <= '1';
        wait for periodo;
        assert bus_sact = '1';
        -- Lee palabra 0 de la ram (byte 2 modificado)
        bus_tms <= '0';
        bus_dms <= 32x"0";
        bus_twidth <= "010";
        bus_addr(1 downto 0) <= 2x"0";
        wait for periodo; 
        assert bus_sact = '1';
        assert bus_dsm = 32x"00890001";
        -- Lee byte 2 de la ram con signo 
        bus_addr(1 downto 0) <= 2x"2";
        bus_twidth <= "000";
        wait for periodo;
        assert bus_sact = '1';
        assert bus_dsm = 32x"ffffff89";
        -- lee byte 2 de la ram sin signo
        bus_twidth <= "100";
        wait for periodo;
        assert bus_sact = '1';
        assert bus_dsm = 32x"00000089";
        -- escribe half 4 de la ram
        bus_addr(2 downto 0) <= 3x"4";
        bus_twidth <= "001";
        bus_tms <= '1';
        bus_dms <= 32x"555589AB";
        wait for periodo;
        assert bus_sact = '1';
        -- lee palabra 4 de la ram
        bus_tms <= '0';
        bus_twidth <= "010";
        wait for periodo;
        assert bus_sact = '1';
        assert bus_dsm = 32x"000089AB";
        -- lee media palabra 4 con signo
        bus_twidth <= "001";
        wait for periodo;
        assert bus_sact = '1';
        assert bus_dsm = 32x"ffff89AB";
        -- lee media palabra 4 sin signo
        bus_twidth <= "101";
        wait for periodo;
        assert bus_sact = '1';
        assert bus_dsm = 32x"000089AB";
        wait for periodo;
        finish;
    end process;
end tb ; -- tb