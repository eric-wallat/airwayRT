library(boot)
library(pROC)
set.seed(100)
sample <- sample(c(TRUE, FALSE), nrow(resistances), replace=TRUE, prob=c(0.8,0.2))
train <- resistances[sample, ]
test <- resistances[!sample, ] 
logit_test <- function(d,indices) {  
  d <- d[indices,]  
  fit <- glm(JR<(0.94) ~ R_Ratio, data = d, family='binomial')
  return(coef(fit))  
}
boot_fit <- boot(  
  data = train, 
  statistic = logit_test, 
  R = 2000
) 

print(exp(boot_fit$t0))
print(exp(confint(boot_fit,level=.95,type="norm")))
fit <- glm(JR<(1) ~ R_Ratio, data = train, family='binomial')
summary(fit)



model <- glm(JR<(0.94) ~ R_Ratio, data = train, family = "binomial")  
predicted <- predict(model, test, type="response")
summary(model)

#calculate AUC

auc1 <- auc(test$JR<(0.94), predicted, plot=TRUE, auc.polygon=TRUE, auc.polygon.col="grey", asp=FALSE,
            print.auc=TRUE, print.auc.cex=4,cex.axis=4,xlab="",ylab="",print.thres.cex=4,mgp=c(3,3,0),mar=c(10,12,4,1)+.1,identity.lty='dashed',identity.lwd=3,identity.col='black')
mtext("Specificity",side=1,line=1,cex=4)
mtext("Sensitivity",side=2,line=1,cex=4)
ci.auc(auc1, method='b')