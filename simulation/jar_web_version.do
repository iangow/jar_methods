clear
* insheet using "jar_restate_10000.csv"
gen restate = v1
gen pay = v2
gen bonus = v3
gen big4 = v4
gen director = v5
gen internat = v6
gen segment = v7
gen inter1 = pay*internat
gen inter2 = pay*segment
gen inter3 = pay*bonus
gen inter4 = internat*bonus
gen inter5 = segment*bonus
gen inter6 = pay*pay
gen inter7 = bonus*bonus
gen inter8 = segment*internat

* Table 1
summariz

* Table 2
logit restate pay bonus
mfx
logit restate pay bonus big4 director internat segment
mfx

* Table 3
#delimit ;
gmm (restate - ({t1=.03}+{t2=.06}*internat+{t3=.001}*segment+{t4=.004}*pay+{t5}*internat*pay+{t6=.007}*segment*pay)/(1+{t7=.6}*bonus)),
instruments(pay bonus internat segment inter1 inter2) onestep winitial(identity) vce(un);

gmm (restate - ({t1=.03}+{t2=.06}*internat+{t3=.001}*segment+{t4=.004}*pay+{t5}*internat*pay+{t6=.007}*segment*pay)/(1+{t7=.6}*bonus)),
instruments(pay bonus internat segment inter1 inter2) twostep winitial(identity) vce(robust);

gmm (restate - ({t1=.03}+{t2=.06}*internat+{t3=.001}*segment+{t4=.004}*pay+{t5}*internat*pay+{t6=.007}*segment*pay)/(1+{t7=.6}*bonus)),
instruments(pay bonus internat segment inter1-inter8) onestep winitial(identity) vce(un);

gmm (10000*restate - 10000*({t1=.083}+{t2=.0369}*internat+{t3=.0009}*segment+{t4=-.0655}*pay+{t5=.0256}*internat*pay+{t6=.0559}*segment*pay)/(1+{t7=.534}*bonus)),
instruments(pay bonus internat segment inter1-inter8) onestep winitial(identity) vce(un) conv_ptol(1e-13) technique("dfp"); 

gmm (restate - ({t1=.03}+{t2=.06}*internat+{t3=.001}*segment+{t4=.004}*pay+{t5}*internat*pay+{t6=.007}*segment*pay)/(1+{t7=.6}*bonus)),
instruments(pay bonus internat segment inter1-inter8) onestep winitial(identity) vce(robust);

#delimit cr 


