library(basedosdados)
library(bigrquery)
library(pheatmap)
library(dplyr)
library(plm)
library(MASS)
library(car)

# 1. Importadno os dados ####

# Defina o seu projeto no Google Cloud
set_billing_id("crucial-pagoda-476121-p4")


query <- "
SELECT
    dados.ano as ano,
    dados.id_municipio as id_municipio,
    dados.sigla_uf as sigla_uf,
    dados.populacao_atendida_agua as populacao_atendida_agua,
    dados.populacao_urbana as populacao_urbana,
    dados.populacao_urbana_atendida_agua_ibge as populacao_urbana_atendida_agua_ibge,
    dados.extensao_rede_agua as extensao_rede_agua,
    dados.quantidade_sede_municipal_agua as quantidade_sede_municipal_agua,
    dados.quantidade_economia_ativa_agua as quantidade_economia_ativa_agua,
    dados.quantidade_economia_residencial_ativa_agua as quantidade_economia_residencial_ativa_agua,
    dados.volume_agua_produzido as volume_agua_produzido,
    dados.volume_agua_tratada_eta as volume_agua_tratada_eta,
    dados.volume_agua_consumido as volume_agua_consumido,
    dados.volume_agua_faturado as volume_agua_faturado,
    dados.volume_servico_agua as volume_servico_agua,
    dados.receita_operacional_direta as receita_operacional_direta,
    dados.receita_operacional_direta_agua as receita_operacional_direta_agua,
    dados.arrecadacao_total as arrecadacao_total,
    dados.despesa_total_servico as despesa_total_servico,
    dados.investimento_agua_prestador as investimento_agua_prestador,
    dados.investimento_total_prestador as investimento_total_prestador,
    dados.investimento_agua_municipio as investimento_agua_municipio,
    dados.investimento_outro_municipio as investimento_outro_municipio,
    dados.investimento_total_municipio as investimento_total_municipio,
    dados.investimento_agua_estado as investimento_agua_estado,
    dados.investimento_total_estado as investimento_total_estado
FROM `basedosdados.br_mdr_snis.municipio_agua_esgoto` AS dados
"


data <- read_sql(query, billing_project_id = get_billing_id())

View(data)

# 2. Organizando os dados ####

df <- data %>% filter (sigla_uf %in% c("BA", "PI", "MA")) # filtrando os estados

df <- df[!(is.na(df[,"populacao_atendida_agua"])),] # excluindo NA's de ag001

colSums(is.na(df))

missing_vars_ag <- names(df)[0.3<(colSums(is.na(df))/nrow(df))]
df <- df[,!(colnames(df) %in% missing_vars_ag)] #exclui as variaveis com mais de 30% missing


View(df)

# 3.	Primeira análise dos dados ####

# 3.1 As correlações

cor_ag <- cor(df[,!(names(df) %in% c("id_municipio", "sigla_uf", "ano") )],
              df[,!(names(df) %in% c("id_municipio", "sigla_uf", "ano") )],
              use = "pairwise.complete.obs")

cor_mat_ag <- as.matrix(cor_ag)

heatmap_ag <- pheatmap(cor_mat_ag,
                       color = colorRampPalette(c("white", "blue"))(100),
                       border_color = NA,
                       display_numbers = TRUE,
                       cluster_rows = FALSE, cluster_cols = FALSE,
                       )

# 3.2 Estatísticas descritivas

summary(df[,!(names(df) %in% c("id_municipio", "sigla_uf", "ano"))])


# 3.3	Ajustes após análise

df_log <- df

df_log$investimento_total_prestador <- ifelse(df$investimento_total_prestador > 0, log(df$investimento_total_prestador), 0)

df_log$investimento_agua_prestador <- ifelse(df$investimento_agua_prestador > 0, log(df$investimento_agua_prestador), 0)

df_log$despesa_total_servico <- ifelse(df$despesa_total_servico > 0, log(df$despesa_total_servico), 0)

df_log$receita_operacional_direta_agua <- ifelse(df$receita_operacional_direta_agua > 0, log(df$receita_operacional_direta_agua), 0)

df_log <- df_log[,!(names(df_log) %in% c("quantidade_sede_municipal_agua",
                                         "quantidade_economia_residencial_ativa_agua",
                                         "quantidade_economia_ativa_agua",
                                         "volume_agua_faturado",
                                         "volume_agua_tratada_eta",
                                         "populacao_urbana",
                                         "populacao_urbana_atendida_agua_ibge",
                                         "arrecadacao_total",
                                         "volume_agua_consumido",
                                         "volume_agua_produzido",
                                         "extensao_rede_agua",
                                         "receita_operacional_direta"))]



colnames(df_log)



# segunda matriz de correlaçao


cor_ag_log <- cor(df_log[,!(names(df_log) %in% c("id_municipio", "sigla_uf", "ano") )],
              df_log[,!(names(df_log) %in% c("id_municipio", "sigla_uf", "ano") )],
              use = "pairwise.complete.obs")

cor_mat_ag_log <- as.matrix(cor_ag_log)

heatmap_ag_log <- pheatmap(cor_mat_ag_log,
                       color = colorRampPalette(c("white", "blue"))(100),
                       border_color = NA,
                       display_numbers = TRUE,
                       cluster_rows = FALSE, cluster_cols = FALSE,
)

# 4. rodando a regressao de painel ####

df_painel <- pdata.frame(df_log, index = c("id_municipio", "ano", "sigla_uf"))
df_painel <- na.omit(df_painel)
View(df_painel)

df_painel[] <- lapply(df_painel, function(x) {
  if (inherits(x, "integer64")) as.numeric(x) else x
})

variables_ind <- !(names(df_painel) %in% c("populacao_atendida_agua","id_municipio", "ano", "sigla_uf"))
variables_ind <- df_painel[,variables_ind]

formula <- paste("populacao_atendida_agua ~ ", paste(names(variables_ind), collapse ="+"))


reg_painel <- plm(formula, data = df_painel, model = "pooling")
summary(reg_painel)

# 4. rodando a regressao linear

reg_lin <- lm(formula, data = df_painel)
summary(reg_lin)

vif(reg_lin)


# 5. Seleção de modelo ####

modelo_completo <- lm(populacao_atendida_agua ~ 
                        volume_servico_agua + 
                        receita_operacional_direta_agua + 
                        despesa_total_servico + 
                        investimento_agua_prestador + 
                        investimento_total_prestador,
                      data = df_painel)

modelo_nulo <- lm(populacao_atendida_agua ~ 1, data = df_painel)

modelo_forward <- stepAIC(modelo_nulo,
                          scope = list(lower = modelo_nulo, upper = modelo_completo),
                          direction = "forward",
                          trace = TRUE)

modelo_backward <- stepAIC(modelo_completo,
                           direction = "backward",
                           trace = TRUE)

modelo_both <- stepAIC(modelo_completo,
                           direction = "both",
                           trace = TRUE)

# 6. testando o modelo escolhido ####

modelo_final <- lm(populacao_atendida_agua ~ volume_servico_agua
                   + despesa_total_servico, data = df_painel) 

plot(modelo_final)

plot(modelo_final$residuals)
