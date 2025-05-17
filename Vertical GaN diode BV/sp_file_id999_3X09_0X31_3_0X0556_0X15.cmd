; Simple Diode Structures: 
; PND == P-N Junction Diode
; SBD == Schottky Barrier Diode
; JBS == Junction Schottky Barrier Diode
(sde:clear)
; Using UCS coordinate system for structure generation (Default coordinate system)
(sde:set-process-up-direction "-x")

(define Lsub 3.25)
(define Lepi 11.00)
(define Lna  0.00)
(define Ltren 0.06)
(define Ltot (+ Lsub Lepi Lna))
(define EpiDop 1E16)
(define SubDop 2E18)
(define OxL 2.0)

(define gap 3.09)
(define width 0.31)
(define ngr 3)
(define sigma 0.0556)
(define depth 0.15)

(define widthStart 4.5)
(define gLast 20)

(define yList (list 0 widthStart))

; Add the guard rings
(do ( (i 0 (+ i 1)) )
    ( (= i ngr) )
    (begin
       (define yListNew1 (append yList (list (+ (list-ref yList (- (length yList) 1)) gap))))
       (set! yList yListNew1)
       (define yListNew2 (append yList (list (+ (list-ref yList (- (length yList) 1)) width))))
       (set! yList yListNew2)
    )
)

(define yListNew3 (append yList (list (+ (list-ref yList (- (length yList) 1)) gLast))))
(set! yList yListNew3)

(define Wtot (list-ref yList (- (length yList) 1)))

(define delta 0.1)

;========================================
;   Create boundary
;========================================

;---GaN Region
(sdegeo:create-rectangle (position -0.25 0.0 0.0) (position Ltot Wtot  0.0) 
 "GaN" "EpiSubRegion" )  

; =================== Contact Definition Placement  =========================

(sdegeo:define-contact-set "top_schottky" 4.0 (color:rgb 1.0 0.0 0.0) "##")
(do ( (i 0 (+ i 1)) )
    ( (= i ngr) )
    (begin
        (sdegeo:define-contact-set (string-append "top_schottky" (number->string (+ i 1))) 4.0 (color:rgb 1.0 0.0 0.0) "##")
    )
)
(sdegeo:define-contact-set "bot_ohmic"    4.0 (color:rgb 1.0 0.0 0.0) "##")

(sdegeo:set-default-boolean "ABA")


(define tp.metal (sdegeo:create-polygon (list  (position -1.25 0.0 0)  
                                               (position -1.25 Wtot 0)  
                                               (position -0.25 (- (list-ref yList 1) delta) 0)  
                                               (position -0.25 (list-ref yList 0) 0)) "Metal" "top_schottky" ))
(sdegeo:set-current-contact-set "top_schottky" )
(sdegeo:set-contact-boundary-edges tp.metal)
(sdegeo:delete-region tp.metal)

(do ( (i 0 (+ i 1)) )
    ( (= i ngr) )
    (begin
        (define tp.metal (sdegeo:create-polygon (list  (position -1.25 0.0 0)  
                                                       (position -1.25 Wtot 0)  
                                                       (position -0.25 (- (list-ref yList (+ (* i 2) 3)) delta) 0)
                                                       (position -0.25 (+ (list-ref yList (+ (* i 2) 2)) delta) 0)) "Metal" (string-append "top_schottky" (number->string (+ i 1))) ))
        (sdegeo:set-current-contact-set (string-append "top_schottky" (number->string (+ i 1))) )
	(sdegeo:set-contact-boundary-edges tp.metal)
	(sdegeo:delete-region tp.metal)
    )
)

(sdegeo:define-2d-contact (find-edge-id (position  Ltot (/ Wtot 2) 0.0)) "bot_ohmic")

; =================== Constant and Analytical Profiles =========================
;---Definitions
(sdedr:define-constant-profile "Epi_Dop_Defn" "nSiliconActiveConcentration" EpiDop)
(sdedr:define-constant-profile "Sub_Dop_Defn" "nSiliconActiveConcentration" SubDop)

;---Windows
(sdedr:define-refeval-window "Epi_Win" "Rectangle"  (position -0.25 0 0)    (position Lepi Wtot 0.0))
(sdedr:define-refeval-window "Sub_Win" "Rectangle"  (position Lepi 0 0) (position Ltot Wtot 0.0)) 

 ;---Placement
(sdedr:define-constant-profile-placement "Epi_Place" "Epi_Dop_Defn" "Epi_Win")
(sdedr:define-constant-profile-placement "Sub_Place" "Sub_Dop_Defn" "Sub_Win")

; -- p-type doping specification
(sdedr:define-erf-profile "Impl.Res"
 "pMagnesiumActiveConcentration"
 "SymPos" depth  "MaxVal" 1E19
 "Length" sigma
 "Erf" "Length" sigma
)

; -- n-type doping specification
(sdedr:define-erf-profile "Impl.Res_n"
 "nSiliconActiveConcentration"
 "SymPos" depth  "MaxVal" 1E19
 "Length" sigma
 "Erf"  "Length" sigma
)

(sdedr:define-refinement-window "BaseLine1" "Line"  
 (position -0.25  0 0.0)   
 (position -0.25  Wtot  0.0) )
; -- implant definition
(sdedr:define-analytical-profile-placement "Implleft1" 
 "Impl.Res" "BaseLine1" "Negative" "NoReplace" "Eval")

(do ( (i 0 (+ i 1)) )
    ( (= i (+ ngr 1)) )
    (begin
	; -- implant placement
	(sdedr:define-refinement-window (string-append "BaseLine" (number->string (+ i 2))) "Line"  
	 (position -0.25  (list-ref yList (+ (* i 2) 1)) 0.0)   
	 (position -0.25  (list-ref yList (+ (* i 2) 2))  0.0) )
	; -- implant definition
	(sdedr:define-analytical-profile-placement (string-append "Implleft" (number->string (+ i 2))) 
	 "Impl.Res_n" (string-append "BaseLine" (number->string (+ i 2))) "Negative" "NoReplace" "Eval")
    )
)

;========================================
;   Define mesh
;========================================
; Global 
(sdedr:define-refinement-window "Win.Default" "Rectangle" 
	(position -0.25 0.0 0.0) (position Ltot Wtot 0.0) )
(sdedr:define-refinement-size "Ref.Default" 1 1 99 0.002 0.05 66 )
;(sdedr:define-refinement-size "Ref.Default" 0.01 999 0.001 888)
(sdedr:define-refinement-function "Ref.Default" "DopingConcentration" "MaxTransDiff" 1.0)
(sdedr:define-refinement-function "Ref.Default" "MaxLenInt" "GaN" "Contact" 0.0015 2.0)
(sdedr:define-refinement-placement "Pl.Default" "Ref.Default" "Win.Default" )

; Epi Region
(sdedr:define-refinement-window "Win.top" "Rectangle" 
	(position -0.25 0.0 0.0) (position Lepi Wtot 0.0) )
(sdedr:define-refinement-size "Ref.top" 0.5 0.5 99 0.005 0.05 66 )
;(sdedr:define-refinement-size "Ref.top" 0.01 999 0.001 888)
(sdedr:define-refinement-placement "Pl.top" "Ref.top" "Win.top" )

;========================================
;   Build mesh
;========================================
(sde:build-mesh "snmesh" "-AI" "/home/014309984/GaN/P1_FasterBV/Generation/S6_R3_10000/GaN/nid999_3X09_0X31_3_0X0556_0X15_msh")


