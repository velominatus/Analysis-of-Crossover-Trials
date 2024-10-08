library(tidyverse)
library(readxl)

data <- read_xlsx("data/DataExample_Ch2_JK.xlsx")
data <- data %>%
  arrange(Group, Subject) %>%
  mutate(Sequence = if_else(Group == 1, "AB", "BA")) %>%
  mutate(across(c(Group, Sequence, Subject, Subject_Label), as_factor))

means <- data %>%
  group_by(Sequence) %>%
  summarise(Period1 = mean(Period1), Period2 = mean(Period2))

# Period 1 vs Period 2 Plot
labels=c(AB="AB Sequence", BA="BA Sequence")
ggplot(data = data, mapping = aes(x=Period1, y=Period2, colour=Sequence)) +
  geom_point(show.legend = FALSE) +
  geom_abline(slope=1,intercept=0) +
  facet_wrap(~Sequence, labeller = as_labeller(labels)) +
  labs(x = "Period 1", y = "Period 2") +
  theme_bw()
ggsave("report/figures/ch2/periodsPlot.png")

# Period 1 vs Period 2 with Centroids Plot
ggplot(data = data, mapping = aes(x=Period1, y=Period2, colour=Sequence)) +
  geom_point() +
  geom_point(data = means, size=5, shape="square") +
  geom_abline(slope=1,intercept=0) +
  labs(x = "Period 1", y = "Period 2") +
  theme_bw()
ggsave("report/figures/ch2/centroidsPlot.png")

# Subject-Profiles Plot
data.long <- data %>%
  rename(`1` = "Period1", `2` = "Period2") %>%
  pivot_longer(cols = c(`1`, `2`), names_to = "Period", values_to = "PEFR",
               names_transform = list(Period = as_factor))

ggplot(data = data.long, mapping = aes(x=Period, y=PEFR)) +
  geom_line(aes(group = Subject_Label), alpha = 0.55) +
  geom_point(aes(colour = Sequence), show.legend = FALSE) +
  facet_wrap(~Sequence, labeller = as_labeller(labels)) +
  theme_bw()
ggsave("report/figures/ch2/subjectProfilesPlot.png")

# Boxplot
ggplot(data = data.long, mapping = aes(x=Period, y = PEFR)) +
  geom_boxplot() +
  facet_wrap(~Sequence) +
  theme_bw()
ggsave("report/figures/ch2/boxplot.png")

# Groups-by-Periods Plot
means.long <- means %>%
  rename(`1` = "Period1", `2` = "Period2") %>%
  pivot_longer(cols = c(`1`, `2`), names_to = "Period", values_to = "PEFR",
               names_transform = as_factor)

ggplot(data = means.long, mapping = aes(x = Period, y = PEFR, colour = Sequence)) +
  geom_line(aes(group = Sequence)) +
  geom_point() +
  labs(y = "Mean PEFR") +
  theme_bw()
ggsave("report/figures/ch2/groupsByPeriodsPlot.png")

# Paired boxplot
ggplot(data = data.long, mapping = aes(x=Period, y=PEFR)) +
  facet_wrap(~Sequence, labeller = as_labeller(labels)) +
  geom_boxplot(outliers = FALSE) +
  geom_line(aes(group = Subject_Label), alpha = 0.35) +
  geom_point(alpha=0.6, mapping = aes(col = Sequence), show.legend = FALSE) +
  theme_bw()
ggsave("report/figures/ch2/pairedBoxplot.png")
