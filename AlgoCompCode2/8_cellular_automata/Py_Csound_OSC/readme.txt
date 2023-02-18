Csound and Python scripts for cellular automata.
Øyvind Brandtsegg - 2022, obrandts@gmail.com

The files ca.py and osc_io.py are just modules used by the other scripts. They are not intended to be run as main, even if no harm will come from doing so.

Intended usage:

Csound will run the timing and audio synthesis, while Python provides the data for each event generated. Csound and Python communicates via Open Sound Control. To run, open two terminal windows (yes, two).
In the first one, run
python osc_ca.py
In the second one, run
csound osc_ca.csd

The first process now runs a Python OSC server waiting for calls from Csound, asking for the data for the next event. When data is returned from Python, Csound will generate the event. The delta time until the next event is part of the event data, so Csound will then wait until it is time to ask Python for the next event data.

This also makes it possible to run the same Csound orchestra with different versions of the Python server (providing different data mapping for example).
You can try:
In the first terminal, run
python osc_ca_interval.py
In the second one, (as above) run
csound osc_ca.csd

Even if it is possible to combine Csound and Python processes rather freely (as the data interface is compatible), I have made some variations that are intended to be used together. For example the 3voice version of the Csound script is intended to be used with the 3voice version of the Python script, as in this case Python will correctly keep data generation separate for events in each voice (rather than just bleeding things over between voices).
