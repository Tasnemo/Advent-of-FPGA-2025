sum = 0

with open("input.txt") as f:
    for line in f:
        d = line[0]
        n = int(line[1:])

        if d == "R":
            sum += n
        else:
            sum -= n

res = sum % 60
