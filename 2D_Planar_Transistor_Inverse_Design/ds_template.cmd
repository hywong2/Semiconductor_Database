
File {
  Grid      = "${path}${tid}_n_msh.tdr"
  
  Parameter = "${path}${tid}_sdevice_des.par"
  Plot      = "${path}${tid}_n_des.tdr"
  Current   = "${path}${tid}_n_des.plt"
  Output    = "${path}${tid}_n_des.log"
  
}

Electrode {
  { Name="source"    Voltage=0.0 }
  { Name="drain"     Voltage=0.0 }
  { Name="gate"      Voltage=0.0 }
  { Name="substrate" Voltage=0.0 }
}

Physics {Fermi}

Physics (Material= Silicon) {
	eQuantumPotential(AutoOrientation density)
	Mobility (
	  Enormal (IALMob(AutoOrientation)) 
	  HighFieldSaturation
	)
      Recombination(SRH)
      EffectiveIntrinsicDensity(OldSlotboom)
      
}


Plot{
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi
  eTemperature Temperature * hTemperature
  ElectricField/Vector Potential SpaceCharge
  Doping DonorConcentration AcceptorConcentration
  SRH Band2Band * Auger
  AvalancheGeneration eAvalancheGeneration hAvalancheGeneration
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  BandGap 
  BandGapNarrowing
  Affinity
  ConductionBand ValenceBand
  eBarrierTunneling hBarrierTunneling * BarrierTunneling
  eTrappedCharge  hTrappedCharge
  eGapStatesRecombination hGapStatesRecombination
  eDirectTunnel hDirectTunnel
  
}

Math {
  Extrapolate
  Derivatives
  RelErrControl
  Digits=5
  RHSmin=1e-10
  Notdamped=100
  Iterations=50
  DirectCurrent
  ExitOnFailure
  TensorGridAniso
  StressMobilityDependence= TensorFactor 
  * Please uncomment if you have 8 CPUs or more
  NumberOfThreads= 8
  
}

Solve {
  Coupled ( Iterations=100 LineSearchDamping=1e-8 ){ Poisson eQuantumPotential }
  Coupled { Poisson Electron eQuantumPotential }
  Save ( FilePrefix="${path}${tid}_n_init" )
  Quasistationary( 
    InitialStep=1e-2 Increment=1.5 
    MinStep=1e-6 MaxStep=0.5 
    Goal { Name="drain" Voltage=0.05 } 
  ){ Coupled { Poisson Electron eQuantumPotential } }
  Save ( FilePrefix="${path}${tid}_n_VdLin" )

  Load ( FilePreFix="${path}${tid}_n_init" )
  Quasistationary( 
    InitialStep=1e-2 Increment=1.5 
    MinStep=1e-6 MaxStep=0.5 
    Goal { Name="drain" Voltage=1.4 } 
  ){ Coupled { Poisson Electron eQuantumPotential } }
  Save ( FilePrefix="${path}${tid}_n_VdSat" )

  NewCurrentFile="IdVg_VdLin_" 
  Load ( FilePrefix = "${path}${tid}_n_VdLin" )
  Quasistationary( 
    DoZero 
    InitialStep=1e-2 Increment=1.2 
    MinStep=1e-8 MaxStep=0.05 
    Goal { Name="gate" Voltage=1.4	 } 
  ){ Coupled { Poisson Electron eQuantumPotential } }

  NewCurrentFile="IdVg_VdSat_" 
  Load ( FilePrefix="${path}${tid}_n_VdSat" )
  Quasistationary( 
    DoZero 
    InitialStep=1e-2 Increment=1.2 
    MinStep=1e-8 MaxStep=0.05 
    Goal { Name="gate" Voltage=1.4	 } 
  ){ Coupled { Poisson Electron eQuantumPotential } }
}


