@{
	RootModule = '..\Module\TensorLogic.psm1'
	ModuleVersion = '1.0.0'
	GUID = 'a7c8f5d3-9e2b-4f6a-8c1d-3e4f5a6b7c8d'
	Author = 'Team Sophia'
	CompanyName = 'Team Sophia'
	Copyright = '(c) 2026 Team Sophia. All rights reserved.'
	Description = 'TensorLogic Module - Neural-Symbolic Integration for PowerShell. Implements core Tensor Logic concepts based on https://tensor-logic.org/'
	PowerShellVersion = '5.1'
	FunctionsToExport = @(
		'New-Tensor',
		'Invoke-TensorMultiplication',
		'Invoke-TensorLogicRule',
		'New-SymbolicKnowledgeBase',
		'Add-SymbolicRelation',
		'Invoke-SymbolicReasoning',
		'Show-Tensor',
		'Get-TensorLogicVersion'
	)
	CmdletsToExport = @()
	VariablesToExport = @()
	AliasesToExport = @()
	PrivateData = @{
		PSData = @{
			Tags = @('TensorLogic', 'AI', 'NeuralSymbolic', 'MachineLearning', 'Reasoning')
			LicenseUri = 'https://github.com/farag2/Sophia-Script-for-Windows/blob/master/LICENSE'
			ProjectUri = 'https://github.com/farag2/Sophia-Script-for-Windows'
			ReleaseNotes = 'Initial release of TensorLogic module implementing neural-symbolic integration concepts'
		}
	}
}
