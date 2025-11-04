library(dplyr)
library(plm)
library(corrplot)
library(pheatmap)
library(plm)
library(car)
library(MASS)

# carregango os dados ####

df <- read.csv("dados_snis.csv")

# Organizando os dados importados da base de dados do SNIS: ####

df <- df %>% filter (sigla_uf %in% c("BA", "PI", "MA"))

# 1. O dataframe de AG001: ####

df_ag <- df[!(is.na(df[,"populacao_atendida_agua"])),]
missing_vars_ag <- names(df_ag)[0.3<(colSums(is.na(df_ag))/nrow(df_ag))]
df_ag <- df_ag[,!(colnames(df_ag) %in% missing_vars_ag)]

na_counts <- colSums(is.na(df_ag))
for (i in seq_along(na_counts)) {
  cat(sprintf("%-40s : %5d\n", names(na_counts)[i], na_counts[i]))
}


# 2. As correlações de AG001 ####

cor_ag <- cor(df_ag[,"populacao_atendida_agua"],
                 df_ag[,!(names(df_ag) %in% c("id_municipio", "sigla_uf"))],
                 use = "pairwise.complete.obs")

cor_mat_ag <- as.matrix(cor_ag)

heatmap_ag <- pheatmap(cor_mat_ag,
         color = colorRampPalette(c("red", "white", "blue"))(100),
         border_color = NA,
         display_numbers = TRUE,
         cluster_rows = FALSE, cluster_cols = FALSE,
         breaks = seq(-1, 1, length.out = 101))



# 3. a regressao de painel ####

# primeira regressao ####
df_ag_panel <- pdata.frame(df_ag, index = c("id_municipio", "ano", "sigla_uf"))
View(df_ag_panel)


variables_ag <- !(names(df_ag) %in% c("populacao_atendida_agua","id_municipio", "ano", "sigla_uf"))
variables_ag <- df_ag[,variables_ag]


formula <- paste("populacao_atendida_agua ~ ", paste(names(variables_ag), collapse ="+"))

reg_painel <- plm( formula, data = df_ag_panel, model = "pooling")
summary(reg_painel)

alias(reg_painel)

# segunda regressao ####

df_ag_panel <- df_ag_panel[,!(names(df_ag_panel) %in% c("populacao_urbana_residente_agua",
                                                 "despesas_juros_divida_excecao"))] 

variables_ag <- !(names(df_ag) %in% c("populacao_atendida_agua","id_municipio",
                                      "ano", "sigla_uf",
                                      "populacao_urbana_residente_agua",
                                      "despesas_juros_divida_excecao"))
variables_ag <- df_ag[,variables_ag]

formula <- paste("populacao_atendida_agua ~ ", paste(names(variables_ag), collapse ="+"))

reg_painel <- plm( formula, data = df_ag_panel, model = "pooling")

summary(reg_painel)

alias(reg_painel)

vif(reg_painel)


# seleção de modelo ####

df_reg <- na.omit(df_ag_panel)

reg <- lm( formula, data = df_reg)

#seleção com BIC
n <- nrow(df_ag_panel)
forward_bic <- stepAIC(reg, direction = "forward", k = log(n))
backward_bic <- stepAIC(reg, direction = "backward", k= log(n))
both_bic <- stepAIC(reg, direction = "both", k= log(n))

# seleçaõ com AIC
backward_aic <- stepAIC(reg, direction = "backward")
forward_aic <- stepAIC(reg, direction = "backward")
both_aic <- stepAIC(reg, direction = "both")

summary(both_bic)



