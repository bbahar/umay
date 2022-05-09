# transfusion dashboard
library(readr)
library(tidyverse)
library(lubridate)
laborder <- read_csv("laborder.csv", show_col_types = FALSE)
# attributes of laborder.csv
# cols(
#  MRN = col_character(),
#  FIN = col_character(),
#  Patient_Loc = col_character(),
#  Hgb_Date = col_character(),
#  Result = col_double()
# )
bridge <- read_csv("transfusion.csv", show_col_types = FALSE)
# attributes of transfusion.csv
# cols(
#  `Encounter id` = col_double(),
#  `Event Id` = col_double(),
#  `Clinical Event Id` = col_double(),
#  `Parent Event Id` = col_double(),
#  `MRN- Organization` = col_double(),
#  `Financial Number` = col_double(),
#  `Age- Days (Visit)` = col_double(),
#  `Age- Years (Visit)` = col_double(),
#  `Clinical Event` = col_character(),
#  `Clinical Event Result Type` = col_character(),
#  `Clinical Event Result Units` = col_character(),
#  `Clinical Event Result` = col_character(),
#  `Clinical Sig Update Date & Time` = col_character()
# )
antibody <- read_csv("antibody.csv", show_col_types = FALSE)
# attributes of antibody.csv
# cols(
#  FIN = col_double(),
#  Antibody = col_character()
# )
bloodgroup <- read_csv("bloodgroup.csv", show_col_types = FALSE)
# attributes of bloodgroup.csv
# cols(
#  FIN = col_double(),
#  `Blood group` = col_character()
# )
laborder$FIN <- str_replace(laborder$FIN, "-", "")
laborder$FIN <- as.numeric(laborder$FIN)
laborder$DT_hgb <- mdy_hm(laborder$Hgb_Date)
laborder$Hgb <- as.numeric(laborder$Result)
laborder <- laborder %>% filter(Result >= 1 & Result <= 15)
laborder <- laborder %>% select(1,2,3,6,7)
laborder <- laborder %>% mutate(lev=case_when(Hgb > 1 & Hgb <= 4 ~ '≤4',
                                  Hgb > 4 & Hgb <= 5 ~ '>4 to ≤5',
                                  Hgb > 5 & Hgb <= 6 ~ '>5 to ≤6',
                                  Hgb > 6 & Hgb <= 7 ~ '>6 to ≤7',
                                  Hgb > 7 & Hgb <= 8 ~ '>7 to ≤8',
                                  Hgb > 8 & Hgb <= 9 ~ '>8 to ≤9',
                                  Hgb > 9 & Hgb <= 10 ~ '>9 to ≤10',
                                  Hgb > 10 & Hgb <= 11 ~ '>10 to ≤11',
                                  Hgb > 11 & Hgb <= 12 ~ '>11 to ≤12',
                                  Hgb > 12 & Hgb <= 13 ~ '>12 to ≤13',
                                  Hgb > 13 & Hgb <= 15 ~ '>13',
                                  TRUE~'Other'))
bridge$DT_transfusion <- ymd_hms(bridge$`Clinical Sig Update Date & Time`)
bridge$FIN <- bridge$`Financial Number`
Trans_RBC_volume_end <- bridge %>% filter(`Clinical Event`=='Bridge RBC/Whole Blood') %>% 
  mutate(Volume=as.numeric(`Clinical Event Result`))
Trans_units_start_end <- bridge %>% filter(str_detect(`Clinical Event Result`, "[SE]")) %>% 
  mutate(Unit_no=str_sub(`Clinical Event Result`,-13))
Trans_RBC_start_end_volume <- left_join(Trans_units_start_end,Trans_RBC_volume_end,by="Parent Event Id")
Trans_RBC_start_end_volume <- Trans_RBC_start_end_volume %>% select(1:16,31)
# Unit codes W2146(CNH) W2053(ARC) 
Trans_RBC_start_end_volume <- Trans_RBC_start_end_volume %>% 
  mutate(BDC=case_when(startsWith(Unit_no, 'W2053')~'ARC',
                       startsWith(Unit_no, 'W2146')~'CNH',
                       TRUE ~ 'Other'))
