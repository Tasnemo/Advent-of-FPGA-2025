instructions = []
with open("input.txt") as f:
    for line in f:
        if line.strip():
            instructions.append((line[0], int(line[1:])))

pos = 50
part1 = 0
part2 = 0

for d, n in instructions:
    old = pos

    if d == 'R':
        pos += n
        part2 += pos // 100 - old // 100
    else:
        pos -= n
        part2 += (old - 1) // 100 - (pos - 1) // 100

    if pos % 100 == 0:
        part1 += 1

print(part1)
print(part2)

