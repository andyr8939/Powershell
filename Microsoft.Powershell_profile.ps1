# My Powershell Profile

Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme hotstick.minimal
Import-Module ~\Documents\Powershell\Get-AndyURLHealthCheck.psm1
Set-PSReadLineOption -PredictionSource History

# Creating some aliases for most commonly used commands
function terraforminit { terraform init }
function terraformvalidate { terraform validate }
function terraformplan { terraform plan }
function terraformapply { terraform apply }
set-alias -Name ti -Value terraforminit
set-alias -Name tv -Value terraformvalidate
set-alias -Name tp -Value terraformplan
set-alias -Name ta -Value terraformapply
set-alias -Name k -Value kubectl
function gitadd {
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string[]]
        $Path
    )
    git add $Path
}
function gitstatus { git status }
function gitcommit { git commit -m }
function gitcommit {
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string[]]
        $CommitMessage
    )
    git commit -m $CommitMessage
}

function gitpush { git push }
set-alias -Name ga -Value gitadd
set-alias -Name gs -Value gitstatus
set-alias -Name gco -Value gitcommit
set-alias -Name gpu -Value gitpush
Set-Location -Path ~
