-- Execute com psql, a partir da raiz do repositório, em um banco vazio.
-- Gere antes os quatro CSVs com scripts/exportar-csv.ps1.
-- Interrompe em caso de erro. Não apaga nem substitui tabelas existentes.
\set ON_ERROR_STOP on
BEGIN;

CREATE TABLE public.clientes (
    id_cliente text PRIMARY KEY,
    cidade text NOT NULL,
    uf text NOT NULL,
    faixa_etaria text NOT NULL,
    segmento text NOT NULL,
    data_cadastro date NOT NULL
);

CREATE TABLE public.contas (
    id_conta text PRIMARY KEY,
    id_cliente text NOT NULL REFERENCES public.clientes(id_cliente),
    tipo_conta text NOT NULL,
    data_abertura date NOT NULL,
    saldo_inicial_brl numeric(18,2) NOT NULL,
    saldo_final_brl numeric(18,2) NOT NULL
);

CREATE TABLE public.transacoes (
    id_transacao text PRIMARY KEY,
    id_conta text NOT NULL REFERENCES public.contas(id_conta),
    data_transacao date NOT NULL,
    tipo_transacao text NOT NULL,
    natureza text NOT NULL CHECK (natureza IN ('Crédito', 'Débito')),
    canal text NOT NULL,
    valor_brl numeric(18,2) NOT NULL
);

CREATE TABLE public.emprestimos (
    id_emprestimo text PRIMARY KEY,
    id_conta text NOT NULL REFERENCES public.contas(id_conta),
    data_contratacao date NOT NULL,
    tipo_emprestimo text NOT NULL,
    principal_brl numeric(18,2) NOT NULL,
    taxa_mensal numeric(12,6) NOT NULL,
    prazo_meses integer NOT NULL,
    status_contrato text NOT NULL
);

\copy public.clientes FROM 'dados/csv/clientes.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy public.contas FROM 'dados/csv/contas.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy public.transacoes FROM 'dados/csv/transacoes.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy public.emprestimos FROM 'dados/csv/emprestimos.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

CREATE VIEW public.vw_clientes AS SELECT * FROM public.clientes;
CREATE VIEW public.vw_contas AS SELECT * FROM public.contas;
CREATE VIEW public.vw_emprestimos AS
SELECT *, CASE WHEN status_contrato = 'Em atraso' THEN 1 ELSE 0 END AS indicador_atraso
FROM public.emprestimos;
CREATE VIEW public.vw_transacoes AS
SELECT *, CASE WHEN natureza = 'Débito' THEN -valor_brl ELSE valor_brl END AS valor_assinado_brl
FROM public.transacoes;

COMMIT;
