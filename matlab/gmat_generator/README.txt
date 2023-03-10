Autogenerate GMAT scripts from TLE or GPS measurements
------------------------------------------------------
Hannu Leppinen, August 2015

NASA GMAT is an open-source mission analysis tool. It is especially useful for
orbit propagation.

The scripts in this folder can be used to generate GMAT scripts from:
- TLE: "generate_gmat_scenario_from_tle.m"
- GPS measurements: "generate_gmat_scenario_from_gps.m"

The GMAT script is generated using a template.


Folder structure
----------------

- lib: contains I/O and conversion functions. Also some unit tests.
- lib/sgp4: contains SGP routines by David Vallado et al.
- lib/keplerstm: contains keplerSTM function by Dmitry Savransky
- output: contains the autogenerated GMAT scripts.
- input: GPS input should be placed here. Contains also some test inputs.
- template: Contains GMAT script templates.


Downloads
---------

GMAT R2014a can be obtained from:
http://sourceforge.net/projects/gmat/files/GMAT/GMAT-R2014a/

Matlab R2015a can be obtained from download.aalto.fi with Aalto account.
https://download.aalto.fi/student/
