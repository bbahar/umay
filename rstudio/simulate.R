# simulate data for dashboard
library(dplyr)
set.seed(111)
transfusion_example_data <- data.frame(id=c(1:1000),
                                       age_year=sample(0:22,1000, replace=TRUE),
                                       time=sample(seq(as.POSIXct("2020-01-01 00:00:01"), 
                                                       as.POSIXct("2021-12-31 23:59:00"), 
                                                       by="min"),1000),
                                       fin=sample(10000:20000,1000, replace=TRUE),
                                       unit_no=paste0("W",sample(10000:20000,1000, replace=TRUE)),
                                       volume=sample(10:700,1000, replace=TRUE),
                                       donor_center=sample(c('ARC','CNH','Other'),1000, replace=TRUE),
                                       mrn=sample(100000:200000,1000, replace=TRUE),
                                       location=sample(c('ER','Floor','OP','ICU'),1000,replace=TRUE),
                                       hgb=sample(30:200,1000, replace=TRUE)/10,
                                       hours=sample(5:240,1000, replace=TRUE)/10,
                                       blood_group=sample(c('A NEG','A POS',
                                                            'B NEG','B POS',
                                                            'O NEG','O POS',
                                                            'AB NEG','AB POS'),1000,replace=TRUE),
                                       antibody=sample(c('NEG','POS'),1000, replace=TRUE))
transfusion_example_data <- transfusion_example_data %>% mutate(level=case_when(hgb > 1 & hgb <= 4 ~ '≤4',
                                                                                hgb > 4 & hgb <= 5 ~ '>4 to ≤5',
                                                                                hgb > 5 & hgb <= 6 ~ '>5 to ≤6',
                                                                                hgb > 6 & hgb <= 7 ~ '>6 to ≤7',
                                                                                hgb > 7 & hgb <= 8 ~ '>7 to ≤8',
                                                                                hgb > 8 & hgb <= 9 ~ '>8 to ≤9',
                                                                                hgb > 9 & hgb <= 10 ~ '>9 to ≤10',
                                                                                hgb > 10 & hgb <= 11 ~ '>10 to ≤11',
                                                                                hgb > 11 & hgb <= 12 ~ '>11 to ≤12',
                                                                                hgb > 12 & hgb <= 13 ~ '>12 to ≤13',
                                                                                hgb > 13 ~ '>13',
                                                                                TRUE~'Other'))

