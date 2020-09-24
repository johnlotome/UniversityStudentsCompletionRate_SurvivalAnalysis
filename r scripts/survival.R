getwd()
setwd("..survival")
data <- read.table("data.csv")

# EXPLORATORY DATA ANALYSIS
head(data)
tail(data)
summary(data)

data_copy <- data

#Converting courses, Gender and Reasons into categories
data_copy$Course[data_copy$Course == 1] = "BMCS"
data_copy$Course[data_copy$Course == 2] = "BSSC"
data_copy$Course[data_copy$Course == 3] = "BTRE"
data_copy$Course[data_copy$Course == 4] = "BTAP"
data_copy$Course <- factor(data_copy$Course)

data_copy$Gender[data_copy$Gender == 1] = "M"
data_copy$Gender[data_copy$Gender == 2] = "F"
data_copy$Gender <-factor(data_copy$Gender)

data_copy$Reasons[data_copy$Reasons == 1] = "Academics"
data_copy$Reasons[data_copy$Reasons == 2] = "Health"
data_copy$Reasons[data_copy$Reasons == 3] = "Discipline"
data_copy$Reasons[data_copy$Reasons == 4] = "Finance"
data_copy$Reasons[data_copy$Reasons == 5] = "Graduated"
data_copy$Reasons <-factor(data_copy$Reasons)

tail(data_copy)

#Survial Analysis
install.packages(c("survival", "survminer"))

#loading librarires
library("survival")
library("survminer")

data$time <- data$Year*12
#Censoring
data$Status <- ifelse(data$"Year">4, 0, 1)

  #Kaplan-Meir plots
   #Survdiff for Gender
fit <- survfit(Surv(time, Status) ~Gender, data=data)
print(fit)

summary(fit)
summary(fit)$table

d <- data.frame(time = fit$time,
                n.risk = fit$n.risk,
                n.event = fit$n.event,
                n.censor = fit$n.censor,
                surv = fit$surv,
                upper = fit$upper,
                lower = fit$lower
)
d

ggsurvplot(fit, data=data,
           pval = TRUE, conf.int = TRUE,
           risk.table = TRUE,
           risk.table.col = "strata",
           linetype = "strata", 
           surv.median.line = "hv",
           ggtheme = theme_bw(),
           palette = c("#E7B800", "#2E9FDF"))

ggsurvplot(fit, data=data,                    
                pval = TRUE,            
                conf.int = TRUE,         
                conf.int.style = "step",  
                xlab = "Time in days",   
                break.time.by = 10,     
                ggtheme = theme_light(), 
                risk.table = "abs_pct",  
                risk.table.y.text.col = T,
                risk.table.y.text = FALSE,
                ncensor.plot = TRUE,      
                surv.median.line = "hv",  
                legend.labs = 
                  c("Male", "Female"),    
                palette = 
                  c("#E7B800", "#2E9FDF"))


#Survdiff for Courses
fit <- survfit(Surv(time, Status) ~Course, data=data)
print(fit)

summary(fit)
summary(fit)$table

d <- data.frame(time = fit$time,
                n.risk = fit$n.risk,
                n.event = fit$n.event,
                n.censor = fit$n.censor,
                surv = fit$surv,
                upper = fit$upper,
                lower = fit$lower
)
d

ggsurvplot(fit, data=data,
           pval = TRUE, conf.int = TRUE,
           risk.table = TRUE, 
           risk.table.col = "strata",
           linetype = "strata", 
           surv.median.line = "hv",
           ggtheme = theme_bw(), 
           palette = c("#E7B800", "#2E9FDF", "#b6d477", "#d477b9"))

ggsurvplot(fit, data=data,                    
           pval = TRUE,            
           conf.int = TRUE,         
           conf.int.style = "step",  
           xlab = "Time in days",   
           break.time.by = 10,     
           ggtheme = theme_light(), 
           risk.table = "abs_pct",  
           risk.table.y.text.col = T,
           risk.table.y.text = FALSE,
           ncensor.plot = TRUE,      
           surv.median.line = "hv",  
           legend.labs = c("BMCS", "BSSC", "BTRE", "BTAP"),    
           palette = c("#E7B800", "#2E9FDF", "#b6d477", "#d477b9"))


#Log-Rank Test  (H0 = there's no diff in survival between the groups. reject h0 if p<0.05)
# (gender)
surv_dif <- survdiff(Surv(time, Status) ~Gender, data=data)
surv_dif

# course
surv_dif_course <- survdiff(Surv(time, Status) ~Course, data=data)
surv_dif_course

# reason
surv_dif_reason <- survdiff(Surv(time, Status) ~Reasons, data=data)
surv_dif_reason


# all 3 variables
require("survival")
fit <- survfit( Surv(time, Status) ~ Gender + Course,
                 data = colon )
fit

# complex plot(of the 3 variables)
# Plot survival curves by gender and facet by course and reasons
ggsurv <- ggsurvplot(fit, fun = "event", conf.int = TRUE,
                     ggtheme = theme_bw())

ggsurv$plot +theme_bw() + 
  theme (legend.position = "right")+
  facet_grid(Course ~ Reasons
             
             
# coxph (simultaneous evaluation of the 3 factors)
# gender
res_cox <- coxph(Surv(time, Status) ~ Gender, data = data)
res_cox
summary(res_cox) 

# Course
c_cox <- coxph(Surv(time, Status) ~ Course, data = data)
c_cox
summary(c_cox) 

# Reasons
g_cox <- coxph(Surv(time, Status) ~ Reasons, data = data)
g_cox
summary(g_cox) 

#multivariate coxph