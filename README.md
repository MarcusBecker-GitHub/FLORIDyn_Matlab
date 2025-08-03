
# FLORIDyn versions
There are *multiple* versions of FLORIDyn described in the literature. The table below lists those developed in collaboration with / at TU Delft. The table further gives an indication of what is implemented, which papers describe the model, and what can be expected in terms of computational speed.

**The version in this repository is not under further development!**
We recommend the use of another FLORIDyn implementation.
Basic bug fixes and help will still be provided.

## Overview
| Name | Repository | Model Paper | FLORIDyn | Wake model | EnKF | Optimization | Active development | Authors | Comp. speed | Language |
|---|---|---|---|---|---|---|---|---|---|---|
| FLORIDyn 3.0 | [Repo](https://github.com/TUDelft-DataDrivenControl/FLORIDyn_Matlab) | [Link](https://iopscience.iop.org/article/10.1088/1742-6596/2265/3/032103) | 3D, centerline | Gaussian | ✅ | ✅ | ✅ | M.Becker | + | Matlab |
| FLORIDyn 2.0 | [This repo](https://github.com/MarcusBecker-GitHub/FLORIDyn_Matlab) | [Link](https://wes.copernicus.org/articles/7/2163/2022/wes-7-2163-2022.html) | 3D, multichain | Gaussian | ❌ | ❌ | ❌ | M.Becker | - | Matlab |
| FLORIDyn 1.0 | ❌ | [Link](https://iopscience.iop.org/article/10.1088/1742-6596/524/1/012186) | 2D, multichain | Zone FLORIS | ❌ | ❌ | ❌ | P.M.O. Gebraad | ❌ | ❌ |
| OFF | [Link](https://github.com/TUDelft-DataDrivenControl/OFF) | [Link](https://wes.copernicus.org/articles/10/1055/2025/) | 3D, centerline | [FLORIS](https://github.com/NREL/floris) | ❌ | ❌ | ❌ | M.Becker, M. Lejeune | 0 | Python |
| FLORIDyn.jl | [Link](https://github.com/ufechner7/FLORIDyn.jl) | [Link](https://iopscience.iop.org/article/10.1088/1742-6596/2265/3/032103) | 3D, centerline | Gaussian | ❌ | in progress | ✅ | U.Fechner | ++ | Julia |

# FLORIDyn 2.0

The Flow redirection and induction dynamics model allows for the dynamic simulation of FLORIS wakes under heterogeneous conditions. Such conditions are changing wind speeds, directions, and ambient turbulence intensity over time and space. The model also includes wake interaction effects and an added turbulence model. The code includes various layouts and conditions as well as guiding comments to create custom simulation cases.
The high-fidelity simulation SOWFA was used to validate the code. In the current version, it is possible to compare generated power outputs, to copy yaw behaviour of the SOWFA simulation, and to copy control behaviour (greedy control or based on the tip-speed-ratio and the blade-pitch-angle). Relevant instructions are given in the code.

## Paper and citation
The paper about this model is currently in discussion in Wind Energy Science and can be accessed here: https://wes.copernicus.org/preprints/wes-2021-154/
If the Gaussian FLORIDyn model is playing or played a role in your research, consider citing the work:

> Becker, M., Ritter, B., Doekemeijer, B., van der Hoek, D., Konigorski, U., Allaerts, D., and van Wingerden, J.-W.: The revised FLORIDyn model: Implementation of heterogeneous flow and the Gaussian wake, Wind Energ. Sci. Discuss. [preprint], https://doi.org/10.5194/wes-2021-154, in review, 2022. 

## How to get started
There are two ways you can run the code: either from the FLORIDyn App or by running one of the main scripts. To use the app, open FLORIDyn_App.mlapp. If you open it from the explorer, only the App window should open. Use the "Preview" button to see where the turbines are, what the wind direction is, and what the wind shear profile is. Upon clicking "run" the simulation will be carried out and will plot the generated power and also the flow field (if activated). 
If you open FLORIDyn_App.mlapp from MATLAB, you have access to the app code and can modify it.
For more choice, use the script main.m, which contains a framework to run a FLORIDyn - standalone simulation. It prepares the necessary variables and settings and calls the function FLORIDyn.m . If you have SOWFA data available or want to run a simulation based on SOWFA data in this repository, use mainSOWFA.m . The script mentions the necessary files and includes the generated power in SOWFA in the power plot.

## Scientific basis
The underlying FLORIS model is based on the Gaussian wake model by Bastankhah and Porte-Agel [1], and the dynamic transformation is inspired by the FLORIDyn model by Gebraad and Wingerden [2]. Concepts to include heterogeneous conditions for the FLORIS model have been inspired by Farrell et al. [3].

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

### App Screenshot
Current version of the FLORIDyn App. It is meant to provide an easy start and idea of the simulation. The data storage option is not implemented yet. On the top right you can see the preview of the layout and the wind direction (red arrow) and the wind shear. Below you can set the simulation duration and if the flow field should be plotted. On the top left environmental variables can be changed: Wind speed, direction, the ambient turbulence intensity and the wind shear coefficient. Below you can choose from predefined turbine layout options. Pressing the RUN button will start the Simulation. If you have MATLAB open you should be able to follow the progress in the console. After the run the generated power will be displayed in the figure below the run button. The flow field will be generated in a separate figure which will also not be overwritten by following simulations.
![FLORIDynApp](https://github.com/MarcusBecker-GitHub/FLORIDyn_Matlab/blob/main/Pictures/AppScreenshot.PNG)

## Goals for the future
The goal is to integrate the developed model into an Ensemble Kalman Filter design and couple it with SOWFA. This should deliver a robust state estimation and will allow a Model Predictive Design approach, which will be the next goal.
It is also the goal to implement the model in Julia for performance reasons and to become independent from the Matlab platform. This will likely be published as a new branch.

## Sources
[1] Bastankhah, Majid, and Fernando Porté-Agel. “Experimental and Theoretical Study of Wind Turbine Wakes in Yawed Conditions.” Journal of Fluid Mechanics 806 (November 10, 2016): 506–41. https://doi.org/10.1017/jfm.2016.595.

[2] Gebraad, Pieter M. O., and J. W. van Wingerden. “A Control-Oriented Dynamic Model for Wakes in Wind Plants.” Journal of Physics: Conference Series 524 (June 2014): 012186. https://doi.org/10.1088/1742-6596/524/1/012186.

[3] Farrell, Alayna, Jennifer King, Caroline Draxl, Rafael Mudafort, Nicholas Hamilton, Christopher J Bay, Paul Fleming, and Eric Simley. “Design and Analysis of a Spatially Heterogeneous Wake.” Wind Energy Science, 2020, 25. https://doi.org/10.5194/wes-2020-57.

## Contact:
Marcus Becker, marcus.becker@tudelft.nl
