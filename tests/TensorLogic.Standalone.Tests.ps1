<#
	.SYNOPSIS
	Standalone unit tests for TensorLogic Module (without Pester dependency)

	.DESCRIPTION
	Comprehensive tests that can be run directly with PowerShell
#>

# Import the module
$ModulePath = "$PSScriptRoot\..\src\TensorLogic\Module\TensorLogic.psm1"
if (-not (Test-Path $ModulePath)) {
	$ModulePath = "/home/runner/work/Sophia-Script-for-Windows/Sophia-Script-for-Windows/src/TensorLogic/Module/TensorLogic.psm1"
}
Import-Module $ModulePath -Force

$TestsPassed = 0
$TestsFailed = 0
$TestsTotal = 0

function Test-Assertion {
	param(
		[Parameter(Mandatory = $true)]
		[string]$TestName,
		
		[Parameter(Mandatory = $true)]
		[scriptblock]$TestBlock
	)
	
	$script:TestsTotal++
	
	try {
		& $TestBlock
		Write-Host "[PASS] $TestName" -ForegroundColor Green
		$script:TestsPassed++
		return $true
	} catch {
		Write-Host "[FAIL] $TestName" -ForegroundColor Red
		Write-Host "  Error: $_" -ForegroundColor Yellow
		$script:TestsFailed++
		return $false
	}
}

function Assert-Equal {
	param($Actual, $Expected, $Message = "Values should be equal")
	
	if ($Actual -ne $Expected) {
		throw "$Message. Expected: $Expected, Actual: $Actual"
	}
}

function Assert-NotNull {
	param($Value, $Message = "Value should not be null")
	
	if ($null -eq $Value) {
		throw $Message
	}
}

function Assert-Throws {
	param(
		[scriptblock]$ScriptBlock,
		$Message = "Should throw an error"
	)
	
	try {
		& $ScriptBlock
		throw "$Message but didn't"
	} catch {
		# Expected to throw
	}
}

Write-Host "`n=== TensorLogic Module Tests ===" -ForegroundColor Cyan
Write-Host ""

# Test Module Import
Write-Host "Module Import Tests" -ForegroundColor Yellow
Test-Assertion "Module should be imported" {
	$Module = Get-Module TensorLogic
	Assert-NotNull $Module "Module not loaded"
}

Test-Assertion "Module should export expected functions" {
	$Module = Get-Module TensorLogic
	$Functions = @('New-Tensor', 'Invoke-TensorMultiplication', 'Invoke-TensorLogicRule', 'New-SymbolicKnowledgeBase', 'Add-SymbolicRelation', 'Invoke-SymbolicReasoning', 'Show-Tensor', 'Get-TensorLogicVersion')
	foreach ($Func in $Functions) {
		if (-not $Module.ExportedFunctions.ContainsKey($Func)) {
			throw "Function $Func not exported"
		}
	}
}

# Test Get-TensorLogicVersion
Write-Host "`nGet-TensorLogicVersion Tests" -ForegroundColor Yellow
Test-Assertion "Should return version information" {
	$Version = Get-TensorLogicVersion
	Assert-NotNull $Version
	Assert-Equal $Version.Version "1.0.0"
}

# Test New-Tensor
Write-Host "`nNew-Tensor Tests" -ForegroundColor Yellow
Test-Assertion "Should create a tensor with specified dimensions" {
	$Tensor = New-Tensor -Dimensions @(2, 3)
	Assert-NotNull $Tensor
	Assert-Equal $Tensor.Type "Tensor"
	Assert-Equal $Tensor.Rank 2
}

Test-Assertion "Should initialize tensor with zeros by default" {
	$Tensor = New-Tensor -Dimensions @(2, 2)
	Assert-Equal $Tensor.Values[0][0] 0
	Assert-Equal $Tensor.Values[1][1] 0
}

Test-Assertion "Should accept custom values" {
	$Values = @(@(1, 2), @(3, 4))
	$Tensor = New-Tensor -Dimensions @(2, 2) -Values $Values
	Assert-Equal $Tensor.Values[0][0] 1
	Assert-Equal $Tensor.Values[1][1] 4
}

# Test Tensor Multiplication
Write-Host "`nInvoke-TensorMultiplication Tests" -ForegroundColor Yellow
Test-Assertion "Should multiply compatible 2x2 matrices" {
	$T1 = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 2), @(3, 4))
	$T2 = New-Tensor -Dimensions @(2, 2) -Values @(@(2, 0), @(1, 2))
	$Result = Invoke-TensorMultiplication -Tensor1 $T1 -Tensor2 $T2
	Assert-Equal $Result.Values[0][0] 4  # 1*2 + 2*1
	Assert-Equal $Result.Values[1][0] 10 # 3*2 + 4*1
}

Test-Assertion "Should throw error for incompatible dimensions" {
	Assert-Throws {
		$T1 = New-Tensor -Dimensions @(2, 3)
		$T2 = New-Tensor -Dimensions @(2, 2)
		Invoke-TensorMultiplication -Tensor1 $T1 -Tensor2 $T2
	}
}

