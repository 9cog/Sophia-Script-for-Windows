# TensorLogic Module

## Overview

The TensorLogic module brings neural-symbolic AI integration to PowerShell, implementing core concepts from [Tensor Logic](https://tensor-logic.org/) as described by Pedro Domingos and expanded upon in [Ben Goertzel's work on bridging neural and symbolic AI](https://bengoertzel.substack.com/p/tensor-logic-for-bridging-neural).

## Key Features

- **Tensor Operations**: Create and manipulate multi-dimensional tensors
- **Logical Reasoning**: Apply logical rules (AND, OR, NOT, IMPLIES) over tensor representations
- **Symbolic Knowledge Base**: Encode facts and relations as tensors
- **Neural-Symbolic Bridge**: Perform reasoning that combines symbolic logic with continuous neural-like computations
- **Inference Engine**: Chain relations and perform multi-step reasoning

## Installation

Import the module:

```powershell
Import-Module .\src\TensorLogic\Module\TensorLogic.psm1
```

## Quick Start

### Creating Tensors

```powershell
# Create a 2x3 tensor initialized with zeros
$tensor = New-Tensor -Dimensions @(2, 3)

# Create a tensor with custom values
$values = @(@(1, 2), @(3, 4))
$tensor = New-Tensor -Dimensions @(2, 2) -Values $values
```

### Tensor Operations

```powershell
# Matrix multiplication
$t1 = New-Tensor -Dimensions @(2, 2) -Values @(@(1, 2), @(3, 4))
$t2 = New-Tensor -Dimensions @(2, 2) -Values @(@(2, 0), @(1, 2))
$result = Invoke-TensorMultiplication -Tensor1 $t1 -Tensor2 $t2
```

### Logical Operations

```powershell
# Logical AND (fuzzy min)
$t1 = New-Tensor -Dimensions @(3) -Values @(0.8, 0.5, 0.3)
$t2 = New-Tensor -Dimensions @(3) -Values @(0.6, 0.9, 0.4)
$result = Invoke-TensorLogicRule -Rule "AND" -InputTensors @($t1, $t2)

# Logical NOT
$t = New-Tensor -Dimensions @(3) -Values @(1, 0, 0.5)
$result = Invoke-TensorLogicRule -Rule "NOT" -InputTensors @($t)

# Logical IMPLIES
$result = Invoke-TensorLogicRule -Rule "IMPLIES" -InputTensors @($t1, $t2)
```

### Symbolic Reasoning

```powershell
# Create a knowledge base
$kb = New-SymbolicKnowledgeBase -Facts @("Socrates", "Man", "Mortal")

# Add relations
Add-SymbolicRelation -KnowledgeBase $kb -RelationName "isA" -FromFact "Socrates" -ToFact "Man" -Strength 1.0
Add-SymbolicRelation -KnowledgeBase $kb -RelationName "isA" -FromFact "Man" -ToFact "Mortal" -Strength 1.0

# Perform reasoning
$result = Invoke-SymbolicReasoning -KnowledgeBase $kb -Query "Socrates" -RelationChain @("isA", "isA")
# Result: Socrates → Man → Mortal
```

## Functions

### Core Tensor Operations

- **`New-Tensor`**: Create a new tensor with specified dimensions
- **`Invoke-TensorMultiplication`**: Perform Einstein summation (matrix multiplication)
- **`Invoke-TensorLogicRule`**: Apply logical rules (AND, OR, NOT, IMPLIES)

### Neural-Symbolic Bridge

- **`New-SymbolicKnowledgeBase`**: Create a knowledge base for facts
- **`Add-SymbolicRelation`**: Add relations between facts with configurable strength
- **`Invoke-SymbolicReasoning`**: Perform multi-step reasoning over relation chains

### Utility Functions

- **`Show-Tensor`**: Display tensor information for debugging
- **`Get-TensorLogicVersion`**: Get module version and reference information

## Examples

### Example 1: Probabilistic Reasoning

```powershell
$kb = New-SymbolicKnowledgeBase -Facts @("Rain", "Clouds", "Wet")
Add-SymbolicRelation -KnowledgeBase $kb -RelationName "causes" -FromFact "Rain" -ToFact "Clouds" -Strength 0.8
Add-SymbolicRelation -KnowledgeBase $kb -RelationName "causes" -FromFact "Clouds" -ToFact "Wet" -Strength 0.6

$result = Invoke-SymbolicReasoning -KnowledgeBase $kb -Query "Rain" -RelationChain @("causes", "causes")
# Infers that Rain leads to Wet through Clouds with probabilistic confidence
```

### Example 2: Logical Inference

```powershell
# Classical syllogism: All men are mortal, Socrates is a man, therefore Socrates is mortal
$kb = New-SymbolicKnowledgeBase -Facts @("Socrates", "Man", "Mortal")
Add-SymbolicRelation -KnowledgeBase $kb -RelationName "isA" -FromFact "Socrates" -ToFact "Man" -Strength 1.0
Add-SymbolicRelation -KnowledgeBase $kb -RelationName "isA" -FromFact "Man" -ToFact "Mortal" -Strength 1.0

$result = Invoke-SymbolicReasoning -KnowledgeBase $kb -Query "Socrates" -RelationChain @("isA", "isA")
$mortalResult = $result.Results | Where-Object { $_.Fact -eq "Mortal" }
Write-Host "Socrates is mortal with confidence: $($mortalResult.Confidence)"
```

### Example 3: Tensor Logic Operations

```powershell
# Fuzzy logic reasoning
$premise1 = New-Tensor -Dimensions @(3) -Values @(0.9, 0.7, 0.5)  # "It's cloudy"
$premise2 = New-Tensor -Dimensions @(3) -Values @(0.8, 0.6, 0.4)  # "Barometer falling"

# Combine evidence using AND
$combined = Invoke-TensorLogicRule -Rule "AND" -InputTensors @($premise1, $premise2)
Show-Tensor -Tensor $combined
# Result shows combined confidence in rain prediction
```

## Theoretical Background

Tensor Logic unifies neural and symbolic AI by representing both logical rules and neural network operations as tensor equations. This module implements:

1. **Tensor Representation**: Facts and rules encoded as multi-dimensional arrays
2. **Fuzzy Logic**: Continuous truth values (0.0 to 1.0) instead of binary true/false
3. **Relational Reasoning**: Matrix operations represent logical inference
4. **Compositionality**: Chain multiple reasoning steps through matrix multiplication

## Testing

Run the comprehensive test suite:

```powershell
# Using Pester
Install-Module -Name Pester -Force -SkipPublisherCheck
Invoke-Pester -Path .\tests\TensorLogic.Tests.ps1
```

The test suite includes:
- Unit tests for all functions
- Integration tests for complex workflows
- Edge case and error handling tests
- Performance validation

## References

- [Tensor Logic Official Website](https://tensor-logic.org/)
- [Ben Goertzel on Neural-Symbolic Integration](https://bengoertzel.substack.com/p/tensor-logic-for-bridging-neural)
- [Pedro Domingos - Tensor Logic: The Language of AI](https://arxiv.org/abs/2510.12269)

## Version

**Version**: 1.0.0  
**Date**: 13.01.2026  
**Author**: Team Sophia

## License

Copyright (c) 2026 Team Sophia. All rights reserved.

This module is part of the Sophia Script for Windows project.
