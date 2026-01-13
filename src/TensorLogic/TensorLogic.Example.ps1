<#
	.SYNOPSIS
	Example usage of TensorLogic Module

	.DESCRIPTION
	Demonstrates various features of the TensorLogic module including
	tensor operations, logical reasoning, and symbolic knowledge base usage.

	.EXAMPLE
	.\TensorLogic.Example.ps1
#>

# Import the TensorLogic module
Import-Module "$PSScriptRoot\Module\TensorLogic.psm1" -Force

Write-Host "`n=== TensorLogic Module Examples ===" -ForegroundColor Cyan
Write-Host ""

# Get version information
$Version = Get-TensorLogicVersion
Write-Host "Module: $($Version.Name) v$($Version.Version)" -ForegroundColor Green
Write-Host "Description: $($Version.Description)" -ForegroundColor Gray
Write-Host ""

# Example 1: Basic Tensor Creation and Display
Write-Host "Example 1: Creating and Displaying Tensors" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow

$Tensor1 = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 2), @(3, 4))
Write-Host "Created a 2x2 tensor:" -ForegroundColor White
Show-Tensor -Tensor $Tensor1
Write-Host ""

# Example 2: Tensor Multiplication
Write-Host "Example 2: Tensor Multiplication" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow

$T1 = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 2), @(3, 4))
$T2 = New-Tensor -Dimensions @(2, 2) -Values @(@(2, 0), @(1, 2))

Write-Host "Matrix 1:" -ForegroundColor White
Show-Tensor -Tensor $T1

Write-Host "`nMatrix 2:" -ForegroundColor White
Show-Tensor -Tensor $T2

$Result = Invoke-TensorMultiplication -Tensor1 $T1 -Tensor2 $T2
Write-Host "`nResult of multiplication:" -ForegroundColor White
Show-Tensor -Tensor $Result
Write-Host ""

# Example 3: Logical Operations
Write-Host "Example 3: Fuzzy Logic Operations" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow

$Evidence1 = New-Tensor -Dimensions @(3) -Values @(0.9, 0.7, 0.5)
$Evidence2 = New-Tensor -Dimensions @(3) -Values @(0.8, 0.6, 0.4)

Write-Host "Evidence 1 (e.g., 'Cloudy sky'):" -ForegroundColor White
Show-Tensor -Tensor $Evidence1

Write-Host "`nEvidence 2 (e.g., 'Barometer falling'):" -ForegroundColor White
Show-Tensor -Tensor $Evidence2

# AND operation (fuzzy min)
$Combined = Invoke-TensorLogicRule -Rule "AND" -InputTensors @($Evidence1, $Evidence2)
Write-Host "`nCombined evidence (AND):" -ForegroundColor White
Show-Tensor -Tensor $Combined

# OR operation (fuzzy max)
$Alternative = Invoke-TensorLogicRule -Rule "OR" -InputTensors @($Evidence1, $Evidence2)
Write-Host "`nAlternative evidence (OR):" -ForegroundColor White
Show-Tensor -Tensor $Alternative

# NOT operation
$Negation = Invoke-TensorLogicRule -Rule "NOT" -InputTensors @($Evidence1)
Write-Host "`nNegation of Evidence 1 (NOT):" -ForegroundColor White
Show-Tensor -Tensor $Negation
Write-Host ""

# Example 4: Symbolic Reasoning - Classic Syllogism
Write-Host "Example 4: Symbolic Reasoning - Classic Syllogism" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow

Write-Host "Premises:" -ForegroundColor White
Write-Host "  1. Socrates is a Man" -ForegroundColor Gray
Write-Host "  2. All Men are Mortal" -ForegroundColor Gray
Write-Host "Question: Is Socrates mortal?" -ForegroundColor White
Write-Host ""

$KB = New-SymbolicKnowledgeBase -Facts @("Socrates", "Man", "Mortal")
Add-SymbolicRelation -KnowledgeBase $KB -RelationName "isA" -FromFact "Socrates" -ToFact "Man" -Strength 1.0
Add-SymbolicRelation -KnowledgeBase $KB -RelationName "isA" -FromFact "Man" -ToFact "Mortal" -Strength 1.0

