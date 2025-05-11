

File {
   * input files:
   Grid=   "/home/012738063/ML/Basic_files/T+WF/n9000_4e+16_3X4e+16_377_5014_msh.tdr"
   Parameter="sdevice_des.par"
   * output files:
   Plot=   "/home/012738063/ML/Basic_files/T+WF/n9000_4e+16_3X4e+16_377_5014_des.tdr"
   Current="/home/012738063/ML/Basic_files/T+WF/n9000_4e+16_3X4e+16_377_5014_des.plt"
   Output= "/home/012738063/ML/Basic_files/T+WF/n9000_4e+16_3X4e+16_377_5014_des.log"
}

Electrode {
  { name="anode" Schottky workfunction=5.014
    Voltage= (     0 at 0, 4 at 40.0  )
}
  { name="cathode" voltage=0.0 Resist=2.21160651097e-09
  }
}

Thermode {
  { name="cathode" Temperature = 377 SurfaceResistance=1e-6
  }

}


Physics {
 Thermodynamic
  Temperature=377
  EffectiveIntrinsicDensity(OldSlotboom)
		IncompleteIonization
  Recombination(SRH(DopingDep))
  Mobility (IncompleteIonization
DopingDependence(Phumob )
	HighFieldSaturation



)
}

Math {

Cylindrical
  -CheckUndefinedModels
  ExitOnFailure
 Transient=BE

Method=Blocked
SubMethod=ILS(set=5)  * linear solver selection

ILSrc= "set (5) {      
    iterative(gmres(100), tolrel=1e-10, tolunprec=1e-4, tolabs=0, maxit=200);
    preconditioning(ilut(1.5e-6,-1), right);
    ordering(symmetric=nd, nonsymmetric=mpsilst);
    options(compact=yes, linscale=0, refineresidual=10, verbose=0);
};"


  Extrapolate
  ErrRef(electron)= 1
  ErrRef(hole)= 1
  eDrForceRefDens= 1
  hDrForceRefDens= 1
  ExtendedPrecision
  RHSmax= 1e30
  RHSmin= 1e-30
  RHSFactor= 1e50
  CdensityMin= 1.0e-30
  Iterations= 15

}

Plot {
    eCurrent/Vector hCurrent/Vector
    ElectricField/Vector Current/Vector TotalCurrent/Vector
    Doping DonorConcentration AcceptorConcentration SpaceCharge

    SRH Auger
    eMobility hMobility
    eEparallel eEnormal 
    hEparallel hEnormal 
    ConductionBandEnergy ValenceBandEnergy 
    hQuasiFermiEnergy eQuasiFermiEnergy
    eBarrierTunneling hBarrierTunneling nonlocal
    eTrappedCharge hTrappedCharge
}


Solve {
  Coupled(Iterations=1000) {Poisson}
  * Coupled(Iterations=1000) {Poisson Electron Hole Temperature}
  * Plot (FilePrefix="/home/012738063/ML/Basic_files/T+WF/n_init" )

  NewCurrentFile="Fwd_" 
  Transient (
  InitialTime= 0 FinalTime= 40.0
  InitialStep= 0.1 Increment= 1.41
  Minstep= 1e-6 MaxStep= 4
  ){ Coupled { Poisson Electron Hole  Temperature}  
     CurrentPlot(Time=(Range=(0,40)Intervals=51))
    
}
  
}

