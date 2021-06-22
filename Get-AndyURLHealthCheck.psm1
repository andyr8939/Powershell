<#
        .SYNOPSIS
        Runs a continous web check for a URL and exports some metrics

        .DESCRIPTION
        Check a URL on a defined frequency and timeout and get some summary metrics back
        
        .PARAMETER url
        The URL of the website to check

        .PARAMETER frequency
        How often to check the URL

        .PARAMETER timeout
        The timeout of the URL check

        .OUTPUTS
        System.String.

        .EXAMPLE
        PS>  Get-AndyURLHealthCheck -url https://andytestweb.azurewebsites.net -frequency 2 -timeout 5
             12:04:03 - 200 - <!DOCTYPE html><html  - 123.9ms
             12:04:05 - 200 - <!DOCTYPE html><html  - 124.9ms
             12:04:07 - 200 - <!DOCTYPE html><html  - 129.9ms
             12:06:28 - 403 - ï»¿<!DOCTYPE html>< - 127.4ms
             12:06:30 - 503 - 8310111411810599101328511097118971051089798108101 - 181.9ms

    #>

function Get-AndyURLHealthCheck {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$url,
        [Parameter()]
        [int]$frequency = 5,
        [Parameter()]
        [int]$timeout = 5
    )

    while ($true) {
        $timeTaken = Measure-Command -Expression {
            $site = (Invoke-WebRequest $url -TimeoutSec $timeout)
        }
        # $content = ($site.Content)[0..20] -join ""
        $content = ($site.Content)[0..10] -join ""
        $time = Get-Date -Format "HH:mm:ss"
        $milliseconds = $timeTaken.TotalMilliseconds
        $milliseconds = [Math]::Round($milliseconds, 1)
        Write-Output "$time - $($site.StatusCode) - $content - $($milliseconds)ms"
        Start-Sleep $frequency
    }  
}
