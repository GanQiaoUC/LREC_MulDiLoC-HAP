# Load libraries
library(lme4)       # for linear mixed-effects models
library(lmerTest)   # adds p-values to lmer
library(emmeans)    # for estimated marginal means and pairwise comparisons
library(dplyr)
library(ggplot2)    # for plotting
library(tidyr)
library(sjPlot)
library(ggeffects)
library(corrplot)

#correlation####
df <- read.csv("measures.csv", stringsAsFactors = TRUE)
summary(df)

#syntactic complexity
df_num <- df[, c("MeanClauseLength", "AvgDepLength", "DepTypeEntropy", "NominalDensity", "NPComplexity", 
                "VPComplexity", "MeanNPLength", "PPDensity")]

cor_matrix <- cor(df_num, use = "pairwise.complete.obs")
round(cor_matrix, 2)

corrplot(cor_matrix, method = "color", type = "upper", tl.col = "black", tl.srt = 45)

library(performance)
correlation::correlation(df_num)
results <- correlation(df_num, method = "spearman", use = "pairwise.complete.obs")
results

corrplot(cor_matrix, method = "color", order = "hclust", addrect = 3)

#PCA analysis####
# 1. Identify complete cases
complete_rows <- complete.cases(df[, c("MeanClauseLength", "AvgDepLength", "DepTypeEntropy",
                                       "NominalDensity", "NPComplexity", "VPComplexity",
                                       "MeanNPLength", "PPDensity")])

# 2. Run PCA only on complete cases
pca_data <- df[complete_rows, c("MeanClauseLength", "AvgDepLength", "DepTypeEntropy",
                                "NominalDensity", "NPComplexity", "VPComplexity",
                                "MeanNPLength", "PPDensity")]
# Run PCA
pca_result <- prcomp(pca_data, scale. = TRUE)

# Summary of variance explained
summary(pca_result)

# View loadings (correlations between variables and components)
round(pca_result$rotation, 3)

# Basic biplot
biplot(pca_result, scale = 0)

# Or a nicer ggplot-based version
library(factoextra)
fviz_pca_biplot(pca_result,
                repel = TRUE,
                col.var = "darkred", 
                col.ind = "gray60") +
  theme_minimal()

# 3. Extract PC scores
#pc_scores <- as.data.frame(pca_result$x[, 1:3])
pc_scores <- as.data.frame(pca_result$x[, 1])
colnames(pc_scores) <- "PC1"

# 4. Attach grouping variables from the same rows
pc_scores$Condition <- df$Condition[complete_rows]
pc_scores$Variety <- df$Variety[complete_rows]
pc_scores$Session <- df$Session[complete_rows]
pc_scores$PID <- df$PID[complete_rows]
pc_scores$Topic <- df$Topic[complete_rows]

#syntactic complexity regression overall: AI conditions only####
pc_scores$Variety <- factor(pc_scores$Variety, levels = c("US", "CAN", "UK", "AUS", "NZ"))
# Subset the data to keep only the AI conditions
df_sub <- subset(pc_scores, Condition %in% c("stylistic", "phrasal", "paragraph"))

model_pc1 <- lmer(PC1 ~ Session + (1|ID)+(1 | Topic), data = df_sub)
summary(model_pc1)

emm <- emmeans(model_pc1, ~ Phase)
pairs(emm, adjust = "tukey")

ggplot(df_sub, aes(x = Session, y = PC1, fill = Session)) +
  geom_boxplot(
    width = 0.4,
    outlier.size = 0.6
  ) +  
  labs(
    x = "",
    y = "Syntactic Complexity (PC1)",
    title = ""
  ) +
  coord_cartesian(ylim = c(-5, 5)) +
  theme_minimal(base_size = 10) +
  theme(
    axis.title.y = element_text(face = "bold", size = 10),
    axis.text = element_text(size = 8, color = "black"),
    legend.title = element_text(face = "bold", size = 10),
    legend.text = element_text(size = 10),
    legend.position = "none",
    legend.margin = margin(t = -5, r = 0, b = 0, l = 0),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(fill = NA, color = "grey70", linewidth = 0.5),
    axis.text.x = element_text(angle = 0, hjust = 0.5)  # Keep horizontal if space allows
  )+
  scale_x_discrete(labels = c("1st" = "Session 1", "2nd" = "Session 2", "3rd" = "Session 3")) +
  scale_fill_manual(values = c("#E64B35FF", "#66a61e", "#4DBBD5FF"))
