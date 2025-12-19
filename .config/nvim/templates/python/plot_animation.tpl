;; python
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from matplotlib.animation import ArtistAnimation

x = np.linspace(-10, 10, 400)
fig, ax = plt.subplots()

def update(frame):
    ax.clear()
    y = {{_cursor_}}
    im = ax.plot(x, y)
    return im

ani = FuncAnimation(fig, update, interval=100)
# frames = []
# for i in range(100):
#     y = 
#     line, = ax.plot(x, y)
#     frames.append([line])
# ani = ArtistAnimation(fig, frames, interval=100)


plt.grid(True)
plt.show()
