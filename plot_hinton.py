import numpy as np
import matplotlib.pyplot as plt
import csv

def hinton(matrix, max_weight=None, ax=None):
    """Draw Hinton diagram for visualizing a weight matrix."""
    ax = ax if ax is not None else plt.gca()

    if not max_weight:
        max_weight = 2**np.ceil(np.log(np.abs(matrix).max())/np.log(2))

    ax.patch.set_facecolor('gray')
    ax.set_aspect('equal', 'box')
    ax.xaxis.set_major_locator(plt.NullLocator())
    ax.yaxis.set_major_locator(plt.NullLocator())

    for (x, y), w in np.ndenumerate(matrix):
        color = 'white' if w > 0 else 'black'
        size = np.sqrt(np.abs(w))
        rect = plt.Rectangle([x - size / 2, y - size / 2], size, size,
                             facecolor=color, edgecolor=color)
        ax.add_patch(rect)

    ax.autoscale_view()
    ax.invert_yaxis()


if __name__ == '__main__':
    file_list = ['transcription1@2015.11.29-17.51.00.612202.last.save_weightContainer_hidden_0_0_to_output_collapse_weights',
                 'transcription1@2015.11.29-17.51.00.612202.last.save_weightContainer_hidden_0_0_to_hidden_0_0_delay_0_-1_0_weights',
                 'transcription1@2015.11.29-17.51.00.612202.last.save_weightContainer_hidden_0_0_to_hidden_0_0_delay_-1_0_0_weights',
                 'transcription1@2015.11.29-17.51.00.612202.last.save_weightContainer_hidden_0_0_to_hidden_0_0_delay_0_0_-1_weights',
                 'transcription1@2015.11.29-17.51.00.612202.last.save_weightContainer_bias_to_output_weights',
                 'transcription1@2015.11.29-17.51.00.612202.last.save_weightContainer_bias_to_hidden_0_0_weights']
    for file in file_list:
        with open(file, 'r') as csvfile:
            line = csvfile.readline()
            line = line.rstrip()
            line = line.split(' ')
            x = int(line[1])
            y = int(line[2])
            arr = [[0 for duh in range(x)] for duh in range(y)]
            line = csvfile.readline()
            line = line.split(' ')
            line = map(float, line)
            i = 0
            for index in range(y):
                for index2 in range(x):
                    arr[index][index2] = line[i]
                    i = i+1

            print arr
            hinton(arr)
            plt.title(file)
            plt.show()