ggsave("2_Syntactic.pdf", width = 4, height = 2.5, units = "in", dpi = 300)

#syntactic complexity by condition and variety####
pc_scores$Condition <- factor(pc_scores$Condition, levels = c("GPT", "natural", "stylistic", "phrasal", "paragraph"))
pc_scores$Condition <- dplyr::recode(pc_scores$Condition,
                                     "GPT" = "GPT",
                                     "natural" = "Nat",
                                     "stylistic" = "Sty",
                                     "phrasal" = "Phr",
                                     "paragraph" = "Par")

pc_scores$Condition <- factor(pc_scores$Condition, 
                              levels = c("GPT", "Nat", "Sty", "Phr", "Par"))


model_pc2 <- lmer(PC1 ~ Session * Condition * Variety + (1|ID)+(1 | Topic), data = pc_scores)
summary(model_pc2)

#final
ggplot(pc_scores, aes(x = Variety, y = PC1, fill = Condition)) +
  geom_boxplot(outlier.size = 0.6, linewidth = 0.3) +  # smaller outliers, thinner lines, alpha = 0.8
  facet_wrap(~ Session, nrow = 3, #ncol = 3
             labeller = labeller(Session = c("1st" = "Session 1", 
                                             "2nd" = "Session 2", 
                                             "3rd" = "Session 3"))) +
  labs(x = "", 
       y = "Syntactic Complexity (PC1)", 
       fill = "Condition") +coord_cartesian(ylim = c(-5, 6)) +
  theme_minimal(base_size = 10) +  # 10-11pt is standard for papers
  scale_fill_manual(values = c("#E64B35FF", "#66a61e", "#4DBBD5FF", 
                               "#d95f02", "#7570b3")) +  # use fill not color
  theme(
    strip.text = element_text(face = "bold", size = 10),
    axis.title.y = element_text(face = "bold", size = 10),
    axis.text = element_text(color = "black"),  # darker axis text
    legend.title = element_text(face = "bold", size = 6),
    legend.text = element_text(size = 6),
    legend.position = "bottom",
    legend.margin = margin(t = -5, r = 0, b = 0, l = 0),  # pull legend closer
    panel.grid.minor = element_blank(),  # remove minor gridlines
    panel.border = element_rect(fill = NA, color = "grey70", linewidth = 0.4),  # add panel borders
    strip.background = element_rect(fill = "grey90", color = "grey70")  # subtle facet background
  )
ggsave("3_pc1_interaction.pdf", width = 3.5, height = 6, dpi = 300)



# Get predicted values
emm <- emmeans(model_pc2, ~ Phase * Condition * Variety)
# Convert to a data frame for plotting
emm_df <- as.data.frame(emm)

emm <- emmeans(model_pc2, ~ Session | Condition * Variety)
pairs(emm, adjust = "tukey")


#lexical diversity regression####
df <- read.csv("measures.csv", stringsAsFactors = TRUE)
summary(df)

##overall: extract only AI groups####
df$Variety <- factor(df$Variety, levels = c("US", "CAN", "UK", "AUS", "NZ"))
# Subset the data to keep only the last three conditions
df_sub <- subset(df, Condition %in% c("stylistic", "phrasal", "paragraph"))
# Redefine Condition as a factor with only these levels
df_sub$Condition <- factor(df_sub$Condition, levels = c("stylistic", "phrasal", "paragraph"))
summary(df_sub)

