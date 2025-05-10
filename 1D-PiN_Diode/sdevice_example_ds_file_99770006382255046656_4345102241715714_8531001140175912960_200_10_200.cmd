File {
* Input Files
Grid      = "/home/012738063/ML/SISPAD_6_29_2019_doping/NewTest/SISPAD_Files/device_99770006382255046656_4345102241715714_8531001140175912960_200_10_200_fps.tdr"
* Output Files
Current = "/home/012738063/ML/SISPAD_6_29_2019_doping/NewTest/SISPAD_Files/nmos_99770006382255046656_4345102241715714_8531001140175912960_200_10_200"
Plot    = "/home/012738063/ML/SISPAD_6_29_2019_doping/NewTest/SISPAD_Files/nmos_99770006382255046656_4345102241715714_8531001140175912960_200_10_200"
Output  = "/home/012738063/ML/SISPAD_6_29_2019_doping/NewTest/SISPAD_Files/nmos_99770006382255046656_4345102241715714_8531001140175912960_200_10_200"
}
Electrode {
{ Name="cathode"        Voltage=0.0 }
{ Name="Anode"          Voltage=0.0 }
}
Physics {
Fermi
EffectiveIntrinsicDensity( OldSlotboom )  
Mobility(
DopingDep
eHighFieldsaturation( GradQuasiFermi )
hHighFieldsaturation( GradQuasiFermi )
)
Recombination(
SRH( DopingDep TempDependence )
Band2Band(model = NonlocalPath)
)
DefaultParametersFromFile
}
Plot {
eDensity hDensity eCurrent hCurrent dopingConcentration
}
Math {
*-- Parallelization on multi-CPU machine --*
exitonfailure 
Number_Of_Threads=1   * change the number of threads to > 1 to make 
 * parallelization possible. First ensure your machine 
* has shared-memory multi-CPU configuration.
*-- Numeric/Solver Controls --*
Extrapolate           * switches on solution extrapolation along a bias ramp
extendedprecision
Derivatives           * considers mobility derivatives in Jacobian
Iterations=15          * maximum-allowed number of Newton iterations (3D)
RelErrControl         * switches on the relative error control for solution
* variables (on by default)
Digits=5              * relative error control value. Iterations stop if 
* dx/x < 10^(-Digits)
Method=Super            * use the iterative linear solver with default parameter 
NotDamped=100         * number of Newton iterations over which the RHS-norm 
* is allowed to increase
Transient=BE          * switches on BE transient method
}
Solve {
*- Buildup of initial solution:
NewCurrentFilePrefix="junk"
Coupled(Iterations=100){ Poisson }
Coupled{ Poisson Electron Hole }
*- Bias drain to target bias
Quasistationary(
InitialStep=0.01 MinStep=1e-7 MaxStep=0.2
Goal{ Name="Anode" Voltage= -2 }
){ Coupled{ Poisson Electron Hole }}
*- Gate voltage sweep
NewCurrentFilePrefix=""
Quasistationary(
InitialStep=1e-3 MinStep=1e-7 MaxStep=0.05 Increment=1.41 Decrement=2.
Goal{ Name="Anode" Voltage= 2 }
){ Coupled{ Poisson Electron Hole }CurrentPlot(Time=(Range=(0,1)Intervals=101))}
}