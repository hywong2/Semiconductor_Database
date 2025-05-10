set n_thickness 200
set i_thickness 10
set p_thickness 200
set n_doping_conc 99770006382255046656
set i_doping_conc 4345102241715714
set p_doping_conc 8531001140175912960
line x location= [expr 0-10-200]<nm> spacing= 1<nm> spacing.method=regular
line x location= 0<nm> spacing.method=regular  spacing= 1<nm> tag=SiTop
line x location= 200<nm> spacing= 1<nm> spacing.method=regular  tag= SiBottom
region Silicon xlo= SiTop xhi= SiBottom
init concentration= 99770006382255046656<cm-3> field= Arsenic
deposit thickness= 10<nm> Silicon fields.values= "Boron= 4345102241715714<cm-3>"
deposit thickness= 200<nm> Silicon fields.values= "Boron= 8531001140175912960<cm-3>"
diffuse temperature= 500<C> time=1.0e-6<min>
refinebox clear
refinebox !keep.lines
line clear
refinebox min= -200 max= (10+200) xrefine= {0.002 0.002 0.002}
grid remesh
contact bottom name= cathode
contact box Silicon xlo= [expr -10 -200 - 1]<nm> xhi= [expr -10 -200]<nm> name= Anode
struct smesh= /home/012738063/ML/SISPAD_6_29_2019_doping/NewTest/SISPAD_Files/device_99770006382255046656_4345102241715714_8531001140175912960_200_10_200