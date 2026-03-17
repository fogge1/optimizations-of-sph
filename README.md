# sph-python
Optimizations of Smoothed-Particle Hydrodynamics simulation of Toy Star by

## Profiling

Profiling of the baseline `sph.py` is done in the `profiling.ipynb´ jupyter notebook. Profiling is done with cProfile, line profiler and memory profiler.

## Benchmarks

Benchmarks of the baseline and optimizations are done in the `benchmarks.ipynb`. To benchmark and compare the optimizations we measure the runtime with different number of particles, then plot the results.

### Philip Mocz (2020) Princeton University, [@PMocz](https://twitter.com/PMocz)

### [📝 Read the Algorithm Write-up on Medium](https://philip-mocz.medium.com/create-your-own-smoothed-particle-hydrodynamics-simulation-with-python-76e1cec505f1)

Simulate a toy star with SPH

Running the baseline:
```
python sph.py
```
