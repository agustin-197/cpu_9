library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.tipos.all;

entity top is
    
    generic(
        FIRMWARE_FILE : string := "../src/cpu_prog.txt"
           );
    port (
        clk         :in std_logic;
        nreset_in   :in std_logic;
        A           :in std_logic_vector(7 downto 0); -- Interruptores
        y           :out std_logic_vector(7 downto 0) -- Salida a LEDs del Display
        );
end top;

architecture arch of top is

    --señal de reset
    signal sys_nreset : std_logic;

    --señales del bus maestro (salidas de la cpu)
    signal m_addr     : std_logic_vector(31 downto 0);
    signal m_dms      : std_logic_vector(31 downto 0); 
    signal m_dsm      : std_logic_vector(31 downto 0); 
    signal m_twidth   : std_logic_vector(2 downto 0);
    signal m_tms      : std_logic;

    --señales del lado esclavo del crossbar
    signal s_addr_bus : std_logic_vector(31 downto 0);
    signal s_dms_bus  : std_logic_vector(31 downto 0);
    signal s_twidth   : std_logic_vector(2 downto 0);
    signal s_tms      : std_logic;

    -- señales de retorno de los esclavos al crossbar
    constant NUM_SLAVES : positive := 2;
    signal slaves_sact  : std_logic_vector(NUM_SLAVES - 1 downto 0);
    signal slaves_dsm   : word_array(NUM_SLAVES - 1 downto 0);
   
    -- señales del controlador de RAM
    signal ram_ctrl_dsm  : std_logic_vector(31 downto 0);
    signal ram_ctrl_sact : std_logic;
   
    -- señales físicas de la memoria RAM
    signal phys_ram_we   : std_logic;
    signal phys_ram_mask : std_logic_vector(3 downto 0);
    signal phys_ram_addr : std_logic_vector(8 downto 0); 
    signal phys_ram_din  : std_logic_vector(31 downto 0);
    signal phys_ram_dout : std_logic_vector(31 downto 0);

    -- señales internas para el periferico de salida
    signal out_dout      : std_logic_vector(31 downto 0);
    signal out_sact      : std_logic;
    
    begin

    -- conectar la salida del periferico a los LEDs.
    y <= out_dout(7 downto 0);


    u_reset : entity work.reset_al_inicializar_fpga
    port map (
        clk        => clk,
        nreset_in  => A(7),
        nreset_out => sys_nreset
    );

    u_cpu : entity work.cpu
    port map (
        clk        => clk,
        nreset     => sys_nreset,

        bus_addr   => m_addr,
        bus_dms    => m_dms,    
        bus_dsm    => m_dsm,    
        bus_twidth => m_twidth,
        bus_tms    => m_tms     
    );

    u_crossbar : entity work.crossbar
    generic map (
        num_slaves => NUM_SLAVES
    )
    port map (
        -- Lado Maestro
        bus_maddr   => m_addr,
        bus_mdms    => m_dms,
        bus_mtwidth => m_twidth,
        bus_mtms    => m_tms,
        bus_mdsm    => m_dsm, 
        -- Lado Esclavo
        bus_saddr   => s_addr_bus, 
        bus_sdms    => s_dms_bus,  
        bus_stwidth => s_twidth,
        bus_stms    => s_tms,
        -- Entradas desde los esclavos
        bus_sact    => slaves_sact,
        bus_sdsm    => slaves_dsm
    );

        -- mapeo de respuestas de los esclavos hacia el crossbar
        --esclavo 0: controlador de ram
        slaves_sact(0) <= ram_ctrl_sact;
        slaves_dsm(0)  <= ram_ctrl_dsm;

        --esclavo 1: periferico de salida
        slaves_sact(1) <= out_sact;
        slaves_dsm(1)  <= (others => '0');

    u_ram_ctrl : entity work.ram_controller
    generic map (
        ram_addr_nbits => 9,          
        ram_base       => x"00000000" 
    )
    port map (
        clk        => clk,
        -- Bus del sistema
        bus_addr   => s_addr_bus,
        bus_dms    => s_dms_bus,
        bus_twidth => s_twidth,
        bus_tms    => s_tms,
        
        -- Respuestas al bus
        bus_dsm    => ram_ctrl_dsm,
        bus_sact   => ram_ctrl_sact,

        -- Interfaz física hacia la RAM
        ram_we     => phys_ram_we,
        ram_mask   => phys_ram_mask,
        ram_addr   => phys_ram_addr,
        ram_din    => phys_ram_din,
        ram_dout   => phys_ram_dout
    );
            

    u_ram : entity work.ram512x32
    generic map (
        archivo_init => FIRMWARE_FILE
    )
    port map (
        clk  => clk,
        we   => phys_ram_we,
        mask => phys_ram_mask,
        addr => phys_ram_addr,
        din  => phys_ram_din,
        dout => phys_ram_dout
    );

    u_interface_out : entity work.interface_out
    port map(
        clk      => clk,
        nreset   => sys_nreset,
        
        bus_addr => s_addr_bus,
        bus_dms  => s_dms_bus,
        bus_tms  => s_tms,
        
        dout     => out_dout,
        escribir => open,
        bus_sact => out_sact

    );


end arch; 

