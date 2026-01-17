.PHONY: build test hdl clean

build:
	dune build

test:
	dune runtest

hdl:
	dune exec bin/generate.exe -- -output-rtl verilog

clean:
	dune clean
