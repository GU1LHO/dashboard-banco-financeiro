# Dicionário dos dados

Dados fictícios para estudo e portfólio. As quatro tabelas operacionais existem nas duas planilhas.

## Clientes

650 registros.

| Coluna | Papel no modelo |
|---|---|
| `id_cliente` | Identificador fictício |
| `cidade` | Atributo descritivo |
| `uf` | Atributo descritivo |
| `faixa_etaria` | Atributo descritivo |
| `segmento` | Atributo descritivo |
| `data_cadastro` | Data |

## Contas

800 registros.

| Coluna | Papel no modelo |
|---|---|
| `id_conta` | Identificador fictício |
| `id_cliente` | Identificador fictício |
| `tipo_conta` | Atributo descritivo |
| `data_abertura` | Data |
| `saldo_inicial_brl` | Valor em reais |
| `saldo_final_brl` | Valor em reais |

## Transacoes

7200 registros.

| Coluna | Papel no modelo |
|---|---|
| `id_transacao` | Identificador fictício |
| `id_conta` | Identificador fictício |
| `data_transacao` | Data |
| `tipo_transacao` | Atributo descritivo |
| `natureza` | Atributo descritivo |
| `canal` | Atributo descritivo |
| `valor_brl` | Valor em reais |

## Emprestimos

280 registros.

| Coluna | Papel no modelo |
|---|---|
| `id_emprestimo` | Identificador fictício |
| `id_conta` | Identificador fictício |
| `data_contratacao` | Data |
| `tipo_emprestimo` | Atributo descritivo |
| `principal_brl` | Valor em reais |
| `taxa_mensal` | Taxa mensal em decimal (0,018 = 1,8%) |
| `prazo_meses` | Prazo em meses |
| `status_contrato` | Atributo descritivo |

## Campos derivados nas views PostgreSQL

- `vw_emprestimos.indicador_atraso`: 1 quando `status_contrato = 'Em atraso'`, 0 nos demais casos.
- `vw_transacoes.valor_assinado_brl`: valor positivo para crédito e negativo para débito.

## Diagnóstico

A versão padronizada acrescenta a aba `Diagnostico`, que registra a avaliação de ausentes, duplicatas, IDs, relações, cronologia, preservação de totais e tipos. O diagnóstico informa zero células de conteúdo alteradas.