# -*- coding: utf-8 -*-
"""
Created on Tue Jun 05 23:46:48 2018

@author: Jesse
"""

import serial
import matplotlib.pyplot as plt
from scipy import signal
import numpy as np

def show_plot(figure_id=None):    
    if figure_id is None:
        fig = plt.gcf()
    else:
        # do this even if figure_id == 0
        fig = plt.figure(num=figure_id)

    plt.show()
    plt.pause(1e-9)
    fig.canvas.manager.window.activateWindow()
    fig.canvas.manager.window.raise_()

pos = []
time = []

ser = serial.Serial('COM5', 115200)
while (not time) or (time[-1] < 50000):
    data = ser.readline().decode('utf-8').split(" ")
    if len(data) >= 2:
        pos.append(int(data[0]))
        time.append(int(data[1]))

ser.close()

pos = np.divide(pos,1320.)
time = np.divide(time,10000.)

#vel = signal.savgol_filter(pos, 49, 6, deriv=1, delta = 0.001)
hann = np.hanning(40)
vel_raw = np.divide(np.diff(pos),map(float,np.diff(time)))
vel = signal.filtfilt(hann/sum(hann),1,vel_raw, method='gust')

fig = plt.figure(figsize = (20,15))
plt.subplot(211)
plt.plot(time,pos)

plt.subplot(212)
plt.plot(time[:-1],vel_raw)
plt.plot(fig)