$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "Socrates" -RelationChain @("isA", "isA")

Write-Host "Reasoning Results:" -ForegroundColor White
foreach ($Res in $Result.Results)
{
	if ($Res.Confidence -gt 0)
	{
		Write-Host "  $($Res.Fact): Confidence = $($Res.Confidence)" -ForegroundColor Green
	}
}

$MortalResult = $Result.Results | Where-Object { $_.Fact -eq "Mortal" }
if ($MortalResult -and $MortalResult.Confidence -gt 0)
{
	Write-Host "`nConclusion: Yes, Socrates is mortal (confidence: $($MortalResult.Confidence))" -ForegroundColor Cyan
}
Write-Host ""

# Example 5: Probabilistic Reasoning
Write-Host "Example 5: Probabilistic Reasoning" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow

Write-Host "Knowledge Base:" -ForegroundColor White
Write-Host "  Rain -> Clouds (strength: 0.8)" -ForegroundColor Gray
Write-Host "  Clouds -> Wet Ground (strength: 0.6)" -ForegroundColor Gray
Write-Host "Query: If it rains, what are the consequences?" -ForegroundColor White
Write-Host ""

$WeatherKB = New-SymbolicKnowledgeBase -Facts @("Rain", "Clouds", "WetGround")
Add-SymbolicRelation -KnowledgeBase $WeatherKB -RelationName "causes" -FromFact "Rain" -ToFact "Clouds" -Strength 0.8
Add-SymbolicRelation -KnowledgeBase $WeatherKB -RelationName "causes" -FromFact "Clouds" -ToFact "WetGround" -Strength 0.6

# Single step reasoning
$SingleStep = Invoke-SymbolicReasoning -KnowledgeBase $WeatherKB -Query "Rain" -RelationChain @("causes")
Write-Host "After 1 step (Rain -> ?):" -ForegroundColor White
foreach ($Res in $SingleStep.Results)
{
	if ($Res.Confidence -gt 0)
	{
		Write-Host "  $($Res.Fact): $($Res.Confidence)" -ForegroundColor Green
	}
}

# Multi-step reasoning
$MultiStep = Invoke-SymbolicReasoning -KnowledgeBase $WeatherKB -Query "Rain" -RelationChain @("causes", "causes")
Write-Host "`nAfter 2 steps (Rain -> ? -> ?):" -ForegroundColor White
foreach ($Res in $MultiStep.Results)
{
	if ($Res.Confidence -gt 0)
	{
		Write-Host "  $($Res.Fact): $($Res.Confidence)" -ForegroundColor Green
	}
}
Write-Host ""

# Example 6: Complex Logical Inference
Write-Host "Example 6: Complex Logical Inference (IMPLIES)" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow

# A → B (if A then B)
$A = New-Tensor -Dimensions @(4) -Values @(1, 1, 0, 0)
$B = New-Tensor -Dimensions @(4) -Values @(1, 0, 1, 0)

Write-Host "A (Premise):" -ForegroundColor White
Show-Tensor -Tensor $A

Write-Host "`nB (Conclusion):" -ForegroundColor White
Show-Tensor -Tensor $B

$Implication = Invoke-TensorLogicRule -Rule "IMPLIES" -InputTensors @($A, $B)
Write-Host "`nA -> B (Implication):" -ForegroundColor White
Show-Tensor -Tensor $Implication

Write-Host "`nInterpretation:" -ForegroundColor White
$Cases = @("1->1 = True", "1->0 = False", "0->1 = True", "0->0 = True")
for ($i = 0; $i -lt 4; $i++)
{
	$Color = if ($Implication.Values[$i] -eq 1) { "Green" } else { "Red" }
	Write-Host "  Case $($i+1): $($Cases[$i]) => $($Implication.Values[$i])" -ForegroundColor $Color
}
Write-Host ""

Write-Host "=== Examples Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "For more information, see:" -ForegroundColor Gray
Write-Host "  - $($Version.Website)" -ForegroundColor Blue
Write-Host "  - $($Version.Reference)" -ForegroundColor Blue
Write-Host ""
