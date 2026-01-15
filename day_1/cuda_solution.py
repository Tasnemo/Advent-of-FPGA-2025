from numba import cuda, int32
import numpy as np
import math

block_size = 16


@cuda.jit
def blelloch_scan_local(data, block_sums, positions):
    temp = cuda.shared.array(block_size, dtype=int32)

    tid = cuda.threadIdx.x
    gid = cuda.grid(1)

    if gid < data.size:
        temp[tid] = data[gid]
    else:
        temp[tid] = 0
    cuda.syncthreads()

    # up-sweep
    offset = 1
    d = block_size >> 1
    while d > 0:
        cuda.syncthreads()
        if tid < d:
            a = offset * (2 * tid + 1) - 1
            b = offset * (2 * tid + 2) - 1
            temp[b] += temp[a]
        offset <<= 1
        d >>= 1

    # store block sum
    if tid == 0:
        block_sums[cuda.blockIdx.x] = temp[block_size - 1]
        temp[block_size - 1] = 0
    cuda.syncthreads()

    # down-sweep
    d = 1
    offset = block_size
    while offset > 1:
        offset >>= 1
        cuda.syncthreads()
        if tid < d:
            a = offset * (2 * tid + 1) - 1
            b = offset * (2 * tid + 2) - 1
            t = temp[a]
            temp[a] = temp[b]
            temp[b] += t
        d <<= 1
    cuda.syncthreads()

    # exclusive -> inclusive
    if gid < positions.size:
        positions[gid] = temp[tid] + data[gid]


@cuda.jit
def add_block_sums_and_count(positions, block_offsets, res):
    gid = cuda.grid(1)
    bid = cuda.blockIdx.x

    if gid < positions.size:
        pos = positions[gid] + block_offsets[bid]
        positions[gid] = pos

        if (50 + pos) % 100 == 0:
            cuda.atomic.add(res, 0, 1)




with open("input.txt") as f:
    lines = f.readlines()

deltas_list = []
for line in lines:
    line = line.strip()
    if not line:
        continue
    d = line[0]
    val = int(line[1:])
    if d == "L":
        val = -val
    deltas_list.append(val)

n = len(deltas_list)
pad_n = math.ceil(n / block_size) * block_size

deltas = np.zeros(pad_n, dtype=np.int32)
deltas[:n] = deltas_list

d_data = cuda.to_device(deltas)
d_positions = cuda.device_array_like(d_data)

num_blocks = pad_n // block_size
d_block_sums = cuda.device_array(num_blocks, dtype=np.int32)

blelloch_scan_local[num_blocks, block_size](d_data, d_block_sums, d_positions)

block_sums = d_block_sums.copy_to_host()
block_offsets = np.zeros_like(block_sums)

cur = 0
for i in range(len(block_sums)):
    block_offsets[i] = cur
    cur += block_sums[i]

d_block_offsets = cuda.to_device(block_offsets)
d_res = cuda.to_device(np.zeros(1, dtype=np.int32))

add_block_sums_and_count[num_blocks, block_size](d_positions, d_block_offsets, d_res)

print(d_res.copy_to_host()[0])
