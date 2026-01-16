library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rom_pkg.all; -- Optional if needed for constants, but solver handles it

entity tb_fpga is
end tb_fpga;

architecture sim of tb_fpga is

    signal clk   : std_logic := '0';
    signal btnC  : std_logic := '0'; -- Reset
    signal btnU  : std_logic := '0'; -- Start
    signal led   : std_logic_vector(15 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate Top Level
    u_fpga : entity work.fpga
    port map (
        clk  => clk,
        btnC => btnC,
        btnU => btnU,
        led  => led
    );

    -- Clock Process
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- Hold Reset
        btnC <= '1';
        wait for 100 ns;
        btnC <= '0';
        wait for 100 ns;
        
        -- Start
        btnU <= '1';
        wait for 20 ns; -- Pulse start
        btnU <= '0';
        
        -- Wait for completion
        -- We don't have a 'done' signal out of fpga entity to monitor directly in this simple TB,
        -- but we can watch LED or just wait long enough.
        -- ROM depth is ~4000. 1 cycle per step. 4000 * 10ns = 40us.
        -- Let's wait 1 ms to be safe.
        wait for 1 ms;
        
        report "Simulation Finished. Check LED value.";
        
        -- Expected LED value (for Part 1 based on previous runs): 969
        -- 969 in hex is 0x3C9. 
        -- Binary: 0000 0011 1100 1001
        
        wait;
    end process;

end sim;
