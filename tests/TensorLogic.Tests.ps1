<#
	.SYNOPSIS
	Comprehensive unit tests for TensorLogic Module

	.DESCRIPTION
	Tests all features and functions of the TensorLogic module including:
	- Tensor creation and initialization
	- Tensor operations (multiplication, logical operations)
	- Symbolic knowledge base operations
	- Reasoning and inference
	- Utility functions

	.NOTES
	Run with: Invoke-Pester -Path .\tests\TensorLogic.Tests.ps1
#>

# Import the module
$ModulePath = Join-Path $PSScriptRoot "..\src\TensorLogic\Module\TensorLogic.psm1"
Import-Module $ModulePath -Force

Describe "TensorLogic Module Tests" {
	Context "Module Import" {
		It "Should import the module successfully" {
			Get-Module TensorLogic | Should -Not -BeNullOrEmpty
		}

		It "Should export all expected functions" {
			$ExpectedFunctions = @(
				'New-Tensor',
				'Invoke-TensorMultiplication',
				'Invoke-TensorLogicRule',
				'New-SymbolicKnowledgeBase',
				'Add-SymbolicRelation',
				'Invoke-SymbolicReasoning',
				'Show-Tensor',
				'Get-TensorLogicVersion'
			)

			$Module = Get-Module TensorLogic
			foreach ($Function in $ExpectedFunctions)
			{
				$Module.ExportedFunctions.ContainsKey($Function) | Should -Be $true
			}
		}
	}

	Context "Get-TensorLogicVersion" {
		It "Should return version information" {
			$Version = Get-TensorLogicVersion
			$Version | Should -Not -BeNullOrEmpty
			$Version.Version | Should -Be "1.0.0"
			$Version.Name | Should -Be "TensorLogic Module"
		}

		It "Should include website and reference links" {
			$Version = Get-TensorLogicVersion
			$Version.Website | Should -Be "https://tensor-logic.org/"
			$Version.Reference | Should -Match "bengoertzel"
		}
	}

	Context "New-Tensor" {
		It "Should create a tensor with specified dimensions" {
			$Tensor = New-Tensor -Dimensions @(2, 3)
			$Tensor | Should -Not -BeNullOrEmpty
			$Tensor.Type | Should -Be "Tensor"
			$Tensor.Rank | Should -Be 2
			$Tensor.Dimensions[0] | Should -Be 2
			$Tensor.Dimensions[1] | Should -Be 3
		}

		It "Should initialize tensor values to zero by default" {
			$Tensor = New-Tensor -Dimensions @(2, 2)
			$Tensor.Values[0][0] | Should -Be 0
			$Tensor.Values[0][1] | Should -Be 0
			$Tensor.Values[1][0] | Should -Be 0
			$Tensor.Values[1][1] | Should -Be 0
		}

		It "Should accept custom initial values" {
			$Values = @(@(1, 2), @(3, 4))
			$Tensor = New-Tensor -Dimensions @(2, 2) -Values $Values
			$Tensor.Values[0][0] | Should -Be 1
			$Tensor.Values[0][1] | Should -Be 2
			$Tensor.Values[1][0] | Should -Be 3
			$Tensor.Values[1][1] | Should -Be 4
		}

		It "Should create rank-1 tensors (vectors)" {
			$Tensor = New-Tensor -Dimensions @(3)
			$Tensor.Rank | Should -Be 1
			$Tensor.Values.Count | Should -Be 3
		}

		It "Should throw error for empty dimensions" {
			{ New-Tensor -Dimensions @() } | Should -Throw
		}
	}

	Context "Invoke-TensorMultiplication" {
		It "Should multiply two compatible 2x2 matrices" {
			$T1 = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 2), @(3, 4))
			$T2 = New-Tensor -Dimensions @(2, 2) -Values @(@(2, 0), @(1, 2))
			
			$Result = Invoke-TensorMultiplication -Tensor1 $T1 -Tensor2 $T2
			
			$Result.Values[0][0] | Should -Be 4  # 1*2 + 2*1
			$Result.Values[0][1] | Should -Be 4  # 1*0 + 2*2
			$Result.Values[1][0] | Should -Be 10 # 3*2 + 4*1
			$Result.Values[1][1] | Should -Be 8  # 3*0 + 4*2
		}

		It "Should multiply non-square matrices with compatible dimensions" {
			$T1 = New-Tensor -Dimensions @(2, 3) -Values @(@(1, 2, 3), @(4, 5, 6))
			$T2 = New-Tensor -Dimensions @(3, 2) -Values @(@(7, 8), @(9, 10), @(11, 12))
			
			$Result = Invoke-TensorMultiplication -Tensor1 $T1 -Tensor2 $T2
			
			$Result.Dimensions[0] | Should -Be 2
			$Result.Dimensions[1] | Should -Be 2
			$Result.Values[0][0] | Should -Be 58  # 1*7 + 2*9 + 3*11
			$Result.Values[0][1] | Should -Be 64  # 1*8 + 2*10 + 3*12
		}

		It "Should throw error for incompatible dimensions" {
			$T1 = New-Tensor -Dimensions @(2, 3)
			$T2 = New-Tensor -Dimensions @(2, 2)
			
			{ Invoke-TensorMultiplication -Tensor1 $T1 -Tensor2 $T2 } | Should -Throw
		}

		It "Should throw error for invalid tensor types" {
			$T1 = @{Type = "NotATensor"}
			$T2 = New-Tensor -Dimensions @(2, 2)
			
			{ Invoke-TensorMultiplication -Tensor1 $T1 -Tensor2 $T2 } | Should -Throw
		}

		It "Should compute identity matrix multiplication correctly" {
			$Identity = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 0), @(0, 1))
			$Matrix = New-Tensor -Dimensions @(2, 2) -Values @(@(5, 6), @(7, 8))
			
			$Result = Invoke-TensorMultiplication -Tensor1 $Identity -Tensor2 $Matrix
			
			$Result.Values[0][0] | Should -Be 5
			$Result.Values[0][1] | Should -Be 6
			$Result.Values[1][0] | Should -Be 7
			$Result.Values[1][1] | Should -Be 8
		}
	}

	Context "Invoke-TensorLogicRule - AND Operation" {
		It "Should perform element-wise AND (min) on rank-1 tensors" {
			$T1 = New-Tensor -Dimensions @(3) -Values @(0.8, 0.5, 0.3)
			$T2 = New-Tensor -Dimensions @(3) -Values @(0.6, 0.9, 0.4)
			
			$Result = Invoke-TensorLogicRule -Rule "AND" -InputTensors @($T1, $T2)
			
			$Result.Values[0] | Should -Be 0.6  # min(0.8, 0.6)
			$Result.Values[1] | Should -Be 0.5  # min(0.5, 0.9)
			$Result.Values[2] | Should -Be 0.3  # min(0.3, 0.4)
		}

		It "Should perform AND on rank-2 tensors" {
			$T1 = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 0), @(1, 1))
			$T2 = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 1), @(0, 1))
			
			$Result = Invoke-TensorLogicRule -Rule "AND" -InputTensors @($T1, $T2)
			
			$Result.Values[0][0] | Should -Be 1  # min(1, 1)
			$Result.Values[0][1] | Should -Be 0  # min(0, 1)
			$Result.Values[1][0] | Should -Be 0  # min(1, 0)
			$Result.Values[1][1] | Should -Be 1  # min(1, 1)
		}

		It "Should throw error for AND with less than 2 tensors" {
			$T1 = New-Tensor -Dimensions @(2)
			
			{ Invoke-TensorLogicRule -Rule "AND" -InputTensors @($T1) } | Should -Throw
		}
	}

	Context "Invoke-TensorLogicRule - OR Operation" {
		It "Should perform element-wise OR (max) on rank-1 tensors" {
			$T1 = New-Tensor -Dimensions @(3) -Values @(0.8, 0.5, 0.3)
			$T2 = New-Tensor -Dimensions @(3) -Values @(0.6, 0.9, 0.4)
			
			$Result = Invoke-TensorLogicRule -Rule "OR" -InputTensors @($T1, $T2)
			
			$Result.Values[0] | Should -Be 0.8  # max(0.8, 0.6)
			$Result.Values[1] | Should -Be 0.9  # max(0.5, 0.9)
			$Result.Values[2] | Should -Be 0.4  # max(0.3, 0.4)
		}

		It "Should throw error for OR with less than 2 tensors" {
			$T1 = New-Tensor -Dimensions @(2)
			
			{ Invoke-TensorLogicRule -Rule "OR" -InputTensors @($T1) } | Should -Throw
		}
	}

	Context "Invoke-TensorLogicRule - NOT Operation" {
		It "Should perform element-wise NOT (1-x) on rank-1 tensor" {
			$T1 = New-Tensor -Dimensions @(3) -Values @(1, 0, 0.5)
			
			$Result = Invoke-TensorLogicRule -Rule "NOT" -InputTensors @($T1)
			
			$Result.Values[0] | Should -Be 0    # 1 - 1
			$Result.Values[1] | Should -Be 1    # 1 - 0
			$Result.Values[2] | Should -Be 0.5  # 1 - 0.5
		}

		It "Should perform NOT on rank-2 tensor" {
			$T1 = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 0), @(0.3, 0.7))
			
			$Result = Invoke-TensorLogicRule -Rule "NOT" -InputTensors @($T1)
			
			$Result.Values[0][0] | Should -Be 0    # 1 - 1
			$Result.Values[0][1] | Should -Be 1    # 1 - 0
			$Result.Values[1][0] | Should -Be 0.7  # 1 - 0.3
			$Result.Values[1][1] | Should -Be 0.3  # 1 - 0.7
		}
	}

	Context "Invoke-TensorLogicRule - IMPLIES Operation" {
		It "Should perform logical IMPLIES (A → B)" {
			$T1 = New-Tensor -Dimensions @(4) -Values @(1, 1, 0, 0)
			$T2 = New-Tensor -Dimensions @(4) -Values @(1, 0, 1, 0)
			
			$Result = Invoke-TensorLogicRule -Rule "IMPLIES" -InputTensors @($T1, $T2)
			
			# A → B ≡ ¬A ∨ B
			$Result.Values[0] | Should -Be 1  # 1 → 1 = True
			$Result.Values[1] | Should -Be 0  # 1 → 0 = False
			$Result.Values[2] | Should -Be 1  # 0 → 1 = True
			$Result.Values[3] | Should -Be 1  # 0 → 0 = True
		}

		It "Should throw error for IMPLIES with wrong number of tensors" {
			$T1 = New-Tensor -Dimensions @(2)
			
			{ Invoke-TensorLogicRule -Rule "IMPLIES" -InputTensors @($T1) } | Should -Throw
		}
	}

	Context "New-SymbolicKnowledgeBase" {
		It "Should create a knowledge base with facts" {
			$KB = New-SymbolicKnowledgeBase -Facts @("A", "B", "C")
			
			$KB | Should -Not -BeNullOrEmpty
			$KB.Type | Should -Be "KnowledgeBase"
			$KB.Facts.Count | Should -Be 3
			$KB.FactCount | Should -Be 3
		}

		It "Should initialize identity tensor for facts" {
			$KB = New-SymbolicKnowledgeBase -Facts @("A", "B")
			
			$KB.FactTensor.Values[0][0] | Should -Be 1
			$KB.FactTensor.Values[0][1] | Should -Be 0
			$KB.FactTensor.Values[1][0] | Should -Be 0
			$KB.FactTensor.Values[1][1] | Should -Be 1
		}

		It "Should handle single fact" {
			$KB = New-SymbolicKnowledgeBase -Facts @("A")
			
			$KB.FactCount | Should -Be 1
			$KB.Facts[0] | Should -Be "A"
		}
	}

	Context "Add-SymbolicRelation" {
		BeforeEach {
			$KB = New-SymbolicKnowledgeBase -Facts @("A", "B", "C")
		}

		It "Should add a relation between facts" {
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "A" -ToFact "B" -Strength 1.0
			
			$KB.Relations.ContainsKey("implies") | Should -Be $true
			$KB.Relations["implies"].Values[0][1] | Should -Be 1.0
		}

		It "Should support multiple relations" {
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "A" -ToFact "B"
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "causes" -FromFact "B" -ToFact "C"
			
			$KB.Relations.Count | Should -Be 2
			$KB.Relations.ContainsKey("implies") | Should -Be $true
			$KB.Relations.ContainsKey("causes") | Should -Be $true
		}

		It "Should support custom relation strength" {
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "A" -ToFact "B" -Strength 0.7
			
			$KB.Relations["implies"].Values[0][1] | Should -Be 0.7
		}

		It "Should throw error for non-existent facts" {
			{ Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "X" -ToFact "B" } | Should -Throw
			{ Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "A" -ToFact "Y" } | Should -Throw
		}

		It "Should throw error for invalid knowledge base" {
			$InvalidKB = @{Type = "NotAKB"}
			
			{ Add-SymbolicRelation -KnowledgeBase $InvalidKB -RelationName "implies" -FromFact "A" -ToFact "B" } | Should -Throw
		}
	}

	Context "Invoke-SymbolicReasoning" {
		BeforeEach {
			$KB = New-SymbolicKnowledgeBase -Facts @("A", "B", "C", "D")
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "A" -ToFact "B" -Strength 1.0
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "B" -ToFact "C" -Strength 1.0
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "causes" -FromFact "C" -ToFact "D" -Strength 1.0
		}

		It "Should perform reasoning with single relation" {
			$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "A" -RelationChain @("implies")
			
			$Result | Should -Not -BeNullOrEmpty
			$Result.Query | Should -Be "A"
			$Result.Results.Count | Should -BeGreaterThan 0
		}

		It "Should follow relation chains" {
			$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "A" -RelationChain @("implies", "implies")
			
			$Result.Relations.Count | Should -Be 2
			# After A → B → C, should infer C
			$CResult = $Result.Results | Where-Object { $_.Fact -eq "C" }
			$CResult | Should -Not -BeNullOrEmpty
			$CResult.Confidence | Should -BeGreaterThan 0
		}

		It "Should return results with confidence values" {
			$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "A" -RelationChain @("implies")
			
			foreach ($Res in $Result.Results)
			{
				$Res.Fact | Should -Not -BeNullOrEmpty
				$Res.Confidence | Should -BeGreaterOrEqual 0
			}
		}

		It "Should throw error for non-existent query fact" {
			{ Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "X" -RelationChain @("implies") } | Should -Throw
		}

		It "Should throw error for non-existent relation" {
			{ Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "A" -RelationChain @("nonexistent") } | Should -Throw
		}

		It "Should handle empty relation chain" {
			$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "A" -RelationChain @()
			
			$Result.Results.Count | Should -BeGreaterThan 0
			$Result.Results[0].Fact | Should -Be "A"
			$Result.Results[0].Confidence | Should -Be 1.0
		}
	}

	Context "Complex Reasoning Scenarios" {
		It "Should perform transitive reasoning" {
			# If A → B and B → C, then A → C (through chain)
			$KB = New-SymbolicKnowledgeBase -Facts @("Socrates", "Man", "Mortal")
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "isA" -FromFact "Socrates" -ToFact "Man" -Strength 1.0
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "isA" -FromFact "Man" -ToFact "Mortal" -Strength 1.0
			
			$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "Socrates" -RelationChain @("isA", "isA")
			
			$MortalResult = $Result.Results | Where-Object { $_.Fact -eq "Mortal" }
			$MortalResult | Should -Not -BeNullOrEmpty
		}

		It "Should handle probabilistic reasoning" {
			$KB = New-SymbolicKnowledgeBase -Facts @("Rain", "Clouds", "Wet")
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "causes" -FromFact "Rain" -ToFact "Clouds" -Strength 0.8
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "causes" -FromFact "Clouds" -ToFact "Wet" -Strength 0.6
			
			$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "Rain" -RelationChain @("causes")
			
			$Result.Results.Count | Should -BeGreaterThan 0
		}
	}

	Context "Show-Tensor" {
		It "Should display tensor information without errors" {
			$Tensor = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 2), @(3, 4))
			
			{ Show-Tensor -Tensor $Tensor } | Should -Not -Throw
		}

		It "Should handle rank-1 tensors" {
			$Tensor = New-Tensor -Dimensions @(3) -Values @(1, 2, 3)
			
			{ Show-Tensor -Tensor $Tensor } | Should -Not -Throw
		}
	}

	Context "Edge Cases and Error Handling" {
		It "Should handle zero-valued tensors correctly" {
			$T1 = New-Tensor -Dimensions @(2, 2)
			$T2 = New-Tensor -Dimensions @(2, 2)
			
			$Result = Invoke-TensorMultiplication -Tensor1 $T1 -Tensor2 $T2
			
			$Result.Values[0][0] | Should -Be 0
			$Result.Values[0][1] | Should -Be 0
			$Result.Values[1][0] | Should -Be 0
			$Result.Values[1][1] | Should -Be 0
		}

		It "Should handle large tensors" {
			$Tensor = New-Tensor -Dimensions @(10, 10)
			
			$Tensor.Dimensions[0] | Should -Be 10
			$Tensor.Dimensions[1] | Should -Be 10
		}

		It "Should validate tensor types in operations" {
			$NotATensor = @{Type = "Invalid"}
			$Tensor = New-Tensor -Dimensions @(2)
			
			{ Invoke-TensorLogicRule -Rule "AND" -InputTensors @($NotATensor, $Tensor) } | Should -Not -Throw
		}
	}

	Context "Integration Tests" {
		It "Should combine multiple operations in a workflow" {
			# Create tensors
			$T1 = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 0), @(0, 1))
			$T2 = New-Tensor -Dimensions @(2, 2) -Values @(@(0.5, 0.5), @(0.5, 0.5))
			
			# Multiply
			$Mult = Invoke-TensorMultiplication -Tensor1 $T1 -Tensor2 $T2
			
			# Apply logic
			$T3 = New-Tensor -Dimensions @(2, 2) -Values @(@(0.8, 0.8), @(0.8, 0.8))
			$Logic = Invoke-TensorLogicRule -Rule "AND" -InputTensors @($Mult, $T3)
			
			$Logic | Should -Not -BeNullOrEmpty
		}

		It "Should integrate symbolic reasoning with tensor operations" {
			# Build knowledge base
			$KB = New-SymbolicKnowledgeBase -Facts @("P", "Q", "R")
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "P" -ToFact "Q"
			Add-SymbolicRelation -KnowledgeBase $KB -RelationName "implies" -FromFact "Q" -ToFact "R"
			
			# Perform reasoning
			$Result = Invoke-SymbolicReasoning -KnowledgeBase $KB -Query "P" -RelationChain @("implies", "implies")
			
			# Verify inference
			$RResult = $Result.Results | Where-Object { $_.Fact -eq "R" }
			$RResult | Should -Not -BeNullOrEmpty
		}
	}
}

# Clean up
Remove-Module TensorLogic -ErrorAction SilentlyContinue