Trans_RBC_start_end_volume <- rename(Trans_RBC_start_end_volume, FIN=FIN.x)
Trans_RBC_start_end_volume <- rename(Trans_RBC_start_end_volume, Age_day=`Age- Days (Visit).x`)
Trans_RBC_start_end_volume <- rename(Trans_RBC_start_end_volume, Age_year=`Age- Years (Visit).x`)
Trans_RBC_start_end_volume <- Trans_RBC_start_end_volume %>% 
  mutate(S_E=case_when(startsWith(`Clinical Event Result.x`, 'S')~'Start',
                       startsWith(`Clinical Event Result.x`, 'E')~'End',
                       TRUE ~ 'Other'))
Trans_start <- Trans_RBC_start_end_volume %>% filter(S_E=='Start') %>% select(7,8,14:16,18,19)
Trans_start <- rename(Trans_start, Start_DT=DT_transfusion.x)
Trans_end <- Trans_RBC_start_end_volume %>% filter(S_E=='End') %>% select(14:19)
Trans_end <- rename(Trans_end, End_DT=DT_transfusion.x)
Trans_start <- Trans_start %>% select(1:5)
Trans_end <- Trans_end %>% select(1:5)
Joined_RBC <- left_join(Trans_start, Trans_end, by=c('Unit_no','FIN'))
Joined <- left_join(Joined_RBC, laborder, by='FIN')
Joined$minutes <- round(interval(Joined$DT_hgb, Joined$Start_DT)/minutes(1))
Joined$hours <- round(interval(Joined$DT_hgb, Joined$Start_DT)/hours(1),1)
Joined <- Joined %>% filter(hours>=0.1 & hours<=24)
Joined <- Joined %>% distinct(Joined$Unit_no, .keep_all = TRUE)
Joined <- Joined %>% select(1:15)
Joined$lev <- fct_relevel(Joined$lev, c('≤4', '>4 to ≤5', '>5 to ≤6', 
                                        '>6 to ≤7', '>7 to ≤8', '>8 to ≤9', 
                                        '>9 to ≤10', '>10 to ≤11', '>11 to ≤12', 
                                        '>12 to ≤13', '>13'))
Joined <- Joined %>% filter(Start_DT < "2022-1-1 00:00:00 UTC")
Joined$BDC <- as.factor(Joined$BDC)
antibody <- antibody %>% filter(Antibody == 'POS' | Antibody == 'NEG')
antibody <- antibody %>% distinct(antibody$FIN, .keep_all = TRUE)
antibody <- antibody %>% select(1:2)
bloodgroup <- bloodgroup %>% distinct(bloodgroup$FIN, .keep_all = TRUE)
bloodgroup <- bloodgroup %>% select(1:2)
bloodgroup <- inner_join(bloodgroup, antibody, by='FIN')
exampledata <- left_join(Joined, bloodgroup, by='FIN')
exampledata$`Blood group` <- fct_relevel(exampledata$`Blood group`, c('A POS'))
exampledata$`Blood group` <- fct_explicit_na(exampledata$`Blood group`, "Unknown")
exampledata$Antibody <- fct_explicit_na(exampledata$Antibody, "Unknown")
exampledata <- mutate(exampledata, id=row_number(), .before=age_day)
# data to PostgreSQL -> exampledata_n
exampledata_1 <- data.frame(id=seq.int(nrow(fulldata)), age_year=fulldata$Age_year, time=fulldata$Start_DT, 
                            fin=fulldata$FIN, unit_no=fulldata$Unit_no, volume=fulldata$Volume, 
                            donor_center=fulldata$BDC, mrn=fulldata$MRN, location=fulldata$Patient_Loc, 
                            hgb=fulldata$Hgb, hours=fulldata$hours, blood_group=fulldata$`Blood group`, 
                            antibody=fulldata$Antibody, level=fulldata$lev)
