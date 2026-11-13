# Reprodução local

O projeto Power BI preserva as consultas PostgreSQL usadas no dashboard. As planilhas estão incluídas para permitir reconstruir a fonte em outro computador; não são fontes Excel diretamente conectadas ao PBIP.

## Pré-requisitos

- Power BI Desktop com suporte ao formato PBIP.
- PostgreSQL e seu cliente `psql`, com acesso a um banco de estudo vazio.
- PowerShell para exportar o XLSX; não é necessário instalar Excel ou bibliotecas de terceiros.

## 1. Gerar os CSVs

Abra um terminal na raiz deste repositório e execute:

```powershell
.\scripts\exportar-csv.ps1
```

O script lê `dados/padronizado/banco_financeiro_padronizado.xlsx`, preserva a planilha e gera quatro arquivos CSV UTF-8 em `dados/csv/`. As datas são exportadas como `AAAA-MM-DD`. A aba `Diagnostico` não é uma tabela de fatos e não é importada.

Caso a execução de scripts não seja permitida no seu ambiente, siga a política local ou exporte manualmente as quatro abas como CSV UTF-8, mantendo a ordem das colunas e os nomes esperados pelo SQL. Não é necessário alterar configurações de segurança para usar o dashboard.

## 2. Preparar a base de estudo

Crie um banco vazio chamado `banco_financeiro` no PostgreSQL, pelo pgAdmin ou pela ferramenta de sua preferência. O SQL deste repositório cria tabelas, importa os CSVs e cria as views esperadas pelo modelo:

```text
psql -h localhost -p 5432 -U SEU_USUARIO -d banco_financeiro -f sql/estrutura-banco.sql
```

Execute a partir da raiz do repositório: os caminhos dos CSVs são relativos a essa pasta. Use as suas próprias credenciais, fornecidas pelo mecanismo de autenticação do PostgreSQL, sem gravá-las no repositório.

O script se destina a um **banco de estudo vazio**. Não contém `DROP`, `TRUNCATE` ou substituição de tabelas. A criação e a importação são realizadas em uma transação; erro de chave, formato ou tabela já existente interrompe a execução.

As views de apoio são uma reconstrução documentada a partir dos campos exigidos pelo PBIP. Os scripts SQL originais da etapa anterior do estudo não foram fornecidos. `valor_assinado_brl` usa a convenção crédito positivo e débito negativo; não é utilizado pelos indicadores da página de empréstimos.

## 3. Carregar no Power BI

Abra `powerbi/BancoFinanceiro.pbip` e mantenha suas pastas `.Report` e `.SemanticModel` juntas. Atualize os dados com a conexão PostgreSQL local. Se seu servidor, porta ou banco forem diferentes, edite as consultas no Power Query antes da atualização.

O cache `.pbi/cache.abf` não está no GitHub. Por isso, um clone novo pode abrir inicialmente sem dados até a primeira atualização.

## 4. Conferir os resultados

Sem restringir modalidade ou segmento, a página de 2025 deve apresentar:

| Medida | Esperado |
|---|---:|
| Total de contratos | 280 |
| Principal contratado | R$ 6.610.759,82 |
| Contratos em atraso | 43 |
| Percentual em atraso | 15,36% |

As aberturas detalhadas estão nos arquivos de `docs/validacao/`. Teste também os filtros de modalidade e segmento: os cartões, gráficos e tabela devem ser recalculados juntos.

## Escopo da validação

O dashboard e os indicadores foram conferidos no Power BI Desktop com a fonte original local. O exportador de CSV foi executado sobre a planilha incluída. O SQL de reconstrução foi preparado para PostgreSQL e não foi executado contra o banco original, para preservar o ambiente do estudo.
