; UCS coordinates
(sde:set-process-up-direction 1)

;----------------------------------------------------------------------
; Setting parameters
; - lateral
(define Lg    ${lg})                  ; [um] Gate length
(define Lsp   ${lspacer})                  ; [um] Spacer length
(define Lreox 0.01)                  ; [um] Spacer length
(define Lsd   (- 0.1 (- (/ Lg 2.0) (/ 0.1 2.0))))                   ; [um] S/D length
(define Ltot (+ Lg (* 2 (+ 0.06 Lsd)))) ; [um] Lateral extend total

; - layers
(define Hsub ${tsub})                      ; [um] Substrate thickness
(define Tox  12e-4)                  ; [um] Gate oxide thickness
(define Hpol ${tpoly})                    ; [um] Poly gate thickness

; - other
; - spacer rounding
(define fillet-radius 0.05)          ; [um] Rounding radius

; - pn junction resolution
(define Gpn 0.01)                  ; [um]

; - Substrate doping level
(define Nsub 1.5e18)                 ; [1/cm3]

;(define Xj  0.05)                    ; [um] Junction depth
(define Xj  ${xj})                    ; [um] Junction depth
(define Xject (* 0.4 Xj))            ; [um] Extension junction depth


; dopants
(define SD-dopant        "ArsenicActiveConcentration")
(define substrate-dopant "BoronActiveConcentration")

;----------------------------------------------------------------------
; Derived quantities
(define Ymax  (/ Ltot 2))
(define Yg    (/ Lg 2))
(define Yreox (+ Yg Lreox))
(define Ysp   (+ Yg Lsp))

(define Xsub Hsub)
(define Xgox (- Tox))
(define Xpol (- Xgox Hpol))

(define Lcont (- Ymax Ysp))

;----------------------------------------------------------------------
; procedure definitions
;

;
; convenience procedure for specifying 2-d coordinates
; this function defined to avoid need to specify 0 coordinate for z
;
(define (position-2d x y)
  (position x y 0)
)

;----------------------------------------------------------------------
; Create the physical structure.  This is the half-FET.  The full
; structure is symmetric and will be generated by reflecting the
; half structure at the end of the meshing process
;

; Creating substrate
(define substrate-region
  (sdegeo:create-rectangle
    (position-2d Xsub 0)
    (position-2d 0 Ymax)
    "Silicon"
    "R.Substrate"
  )
)

; Creating gate oxide
(define gate-oxide
  (sdegeo:create-rectangle
    (position-2d 0 0)
    (position-2d Xgox Ysp)
    "Oxide"
    "R.Gateox"
  )
)

; Creating poly reox
(define poly-reox
  (sdegeo:create-rectangle
    (position-2d Xgox Yg)
    (position-2d Xpol Yreox)
    "Oxide"
    "R.PolyReox"
  )
)

; Creating spacer
(define spacer
  (sdegeo:create-rectangle
    (position-2d Xgox Yreox)
    (position-2d Xpol Ysp)
    "Nitride"
    "R.Spacer"
  )
)

; Creating poly-Si gate
(define poly-gate
  (sdegeo:create-rectangle
    (position-2d Xgox 0)
    (position-2d Xpol Yg)
    "PolySilicon"
    "R.Polygate"
  )
)

;----------------------------------------------------------------------
; - rounding spacer
;
(sdegeo:fillet-2d
  (find-vertex-id (position-2d Xpol Ysp))
  fillet-radius
)

;----------------------------------------------------------------------
; Contact definitions
;
(sdegeo:set-contact
 (find-edge-id (position-2d 0 (* (+ Ymax Ysp) 0.5)))
 "drain"
)
(sdegeo:set-contact
 (find-edge-id (position-2d Xpol 5e-4))
 "gate"
)
(sdegeo:set-contact
 (find-edge-id (position-2d Xsub 5e-4))
 "substrate"
)


;----------------------------------------------------------------------
; Doping profiles:
;

; - Substrate
(sdedr:define-constant-profile
  "Const.Substrate"
  substrate-dopant
  Nsub
)

(sdedr:define-constant-profile-region
  "PlaceCD.Substrate"
  "Const.Substrate"
  "R.Substrate"
)

; - Poly
(sdedr:define-constant-profile "Const.Gate"
 SD-dopant 1e20 )
(sdedr:define-constant-profile-region "PlaceCD.Gate"
 "Const.Gate" "R.Polygate" )

; Source/Drain base line definition: direction matters
(sdedr:define-refeval-window "BaseLine.Drain" "Line"
 (position-2d 0 (* Ymax 2))
 (position-2d 0 Ysp)
)

