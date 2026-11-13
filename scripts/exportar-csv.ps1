param(
    [string]$ArquivoExcel = (Join-Path $PSScriptRoot '..\dados\padronizado\banco_financeiro_padronizado.xlsx'),
    [string]$PastaSaida = (Join-Path $PSScriptRoot '..\dados\csv')
)

# Lê o XLSX sem precisar de Excel instalado. Preserva as planilhas fornecidas.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$arquivo = (Resolve-Path -LiteralPath $ArquivoExcel).Path
$saida = [IO.Path]::GetFullPath($PastaSaida)
New-Item -ItemType Directory -Force -Path $saida | Out-Null
$zip = [IO.Compression.ZipFile]::OpenRead($arquivo)

try {
    function Ler-Xml([string]$nome) {
        $entrada = $zip.GetEntry($nome)
        if ($null -eq $entrada) { return $null }
        $leitor = [IO.StreamReader]::new($entrada.Open())
        try { return [xml]$leitor.ReadToEnd() } finally { $leitor.Dispose() }
    }

    $xmlStrings = Ler-Xml 'xl/sharedStrings.xml'
    $strings = @()
    if ($xmlStrings) { $strings = @($xmlStrings.sst.si | ForEach-Object { $_.InnerText }) }
    $workbook = Ler-Xml 'xl/workbook.xml'
    $relacoes = Ler-Xml 'xl/_rels/workbook.xml.rels'
    $tabelas = @{ Clientes = 'clientes'; Contas = 'contas'; Transacoes = 'transacoes'; Emprestimos = 'emprestimos' }

    foreach ($planilha in $workbook.workbook.sheets.sheet) {
        if (-not $tabelas.ContainsKey([string]$planilha.name)) { continue }
        $rid = $planilha.GetAttribute('id', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')
        $alvo = ($relacoes.Relationships.Relationship | Where-Object Id -eq $rid).Target
        if ($alvo.StartsWith('/')) { $alvo = $alvo.TrimStart('/') }
        elseif (-not $alvo.StartsWith('xl/')) { $alvo = 'xl/' + $alvo }
        $xml = Ler-Xml $alvo
        $linhas = @($xml.worksheet.sheetData.row)
        $cabecalhos = @($linhas[0].c | ForEach-Object {
            if ($_.t -eq 's') { $strings[[int]$_.v] }
            elseif ($_.t -eq 'inlineStr') { $_.is.InnerText }
            else { [string]$_.v }
        })

        $registros = [Collections.Generic.List[object]]::new()
        foreach ($linha in $linhas | Select-Object -Skip 1) {
            $registro = [ordered]@{}
            foreach ($nome in $cabecalhos) { $registro[$nome] = '' }
            foreach ($celula in $linha.c) {
                $letras = ([string]$celula.r) -replace '\d', ''
                $indice = 0
                foreach ($letra in $letras.ToCharArray()) { $indice = $indice * 26 + [int]$letra - [int][char]'A' + 1 }
                $nome = $cabecalhos[$indice - 1]
                if ($celula.t -eq 's') { $valor = $strings[[int]$celula.v] }
                elseif ($celula.t -eq 'inlineStr') { $valor = $celula.is.InnerText }
                else { $valor = [string]$celula.v }
                if ($nome -like 'data_*' -and $valor -ne '') {
                    if ($celula.t -eq 'd') { $valor = ([datetime]$valor).ToString('yyyy-MM-dd') }
                    else { $valor = [datetime]::FromOADate([double]::Parse($valor, [Globalization.CultureInfo]::InvariantCulture)).ToString('yyyy-MM-dd') }
                }
                $registro[$nome] = $valor
            }
            $registros.Add([pscustomobject]$registro)
        }

        $destino = Join-Path $saida ($tabelas[[string]$planilha.name] + '.csv')
        $csv = @($registros | ConvertTo-Csv -NoTypeInformation -Delimiter ',')
        [IO.File]::WriteAllLines($destino, [string[]]$csv, [Text.UTF8Encoding]::new($false))
        Write-Output ('{0}: {1} registros -> {2}' -f $planilha.name, $registros.Count, $destino)
    }
} finally { $zip.Dispose() }