model1 <- lmer(MLTD ~ Session + (1 | ID) +(1 | Topic), data = df_sub,REML = FALSE) #(1 | Topic)
summary(model1)
tab_model(model1)
tab_model(model1, show.re.var = TRUE, show.icc = TRUE, show.r2 = TRUE)

emm <- emmeans(model1, ~ Phase)
pairs(emm, adjust = "tukey")

ggplot(df_sub, aes(x = Session, y = MLTD, fill = Session)) +
  geom_boxplot(
    linewidth = 0.4,
    outlier.size = 0.6
  ) +  
  labs(
    x = "",
    y = "Lexical Diversity (MLTD)",
    title = ""
  ) +
  coord_cartesian(ylim = c(41, 181)) +
  theme_minimal(base_size = 10) +
  theme(
    axis.title.y = element_text(face = "bold", size = 10),
    axis.text = element_text(size = 8, color = "black"),
    legend.title = element_text(face = "bold", size = 10),
    legend.text = element_text(size = 10),
    legend.position = "none",
    legend.margin = margin(t = -5, r = 0, b = 0, l = 0),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(fill = NA, color = "grey70", linewidth = 0.5),
    axis.text.x = element_text(angle = 0, hjust = 0.5)  # Keep horizontal if space allows
  )+
  scale_x_discrete(labels = c("1st" = "Session 1", "2nd" = "Session 2", "3rd" = "Session 3")) +
  scale_fill_manual(values = c("#E64B35FF", "#66a61e", "#4DBBD5FF"))
ggsave("1_MLTD.pdf", width = 4, height = 2.5, units = "in", dpi = 300)

#lexical diversity by variety and condition####
df$Condition <- factor(df$Condition, levels = c("GPT", "natural", "stylistic", "phrasal", "paragraph"))
df$Condition <- dplyr::recode(df$Condition,
                                     "GPT" = "GPT",
                                     "natural" = "Nat",
                                     "stylistic" = "Sty",
                                     "phrasal" = "Phr",
                                     "paragraph" = "Par")

df$Condition <- factor(df$Condition, 
                              levels = c("GPT", "Nat", "Sty", "Phr", "Par"))

model2 <- lmer(MLTD ~ Condition*Variety*Session + (1 | ID) + (1 | Topic), data = df, REML = FALSE)
summary(model2)

library(car)
vif(lm(MLTD ~ Condition*Variety*Phase, data=df))

# Get estimated marginal means for the interaction
emm <- emmeans(model2, ~ Session | Condition * Variety)
pairs(emm, adjust = "tukey")

#final
ggplot(df, aes(x = Variety, y = MLTD, fill = Condition)) +
  geom_boxplot(outlier.size = 0.6, linewidth = 0.3) +  # smaller outliers, thinner lines, alpha = 0.8
  facet_wrap(~ Session, nrow = 3, #ncol = 3
             labeller = labeller(Session = c("1st" = "Session 1", 
                                             "2nd" = "Session 2", 
                                             "3rd" = "Session 3"))) +
  labs(x = "", 
       y = "Lexical Diversity (MLTD)", 
       fill = "Condition") +coord_cartesian(ylim = c(41, 311)) +
  theme_minimal(base_size = 10) +  # 10-11pt is standard for papers
  scale_fill_manual(values = c("#E64B35FF", "#66a61e", "#4DBBD5FF", 
                               "#d95f02", "#7570b3")) +  # use fill not color
  theme(
    strip.text = element_text(face = "bold", size = 10),
    axis.title.y = element_text(face = "bold", size = 10),
    axis.text = element_text(color = "black"),  # darker axis text
    legend.title = element_text(face = "bold", size = 6),
    legend.text = element_text(size = 6),
    legend.position = "bottom",
    legend.margin = margin(t = -5, r = 0, b = 0, l = 0),  # pull legend closer
    panel.grid.minor = element_blank(),  # remove minor gridlines
    panel.border = element_rect(fill = NA, color = "grey70", linewidth = 0.4),  # add panel borders
    strip.background = element_rect(fill = "grey90", color = "grey70")  # subtle facet background
  )
