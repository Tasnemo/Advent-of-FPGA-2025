## Advent of FPGA 2025

This repo is me working through **Advent of FPGA 2025**, whichever ones come to me first.

I plan to solve the problem in multiple languages like **Python** to model, **VHDL** (my first RTL language), and **HardCaml** (Really just testing out what I'm doing)


I’m testing everything on a **Basys 3** that I borrowed from **NYU’s ECE department**.

I didn't expect how much time it would take me to understand hardcaml and I definitely have a lot of work to do this being my first month knowing RTL. I'll probably end up putting the rest of the days in this repository and making them much better.

## Solutions

### Day 1, Part 1

The design is just simple sequential addition and subtraction using a modulo state so that it could wrap around and count the amount of times the dial will hit zero.
The puzzle input is stored in a ROM generated using a Python script that pre-processed the Rs and Ls to be negative and positive so the input would essentially just be integers. (This preprocessing choice was sanity-checked over email beforehand.)

### Day 1, Part 2
Similar to part 1 but there is a counter that would iterate during the wrap arounds in a modulo state and whenever it would be zero.

### Day 1, Part 1 (v2)
I wasn't satisfied with sequentially figuring it out so I used a parallel prefix scan I learnt back when I did CUDA Python. I originally considered a Blelloch scan that I modeled in CUDA, but settled on a Hillis–Steele scan because it tends to work better on hardware. The single upsweep structure is simpler to map onto an FPGA, whereas Blelloch’s two-phase approach adds extra control that isn’t very helpful at this scale. Running the scan in blocks of 16 was optimal for the space on my Basys3 since batches of 32 can bring up risks and batches of 8 won't speed it up by much.


### Day 1, Part 1 (Hardcaml)

The design is also a simple sequential addition and subtraction that uses modulo logic to wrap around and find the amount of hits. This time I used a handshake-based streaming interface for input after some guidance over email and noticing it was a better fit for Hardcaml.


## How I organized it

I'll put the days and then have folders for each implementation that I make, sometimes there will be two of the same language if i felt that my first solution wasn't nice enough. I tried to follow the hardcaml template 
