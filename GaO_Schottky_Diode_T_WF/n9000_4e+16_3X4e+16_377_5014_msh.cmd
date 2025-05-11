Title ""

Controls {
}

IOControls {
	EnableSections
}

Definitions {
	Constant "Const.Substrate" {
		Species = "ArsenicActiveConcentration"
		Value = 1.5e+18
	}
	Constant "Const.Drift" {
		Species = "ArsenicActiveConcentration"
		Value = 4e+16
	}
	Constant "Const.DriftA" {
		Species = "BoronActiveConcentration"
		Value = 3.4e+16
	}
	Constant "Const.SubstrateA" {
		Species = "BoronActiveConcentration"
		Value = 1e+15
	}
	Refinement "Ref.Sub" {
		MaxElementSize = ( 50 50 1 )
		MinElementSize = ( 0.1 0.1 1 )
	}
	Refinement "Ref.Drift" {
		MaxElementSize = ( 50 10 1 )
		MinElementSize = ( 0.1 0.1 1 )
	}
	Refinement "RefinementDefinition_2" {
		MaxElementSize = ( 10 0.5 1 )
		MinElementSize = ( 1 1 1 )
	}
	Refinement "RefinementDefinition_3" {
		MaxElementSize = ( 1 50 1 )
		MinElementSize = ( 1 1 1 )
	}
}

Placements {
	Constant "Place.Substrate" {
		Reference = "Const.Substrate"
		EvaluateWindow {
			Element = region ["R.Sub"]
		}
	}
	Constant "Place.Drift" {
		Reference = "Const.Drift"
		EvaluateWindow {
			Element = region ["R.Drift"]
		}
	}
	Constant "Place.DriftA" {
		Reference = "Const.DriftA"
		EvaluateWindow {
			Element = region ["R.Drift"]
		}
	}
	Constant "Place.SubstrateA" {
		Reference = "Const.SubstrateA"
		EvaluateWindow {
			Element = region ["R.Sub"]
		}
	}
	Refinement "RefPlace.Sub" {
		Reference = "Ref.Sub"
		RefineWindow = region ["R.Sub"]
	}
	Refinement "RefPlace.Drift" {
		Reference = "Ref.Drift"
		RefineWindow = region ["R.Drift"]
	}
	Refinement "RefinementPlacement_2" {
		Reference = "RefinementDefinition_2"
		RefineWindow = Rectangle [(0 -9) (120 0)]
	}
	Refinement "RefinementPlacement_3" {
		Reference = "RefinementDefinition_3"
		RefineWindow = Rectangle [(100 0) (140 -643)]
	}
}

