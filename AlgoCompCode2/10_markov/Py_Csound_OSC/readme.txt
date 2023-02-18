Csound and Python scripts for a markov melody generator.
Øyvind Brandtsegg - 2022, obrandts@gmail.com

The files markov_melody.py and osc_io.py are just modules used by the other scripts. They are not intended to be run as main, even if no harm will come from doing so.

Intended usage:

Csound will run the timing and audio synthesis, while Python provides the data for each event generated. Csound and Python communicates via Open Sound Control. To run, open two terminal windows (yes, two).
In the first one, run
python osc_markov.py
In the second one, run
csound osc_markov.csd

The first process now runs a Python OSC server waiting for calls from Csound, asking for the data for the next event. When data is returned from Python, Csound will generate the event. The delta time until the next event is part of the event data, so Csound will then wait until it is time to ask Python for the next event data.

The VST:
The file osc_markov_vst.csd can be wrapped as a VST in Cabbage, and then loaded in a DAW.
You then need to run the python file in a terminal window, like this:
python osc_markov_vst.py