; Source/Drain implant: definition of profile
(sdedr:define-gaussian-profile
  "Impl.SDprof"
  SD-dopant
  "PeakPos" 0 
  "PeakVal" 6e20
  "ValueAtDepth" Nsub
  "Depth" Xj
  "Gauss"
  "Factor" 0.4
)

; Source/Drain implant: placement of profile to baseline
(sdedr:define-analytical-profile-placement
  "Impl.Drain"
  "Impl.SDprof"
  "BaseLine.Drain"
  "Positive"
  "NoReplace"
  "Eval"
)

; Source/Drain extensions base line definitions
(sdedr:define-refeval-window "BaseLine.DrainExt" "Line"
 (position-2d 0 (* Ymax 2))
 (position-2d 0 Yg)
)

; Source/Drain extensions profile definition
(sdedr:define-gaussian-profile
  "Impl.SDextprof"
  SD-dopant
  "PeakPos" 0 
  "PeakVal" 2e20
  "ValueAtDepth" Nsub
  "Depth" (* Xj 0.25)
  "Gauss"
  "Factor" 0.25
)

; Source/Drain extensions: placement
(sdedr:define-analytical-profile-placement
  "Impl.DrainExt"
  "Impl.SDextprof"
  "BaseLine.DrainExt"
  "Positive"
  "NoReplace"
  "Eval"
)

;----------------------------------------------------------------------
; Meshing Specifications
;

;
; Substrate
;

; default mesh spacing: note minimum will limit junction refinement
(sdedr:define-refinement-size
   "Ref.Substrate"
   (/ Hsub 8) (/ Ltot 4) 
   (* Gpn 4) (* Gpn 4)
)

; doping refinement along junction
(sdedr:define-refinement-function
  "Ref.Substrate"
  "DopingConcentration" "MaxTransDiff" 1
)

; place the substrate refinement
(sdedr:define-refinement-region
  "RefPlace.Substrate"
  "Ref.Substrate"
  "R.Substrate"
)

;
; Active (region near the device)
;
(sdedr:define-refeval-window
  "RWin.Act"
  "Rectangle"
  (position-2d 0 0)
  (position-2d (* Xj 1.2) Ymax)
)

(sdedr:define-refinement-size
  "Ref.SiAct"
  (/ Xj 8) (/ Lcont 4) 
  (* Gpn 2) (* Gpn 2)
)

; doping refinement along junction
(sdedr:define-refinement-function
  "Ref.SiAct"
  "DopingConcentration" "MaxTransDiff" 1
)

; refinement along the substrate-gate insulator interface
(sdedr:define-refinement-function
  "Ref.SiAct"
  "MaxLenInt"
  "R.Substrate"
  "R.Gateox"
  1e-4
  (sqrt 2)
  "UseRegionNames"
)

(sdedr:define-refinement-placement
  "RefPlace.SiAct"
  "Ref.SiAct"
  "RWin.Act"
)

;
; Channel (region encapsulating inversion layer)
;

(sdedr:define-refeval-window
  "RWin.Chan"
  "Rectangle"
  (position-2d 0 0)
  (position-2d Xject (+ Yg Xject))
)

(sdedr:define-refinement-size
  "Ref.SiChan"
  (/ Xj 16) (/ Lg 8) 
  Gpn Gpn
)

; doping refinement along junction
(sdedr:define-refinement-function
  "Ref.SiChan"
  "DopingConcentration" "MaxTransDiff" 1
)

(sdedr:define-refinement-placement
  "RefPlace.SiChan"
  "Ref.SiChan"
  "RWin.Chan"
)

;
; Poly gate refinement
;

		(sdedr:define-refinement-size
  "Ref.Polygate"
  (/ Lg 4) (/ Lg 4)
  (* 4 Gpn) (* 4 Gpn)
)

; refinement along poly gate - gate oxide interface
(sdedr:define-refinement-function
  "Ref.Polygate"
  "MaxLenInt"
  "R.Polygate"
  "R.Gateox"
  4e-4
  (sqrt 2)
  "UseRegionNames"
)

; refinement along poly-spacer interfaces
(sdedr:define-refinement-function
  "Ref.Polygate"
  "MaxLenInt"
  "PolySilicon"
  "Oxide"
  1e-3
  2
)

(sdedr:define-refinement-region
  "RefPlace.Polygate"
  "Ref.Polygate"
  "R.Polygate"
)


;----------------------------------------------------------------------
; Build Mesh
(sde:build-mesh "${path}${tid}_n_msh_half")

;----------------------------------------------------------------------
; Reflect the device
; Note this makes a system call to the Sentaurus Datex Explorer
; there are other approaches, but this one guarantees the mesh
; is perfectly symmetric rather than reflecting the boundary and then
; meshing that.

(system:command "tdx -mtt -y -M 0 -S 0 -ren drain=source ${path}${tid}_n_msh_half_msh  ${path}/${tid}_n_msh")