ggsave("mltd_interaction.pdf", width = 3.5, height = 6, dpi = 300)


#nominalisation####
#pos
df <- read.csv("nominalisation_pos.csv", stringsAsFactors = TRUE)
summary(df)

df$Condition <- factor(df$Condition, levels = c("GPT", "Nat", "Sty", "Phr", "Par"))
df$POS <- factor(df$POS, levels = c("Nouns", "Verbs", "Adjectives", "Adverbs"))

#df$Variety <- factor(df$Variety, levels = c("US", "CAN", "UK", "AUS", "NZ"))
# Subset the data to keep only the last three conditions
df_sub <- subset(df, POS %in% c("Nouns"))
summary(df_sub)

model1 <- lm(Frequency ~ Condition, data = df_sub)
summary(model1)

library(car)
Anova(model1, type = 3)

emmeans(model1, pairwise ~ Condition | POS)

#final
ggplot(df_sub, aes(x = Condition, y = Frequency, fill = Condition)) +
  geom_boxplot(outlier.size = 0.8, linewidth = 0.4) +
  labs(
    x = "",
    y = "Relative Frequency",
    fill = "Condition"
  ) +
  theme_minimal(base_size = 12) +coord_cartesian(ylim = c(0.10, 0.23)) +
  scale_fill_manual(values = c("#E64B35FF", "#66a61e", "#4DBBD5FF", 
                               "#d95f02", "#7570b3")) +
  theme(
    axis.title.y = element_text(face = "bold", size = 12),
    axis.text = element_text(size = 10, color = "black"),
    legend.title = element_text(face = "bold", size = 10),
    legend.text = element_text(size = 10),
    legend.position = "none",
    legend.margin = margin(t = -5, r = 0, b = 0, l = 0),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(fill = NA, color = "grey70", linewidth = 0.5),
    axis.text.x = element_text(angle = 0, hjust = 0.5)  # Keep horizontal if space allows
  )
ggsave("4_nouns.pdf", width = 4, height = 2.5, dpi = 300)

##lexeme####
df <- read.csv("lexeme.csv", stringsAsFactors = TRUE)
summary(df)

df$Condition <- factor(df$Condition, levels = c("GPT", "Nat", "Sty", "Phr", "Par"))
df$Type <- factor(df$Type, levels = c("High", "Mid", "Low"))

model1 <- lm(Frequency ~ Condition*Type, data = df)
summary(model1)

emmeans(model1, pairwise ~ Condition | Type)


ggplot(df, aes(x = Condition, y = Frequency, fill = Condition)) +
  geom_boxplot(outlier.size = 0.6, linewidth = 0.3) +  # smaller outliers, thinner lines, alpha = 0.8
  facet_wrap(~ Type, nrow = 1) + #ncol = 3
  labs(x = "", 
       y = "Lexeme Frequency", 
       fill = "Type") + coord_cartesian(ylim = c(0, 35)) +
  theme_minimal(base_size = 10) +  # 10-11pt is standard for papers
  scale_fill_manual(values = c("#E64B35FF", "#66a61e", "#4DBBD5FF", 
                               "#d95f02", "#7570b3")) +  # use fill not color
  theme(
    strip.text = element_text(face = "bold", size = 10),
    axis.title.y = element_text(face = "bold", size = 10),
    axis.text = element_text(size = 6, color = "black"),  # darker axis text
    legend.title = element_text(face = "bold", size = 6),
    legend.text = element_text(size = 6),
    legend.position = "none",
    legend.margin = margin(t = -5, r = 0, b = 0, l = 0),  # pull legend closer
    panel.grid.minor = element_blank(),  # remove minor gridlines
    panel.border = element_rect(fill = NA, color = "grey70", linewidth = 0.4),  # add panel borders
    strip.background = element_rect(fill = "grey90", color = "grey70")  # subtle facet background
  )
ggsave("6_lexeme_interaction.pdf", width = 4, height = 2.5, dpi = 300)
