## claims.R
## Script run to create the images in lecture.Rmd from capital district claims.

## INIT ========================================================================
library(tidyverse)
options(scipen=999)

## DATA ========================================================================
claims_data_file <- "~/Documents/data/PaidClaims2018.csv"
claims <- read_csv(claims_data_file)
claims$TotalPaidAMT[is.na(claims$TotalPaidAMT)] <- 0
claims$MemberResponsibilityAMT[is.na(claims$MemberResponsibilityAMT)] <- 0
claims <- 
  claims %>%
  mutate(TotalAMT = MemberResponsibilityAMT+TotalPaidAMT) %>%
  filter(TotalAMT >= 0)

## ANALYSIS ====================================================================

## Some basic calculations.
avg_cost <- mean(claims$TotalAMT)
med_cost <- median(claims$TotalAMT)
sd_cost <- sd(claims$TotalAMT)
lower_95 <- avg_cost - sd_cost * 2
upper_95 <- avg_cost + sd_cost * 2


## This is the first picture.
zoomed_out <- 
  claims %>%
  ggplot(aes(x = TotalAMT)) +
  geom_density() + 
  geom_vline(aes(xintercept = avg_cost), color = "red") + 
  geom_vline(aes(xintercept = lower_95), color = "blue") +
  geom_vline(aes(xintercept = upper_95), color = "blue")
ggsave("images/clams-2018-zoomed-out.png", zoomed_out, device = "png", width = 4, height=2)

## This is the second picture.
zoomed_in <-
  claims %>%
  filter(TotalAMT <= 50000) %>%
  ggplot(aes(x = TotalAMT)) +
  geom_density(size = .5) + 
  geom_vline(aes(xintercept = avg_cost), color = "red", size = .5) +
  geom_vline(aes(xintercept = med_cost), color = "green", size = .5) + 
  geom_vline(aes(xintercept = lower_95), color = "blue", size = .5) +
  geom_vline(aes(xintercept = upper_95), color = "blue", size = .5)
ggsave("images/clams-2018-zoomed-in.png", zoomed_in, device = "png", width = 4, height=2)
