



File {
	Grid= "/home/GaN/P1_FasterBV/Generation/S1_R2_300/GaN/nid99_3X05_1X86_9_0X0517_0X28_msh.tdr"
	Plot= "/home/GaN/P1_FasterBV/Generation/S1_R2_300/GaN/nid99_3X05_1X86_9_0X0517_0X28_des.tdr"
	Current= "/home/GaN/P1_FasterBV/Generation/S1_R2_300/GaN/nid99_3X05_1X86_9_0X0517_0X28_des.plt"
	Parameter= "/home/GaN/P1_FasterBV/Generation/S1_R2_300/GaN/par_id99_3X05_1X86_9_0X0517_0X28_des.par"
        Output= "/home/GaN/P1_FasterBV/Generation/S1_R2_300/GaN/sdevice_nid99_3X05_1X86_9_0X0517_0X28_des.log"
  }

Electrode {
		{ Name="top_schottky" Voltage= 0.0 Resist=5e+17}
   	{ Name="bot_ohmic" Voltage= 0.0  }
  }

Physics {
    	** terminal current will be A/cm**2
    	AreaFactor= 10.0e6
    
	DefaultParametersFromFile
	Fermi 
	EffectiveIntrinsicDensity (Nobandgapnarrowing)
	Recombination (
		SRH( DopingDependence) Auger Radiative 
			Avalanche
			ConstantCarrierGeneration (value= 1e10)
	)
	Mobility ( 
		DopingDependence
		HighFieldSaturation
	)
	
	IncompleteIonization
}



Math {
	
	NonLocal "NLM" (
	Electrode= "top_schottky"
	Length= 50e-7
	Digits= 4
	EnergyResolution= 1e-3
	)
		
	Extrapolate
		ExtendedPrecision(80)
		Digits= 5
		CDensityMin= 1e-15
	
	Iterations= 15
	
	* Refine solution until RHS increases or drops below 1e-3
	* This improves robustness as initial guesses for computing new solution are more precise
	* However, it leads to a larger number of Newton iterations and, therefore, slower simulations
	CheckRhsAfterUpdate
	RHSMin= 1e-3
	
	Method= ILS(set= 11)
	ILSrc="
		set(11){
			iterative(gmres(100), tolrel=1e-12, tolunprec=1e-6, tolabs=0, maxit=200);
			preconditioning(ilut(5.0e-7,-1), right);
			ordering(symmetric=nd, nonsymmetric=mpsilst);
			options(compact=yes, linscale=0, refineresidual=10, verbose=0);
		};
	"
	Number_of_Threads= 2
	Cylindrical(yAxis=0)
	Wallclock
	
	Transient= BE
	DirectCurrent
	
	ErrRef(electron)= 1e5
	ErrRef(hole)= 1e5
	
	
	RefDens_eGradQuasiFermi_Zero= 1e8
	RefDens_hGradQuasiFermi_Zero= 1e8

	eMobilityAveraging= ElementEdge
	hMobilityAveraging= ElementEdge

	ExitOnFailure
	ComputeDopingConcentration			* Forces S-Device to recompute DopingConcentration
    -CheckUndefinedModels

}

Plot {
	NonLocal
	Electricfield/Vector
	eCurrent/Vector hCurrent/Vector TotalCurrent/Vector
	
	SRH Avalanche
	eMobility hMobility
	eQuasiFermi hQuasiFermi
	eGradQuasiFermi hGradQuasiFermi
	eEparallel hEparallel
	
	eVelocity hVelocity
	Doping DonorConcentration Acceptorconcentration
	SpaceCharge
	ConductionBand ValenceBand
	BandGap Affinity
	xMoleFraction
	
	eBarrierTunneling hBarrierTunneling 
	eGapStatesRecombination hGapStatesRecombination
	SRH Radiative
	
	PE_Polarization/Vector
	PE_Charge
	PiezoCharge
	
	TotalTrapConcentration eTrappedCharge hTrappedCharge
	TotalInterfaceTrapConcentration eInterfaceTrappedCharge hInterfaceTrappedCharge
	
	StressXX StressYY StressZZ
	
	AvalancheGeneration eAvalanche hAvalanche

}


Solve {
	Coupled (Iterations= 10000 LinesearchDamping= 1e-5) {Poisson }
	
	Plot(FilePrefix="/home/014309984/GaN/P1_FasterBV/Generation/S1_R2_300/GaN/nid99_3X05_1X86_9_0X0517_0X28_zero")
	
    NewCurrentPrefix="dBV_" 

  	Transient (
	  InitialStep= 0.05e-4 	Increment= 1.4 Decrement= 1.8
	  MinStep= 1e-15 	MaxStep= 5.0e-2
	  InitialTime= 0.0 FinalTime= 2000
	  Goal { Name="top_schottky" Voltage= -2000 }
	  BreakCriteria { Current (Contact="top_schottky" absval=1e-6) } 
    ) { Coupled {Poisson Electron Hole}}
    
    Transient (
	  InitialStep= 1.999999992e-11 	Increment= 1.4 Decrement= 1.8
	  MinStep= 1.999999992e-24 	MaxStep= 0.1
	  * InitialTime= 2000.0  ** Start from the previously done time point.. 
	  FinalTime= 500000002000.0
	  Goal { Name="top_schottky" Voltage= -500000002000.0 }
	  BreakCriteria { Current (Contact="top_schottky" absval=1e-6) } 
    ) { Coupled {Poisson Electron Hole}}
 	
 	
}


