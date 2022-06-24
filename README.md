# MATLAB Point Picker

This is a quick-and-dirty proof of concept GUI for picking points from plots in MATLAB.

It's designed around quickly picking points from a collection of CSV files in a folder, and was inspired by an issue faced by a researcher at UAB. They had a ton of signal data with "obvious" peaks. They're nearing the end of their work and didn't have time or data to figure out a deep learning approach to finding the peaks. So I wrote this as a quick solution to the problem.

The code is not particularly well encapsulated or refined. If I refined it I would...

- Modularize data sources, so it could run from files or from 2-column arrays in the workspace.
- Make features (markers, colors, sizes, etc) more customizable using a couple of "preferences" utilities I wrote for another project that aren't published separately yet.
- Make the window resizeable in a sensible way.
- Find a way to make column selection more flexible.
- Have both an auto-save mode, and a save-only-when-I-ask mode. Right now everything is auto-saved.

## Use

1. Click "Load Folder..."
    1. Pick a folder to load
    2. Select X and Y columns in the next dialog
    3. The software assumes ALL CSVs have the same columns, you only get to pick once per folder load!
2. The "Series <-> Scatter" toggle changes the displayed plot to a line series or a marker-only scatterplot.
3. Pick points
    1. Left click to pick a point and add a red "+" symbol there.
    2. Right click to unpick a point.
    3. All changes are saved to the CSV automatically in a new column "IS_PICKED__" whenever you pick or unpick a point.
4. Click Next or Previous to move to a different file.
5. Clear Data to clear all loaded data and start over, if needed.
6. Help shows help like this document.

A series plot with peaks picked.
![Series plot](/doc/series.png)

A scatter plot with two points picked.
![Scatter plot](/doc/scatter.png)

## Notes

Written with R2021b, may not work in older versions. MathWorks is frequently updating their App Designer stuff and I'm not able to track that for this project. Does NOT require any toolboxes. All of my own utilities are included in `lib`.
