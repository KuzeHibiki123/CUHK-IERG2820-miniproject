param([string]$IcarusBin = '')
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    if (!$IcarusBin) {
        $localBin = Join-Path $PSScriptRoot '..\tmp\tools\iverilog\app\bin'
        if (Test-Path (Join-Path $localBin 'iverilog.exe')) {
            $IcarusBin = (Resolve-Path $localBin).Path
        }
    }
    $compiler = if ($IcarusBin) { Join-Path $IcarusBin 'iverilog.exe' } else { 'iverilog' }
    $runtime = if ($IcarusBin) { Join-Path $IcarusBin 'vvp.exe' } else { 'vvp' }
    New-Item -ItemType Directory -Path 'build' -Force | Out-Null
    foreach ($test in @('question1','question2','displays','top','filter_equivalence','core_equivalence','top_equivalence','display_startup','multiplication_bounds','repeat_multiply','clock_switch','display_rom','q2_led_display')) {
        & $compiler -g2005 -Wall -s "tb_$test" -o "build/$test.vvp" -c rtl/files.f "tb/tb_$test.v" tb/reference_input_filter.v tb/reference_question1.v tb/reference_question2.v tb/reference_mini_project_top.v
        if ($LASTEXITCODE -ne 0) { throw "Compile failed: $test" }
        & $runtime "build/$test.vvp"
        if ($LASTEXITCODE -ne 0) { throw "Simulation failed: $test" }
    }
} finally { Pop-Location }
