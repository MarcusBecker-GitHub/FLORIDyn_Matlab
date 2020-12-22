# FLORIDyn

In this work the FLORIDyn model has been impemented. The model allows to dynamically simulate FLORIS wakes 
It is built to run under heterogeneous conditions (changing wind speed, direction, ambient turbulence intensity over time and space) and includes wake interaction effects and an added turbulence model. The code includes various layouts and conditions as well as guiding comments to create custom simulation cases.
The high-fidelity simulation SOWFA was used to validate the code. In the current version it is possible to compare generated power outputs, to copy yaw behaviour of the SOWFA simulation and to copy control behaviour (greedy control or based on the tip-speed-ratio and the blade-pitch-angle). Relevant instructions are given in the code.

## How to get started
The script main.m contains a framework to run a FLORIDyn - standalone simulation. It prepares the necessary variables and settings and calls the function FLORIDyn.m .

## Scientific basis
The underlying FLORIS model is based on the gaussian wake model by Bastankhah and Porte-Agel [1], the dynamic transformation is inspired by the FLORIDyn model by Gebraad and Wingerden [2]. Concepts to include heterogeneous conditions for the FLORIS model have been inspired by Farrell et al. [3].

## Pictures and animations
Selection of visualizations, more can be found in the folder "Pictures".

### Nine turbine case with 60 degree wind direction change
In this case only Observation Points a bit above and below hub height were plotted to visualize the wind speed at hub height.
![NineTurbineCase](https://github.com/MarcusBecker-GitHub/FLORIDyn_Matlab/blob/main/Pictures/Animations/9T.gif)

### Three turbine case flow field
Flow field at hub height merged as one surface.
![3TFlowField](https://github.com/MarcusBecker-GitHub/FLORIDyn_Matlab/blob/main/Pictures/FlowField/ThreeT_00_FlowField_horizontal_newI.png)

### Three turbine case generated power
Generated power of the FLORIDyn simulation next to the (turbulent) SOWFA simulation. Greedy control and no yaw angle.
![3TGeneratedPower](https://github.com/MarcusBecker-GitHub/FLORIDyn_Matlab/blob/main/Pictures/GeneratedPower/3T_00_greedy.png)

### Computational Performance
Seconds per time step, dependent on the number of Observation Points and turbines on a log scale. Numbers were measured in Matlab 2020a, a 2.3 GHz 8-Core Intel i9 CPU, 32
GB of 2667 MHz DDR4 RAM. (No use of Matlab toolboxes)
![CompPerformance](https://github.com/MarcusBecker-GitHub/FLORIDyn_Matlab/blob/main/Pictures/Performance/Performance_NumOPPerTurbine_log.png)


## Goals for the future
The goal is to intigrate the developed model into an Ensemble Kalman Filter design and couple it with SOWFA. This should deliver a robust state estimation and will allow a Model Predictive Design approach, which will be the next goal.
It is also the goal to implement the model in Julia for performance reeasons and to become independent from the Matlab platform. This will likely be published as a new branch.

## Sources
[1] Bastankhah, Majid, and Fernando Porté-Agel. “Experimental and Theoretical Study of Wind Turbine Wakes in Yawed Conditions.” Journal of Fluid Mechanics 806 (November 10, 2016): 506–41. https://doi.org/10.1017/jfm.2016.595.

[2] Gebraad, Pieter M. O., and J. W. van Wingerden. “A Control-Oriented Dynamic Model for Wakes in Wind Plants.” Journal of Physics: Conference Series 524 (June 2014): 012186. https://doi.org/10.1088/1742-6596/524/1/012186.

[3] Farrell, Alayna, Jennifer King, Caroline Draxl, Rafael Mudafort, Nicholas Hamilton, Christopher J Bay, Paul Fleming, and Eric Simley. “Design and Analysis of a Spatially Heterogeneous Wake.” Wind Energy Science, 2020, 25. https://doi.org/10.5194/wes-2020-57.



## Context and contact
This implementation was part of the master thesis of Marcus Becker, TU Darmstadt & TU Delft, Dez.2020
The thesis is avaiable upon request. The findings of this work will be pubished in the near future.

Contact:
Marcus Becker, marcus.becker@tudelft.nl
