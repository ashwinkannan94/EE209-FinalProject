import numpy as np


def measure(theta, L, W):

	# Define walls:
	#             2 (top)
	#         ----------------
	#         |              |
	#         |              |
	# 3(left) |              | 1 (right)
	#         |              |
	#         |              |
	#         |              |
	#         ----------------
	#            4 (bottom)

	# Calculate the right rangefinder results for each wall
	df1 = (W/2) / np.cos(theta)
	df2 = (L/2) / np.cos(theta - np.pi / 2.0)
	df3 = (W/2) / np.cos(theta - np.pi)
	df4 = (L/2) / np.cos(theta - np.pi * 3.0 / 2.0)

	df = [df1, df2, df3, df4]
	min_pos_df = float("inf")
	front_wall_idx = None

	# The wall the front rangefinder should read is the smallest positive number of the above values
	for i in np.arange(len(df)):
		if df[i] > 0 and df[i] < min_pos_df:
			min_pos_df = df[i]
			front_wall_idx = i + 1

	return front_wall_idx, min_pos_df