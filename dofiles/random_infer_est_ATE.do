log using "random_infer_est_ATE.log", replace text

* eddititiedd

* load data from working directory
use "random_infer_est_ATE.dta", clear

describe
summarize
list

* estimate ATE with regression
regress y d


* estimate ATE with mean difference
summarize Y1
scalar mean_Y1 = r(mean)

summarize Y0
scalar mean_Y0 = r(mean)

scalar ATE_est = mean_Y1 - mean_Y0

display ATE_est


* generate treatment groups with combination C(7,2)
generate id = _n, before(d)
list

save "random_infer_est_ATE_id.dta", replace

combin id, k(2)
list

rename id_* trt_*
list

save "random_infer_est_trt_combin.dta", replace


* generate control groups with combination C(7,5)
use "random_infer_est_ATE_id.dta", clear

combin id, k(5)
list

generate ctr_1 = id_5[22 - _n]
generate ctr_2 = id_4[22 - _n]
generate ctr_3 = id_3[22 - _n]
generate ctr_4 = id_2[22 - _n]
generate ctr_5 = id_1[22 - _n]

list

drop id_*

save "random_infer_est_ctr_combin.dta", replace


* merge treatment and control groups
use "random_infer_est_trt_combin.dta", clear

list

merge 1:1 _n using "random_infer_est_ctr_combin.dta"
drop _merge

list

save "random_infer_est_sharpNull_base.dta", replace


* replace trt_* values with observed results y

forvalues i = 1/2 {
	replace trt_`i' = 15 if trt_`i' == 1
	replace trt_`i' = 15 if trt_`i' == 2
	replace trt_`i' = 20 if trt_`i' == 3
	replace trt_`i' = 20 if trt_`i' == 4
	replace trt_`i' = 10 if trt_`i' == 5
	replace trt_`i' = 15 if trt_`i' == 6
	replace trt_`i' = 30 if trt_`i' == 7
}

* replace ctr_* values with observed results y

forvalues i = 1/5 {
	replace ctr_`i' = 15 if ctr_`i' == 1
    replace ctr_`i' = 15 if ctr_`i' == 2
    replace ctr_`i' = 20 if ctr_`i' == 3
    replace ctr_`i' = 20 if ctr_`i' == 4
    replace ctr_`i' = 10 if ctr_`i' == 5
    replace ctr_`i' = 15 if ctr_`i' == 6
    replace ctr_`i' = 30 if ctr_`i' == 7
}

save "random_infer_est_sharpNull_numeric.dta", replace


* generate ATT, ATU, and ATE 
generate ATT = (trt_1 + trt_2) / 2, after(trt_2)
generate ATU = (ctr_1 + ctr_2 + ctr_3 + ctr_4 + ctr_5) / 5
generate ATE = ATT - ATU

tabulate ATE 

scalar ATE_est = 6.5

tabulate ATE if ATE >= ATE_est

return list

display round((r(N) / 21), 0.01)

save, replace

log close
