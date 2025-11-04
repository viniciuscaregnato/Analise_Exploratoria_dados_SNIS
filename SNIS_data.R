
# Defina o seu projeto no Google Cloud
set_billing_id("crucial-pagoda-476121-p4")

# Para carregar o dado direto no R
query <- "
SELECT
    dados.ano as ano,
    dados.id_municipio as id_municipio,
    dados.sigla_uf as sigla_uf,
    dados.populacao_atendida_agua as populacao_atendida_agua,
    dados.populacao_atentida_esgoto as populacao_atentida_esgoto,
    dados.populacao_urbana as populacao_urbana,
    dados.populacao_urbana_residente_agua as populacao_urbana_residente_agua,
    dados.populacao_urbana_atendida_agua as populacao_urbana_atendida_agua,
    dados.populacao_urbana_residente_esgoto as populacao_urbana_residente_esgoto,
    dados.populacao_urbana_atendida_esgoto as populacao_urbana_atendida_esgoto,
    dados.receita_operacional_direta as receita_operacional_direta,
    dados.receita_operacional_direta_agua as receita_operacional_direta_agua,
    dados.receita_operacional_direta_esgoto as receita_operacional_direta_esgoto,
    dados.receita_operacional_indireta as receita_operacional_indireta,
    dados.receita_operacional_direta_agua_exportada as receita_operacional_direta_agua_exportada,
    dados.receita_operacional as receita_operacional,
    dados.receita_operacional_direta_esgoto_importado as receita_operacional_direta_esgoto_importado,
    dados.arrecadacao_total as arrecadacao_total,
    dados.credito_areceber as credito_areceber,
    dados.despesa_pessoal as despesa_pessoal,
    dados.quantidade_empregado as quantidade_empregado,
    dados.despesa_produto_quimico as despesa_produto_quimico,
    dados.despesa_energia as despesa_energia,
    dados.despesa_servico_terceiro as despesa_servico_terceiro,
    dados.despesa_exploracao as despesa_exploracao,
    dados.despesas_juros_divida as despesas_juros_divida,
    dados.despesa_total_servico as despesa_total_servico,
    dados.despesa_ativo as despesa_ativo,
    dados.despesa_agua_importada as despesa_agua_importada,
    dados.despesa_fiscal as despesa_fiscal,
    dados.despesa_fiscal_nao_computada as despesa_fiscal_nao_computada,
    dados.despesa_exploracao_outro as despesa_exploracao_outro,
    dados.despesa_servico_outro as despesa_servico_outro,
    dados.despesa_amortizacao_divida as despesa_amortizacao_divida,
    dados.despesas_juros_divida_excecao as despesas_juros_divida_excecao,
    dados.despesa_divida_variacao as despesa_divida_variacao,
    dados.despesa_divida_total as despesa_divida_total,
    dados.despesa_esgoto_exportado as despesa_esgoto_exportado,
    dados.despesa_capitalizavel_municipio as despesa_capitalizavel_municipio,
    dados.despesa_capitalizavel_estado as despesa_capitalizavel_estado,
    dados.despesa_capitalizavel_prestador as despesa_capitalizavel_prestador,
    dados.investimento_agua_prestador as investimento_agua_prestador,
    dados.investimento_esgoto_prestador as investimento_esgoto_prestador,
    dados.investimento_outro_prestador as investimento_outro_prestador,
    dados.investimento_recurso_proprio_prestador as investimento_recurso_proprio_prestador,
    dados.investimento_recurso_oneroso_prestador as investimento_recurso_oneroso_prestador,
    dados.investimento_recurso_nao_oneroso_prestador as investimento_recurso_nao_oneroso_prestador,
    dados.investimento_total_prestador as investimento_total_prestador,
    dados.investimento_agua_municipio as investimento_agua_municipio,
    dados.investimento_esgoto_municipio as investimento_esgoto_municipio,
    dados.investimento_outro_municipio as investimento_outro_municipio,
    dados.investimento_recurso_proprio_municipio as investimento_recurso_proprio_municipio,
    dados.investimento_recurso_oneroso_municipio as investimento_recurso_oneroso_municipio,
    dados.investimento_recurso_nao_oneroso_municipio as investimento_recurso_nao_oneroso_municipio,
    dados.investimento_total_municipio as investimento_total_municipio,
    dados.investimento_agua_estado as investimento_agua_estado,
    dados.investimento_esgoto_estado as investimento_esgoto_estado,
    dados.investimento_outro_estado as investimento_outro_estado,
    dados.investimento_recurso_proprio_estado as investimento_recurso_proprio_estado,
    dados.investimento_recurso_oneroso_estado as investimento_recurso_oneroso_estado,
    dados.investimento_recurso_nao_oneroso_estado as investimento_recurso_nao_oneroso_estado,
    dados.investimento_total_estado as investimento_total_estado
FROM `basedosdados.br_mdr_snis.municipio_agua_esgoto` AS dados
"

df <- read_sql(query, billing_project_id = get_billing_id())

write.csv(df, "dados_snis.csv", row.names = FALSE)

View(df)
