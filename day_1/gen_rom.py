# gen_rom.py
# Reads input.txt and generates rom_pkg.vhd

lines = open("input.txt").read().strip().splitlines()

vals = []
for line in lines:
    d = line[0]          # 'L' or 'R'
    n = int(line[1:])    # amount
    vals.append(n if d == "R" else -n)

out = open("rom_pkg.vhd", "w")

out.write("library ieee;\n")
out.write("use ieee.std_logic_1164.all;\n")
out.write("use ieee.numeric_std.all;\n\n")

out.write("package rom_pkg is\n")
out.write(f"  constant ROM_DEPTH : integer := {len(vals)};\n")
out.write("  type rom_t is array (0 to ROM_DEPTH-1) of signed(15 downto 0);\n\n")

out.write("  constant ROM : rom_t := (\n")
for i, v in enumerate(vals):
    comma = "," if i < len(vals) - 1 else ""
    out.write(f"    {i} => to_signed({v}, 16){comma}\n")
out.write("  );\n")

out.write("end package;\n")
out.close()
