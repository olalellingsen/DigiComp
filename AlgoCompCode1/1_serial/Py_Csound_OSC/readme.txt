Csound and Python scripts for serial composition
Øyvind Brandtsegg - 2022, obrandts@gmail.com

The file osc_io.py is just a module used by the other scripts. It is not intended to be run as main, even if no harm will come from doing so.

Intended usage:

Csound will run the timing and audio synthesis, while Python provides the data for each event generated. Csound and Python communicates via Open Sound Control. To run, open two terminal windows (yes, two).
In the first one, run
python serial_simplest.py
In the second one, run
csound serial_simplest.csd

The first process now runs a Python OSC server waiting for calls from Csound, asking for the data for the next event. When data is returned from Python, Csound will generate the event. The delta time until the next event is part of the event data, so Csound will then wait until it is time to ask Python for the next event data.

The scripts in this folder are intended to be used with the similarly named one for both Csound and Python. For example, the Csound script serial_composition.csd is intended to be run with the Python script serial_composition.py
The different scripts use a different number of data fields for an event, and this is the reason why they are not compatible.