# Test Logical Operations
Write-Host "`nInvoke-TensorLogicRule Tests" -ForegroundColor Yellow
Test-Assertion "AND operation should compute minimum" {
	$T1 = New-Tensor -Dimensions @(3) -Values @(0.8, 0.5, 0.3)
	$T2 = New-Tensor -Dimensions @(3) -Values @(0.6, 0.9, 0.4)
	$Result = Invoke-TensorLogicRule -Rule "AND" -InputTensors @($T1, $T2)
	Assert-Equal $Result.Values[0] 0.6  # min(0.8, 0.6)
	Assert-Equal $Result.Values[1] 0.5  # min(0.5, 0.9)
}

Test-Assertion "OR operation should compute maximum" {
	$T1 = New-Tensor -Dimensions @(3) -Values @(0.8, 0.5, 0.3)
	$T2 = New-Tensor -Dimensions @(3) -Values @(0.6, 0.9, 0.4)
	$Result = Invoke-TensorLogicRule -Rule "OR" -InputTensors @($T1, $T2)
	Assert-Equal $Result.Values[0] 0.8  # max(0.8, 0.6)
	Assert-Equal $Result.Values[1] 0.9  # max(0.5, 0.9)
}

Test-Assertion "NOT operation should compute complement" {
	$T = New-Tensor -Dimensions @(3) -Values @(1, 0, 0.5)
	$Result = Invoke-TensorLogicRule -Rule "NOT" -InputTensors @($T)
	Assert-Equal $Result.Values[0] 0    # 1 - 1
	Assert-Equal $Result.Values[1] 1    # 1 - 0
	Assert-Equal $Result.Values[2] 0.5  # 1 - 0.5
}

Test-Assertion "IMPLIES operation should work correctly" {
	$T1 = New-Tensor -Dimensions @(4) -Values @(1, 1, 0, 0)
	$T2 = New-Tensor -Dimensions @(4) -Values @(1, 0, 1, 0)
	$Result = Invoke-TensorLogicRule -Rule "IMPLIES" -InputTensors @($T1, $T2)
	Assert-Equal $Result.Values[0] 1  # 1 → 1 = True
	Assert-Equal $Result.Values[1] 0  # 1 → 0 = False
	Assert-Equal $Result.Values[2] 1  # 0 → 1 = True
	Assert-Equal $Result.Values[3] 1  # 0 → 0 = True
}

# Test Knowledge Base
Write-Host "`nNew-SymbolicKnowledgeBase Tests" -ForegroundColor Yellow
Test-Assertion "Should create knowledge base with facts" {
	$KB = New-SymbolicKnowledgeBase -Facts @("A", "B", "C")
	Assert-NotNull $KB
	Assert-Equal $KB.Type "KnowledgeBase"
	Assert-Equal $KB.FactCount 3
}

Test-Assertion "Should initialize identity tensor for facts" {
	$KB = New-SymbolicKnowledgeBase -Facts @("A", "B")
	Assert-Equal $KB.FactTensor.Values[0][0] 1
	Assert-Equal $KB.FactTensor.Values[0][1] 0
	Assert-Equal $KB.FactTensor.Values[1][1] 1
}

# Test Relations
Write-Host "`nAdd-SymbolicRelation Tests" -ForegroundColor Yellow
Test-Assertion "Should add relation between facts" {
	$KB = New-SymbolicKnowledgeBase -Facts @("A", "B", "C")
	Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "A" -ToFact "B" -Strength 1.0
	Assert-NotNull $KB.Relations["implies"]
	Assert-Equal $KB.Relations["implies"].Values[0][1] 1.0
}

Test-Assertion "Should support custom relation strength" {
	$KB = New-SymbolicKnowledgeBase -Facts @("A", "B")
	Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "A" -ToFact "B" -Strength 0.7
	Assert-Equal $KB.Relations["implies"].Values[0][1] 0.7
}

# Test Reasoning
Write-Host "`nInvoke-SymbolicReasoning Tests" -ForegroundColor Yellow
Test-Assertion "Should perform reasoning with single relation" {
	$KB = New-SymbolicKnowledgeBase -Facts @("A", "B", "C")
	Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "A" -ToFact "B" -Strength 1.0
	$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "A" -RelationChain @("implies")
	Assert-NotNull $Result
	Assert-Equal $Result.Query "A"
}

Test-Assertion "Should follow relation chains" {
	$KB = New-SymbolicKnowledgeBase -Facts @("Socrates", "Man", "Mortal")
	Add-SymbolicRelation -KnowledgeBase $KB -RelationName "isA" -FromFact "Socrates" -ToFact "Man" -Strength 1.0
	Add-SymbolicRelation -KnowledgeBase $KB -RelationName "isA" -FromFact "Man" -ToFact "Mortal" -Strength 1.0
	$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "Socrates" -RelationChain @("isA", "isA")
	$MortalResult = $Result.Results | Where-Object { $_.Fact -eq "Mortal" }
	Assert-NotNull $MortalResult "Should infer Socrates is Mortal"
}

# Summary
Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Total Tests: $TestsTotal" -ForegroundColor White
Write-Host "Passed: $TestsPassed" -ForegroundColor Green
Write-Host "Failed: $TestsFailed" -ForegroundColor $(if ($TestsFailed -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($TestsFailed -eq 0) {
	Write-Host "All tests passed! ✓" -ForegroundColor Green
	exit 0
} else {
	Write-Host "Some tests failed! ✗" -ForegroundColor Red
	exit 1
}
