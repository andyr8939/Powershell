<#
        .SYNOPSIS
        Switch Terraform versions based on already downloded versions.

        .DESCRIPTION
        Switch Terraform versions easily to an alternative versions.
        TODO: Add ability to download if version not found

        .EXAMPLE
        PS> .\Set-Terraform.ps1 118

        .NOTES
        Created By - Andy Roberts - andyr8939@gmail.com
        Last Updated - 10th October 2021
        Maintained - https://github.com/andyr8939/azure
#>

$terraformversion=$args[0]
$terrapath = "~\terraform"

if ($terraformversion -eq '012') {
    $newversion = "12-28"
    Write-Host "Setting Terraform to $newversion"
}
 elseif ($terraformversion -eq '013') {
    $newversion = "13-6"
    Write-Host "Setting Terraform to $newversion"
 }
 elseif ($terraformversion -eq '014') {
    $newversion = "14-10"
    Write-Host "Setting Terraform to $newversion"
 }
 elseif ($terraformversion -eq '015') {
    $newversion = "15-1"
    Write-Host "Setting Terraform to $newversion"
 }
  elseif ($terraformversion -eq '102') {
    $newversion = "1-02"
    Write-Host "Setting Terraform to $newversion"
 }
  elseif ($terraformversion -eq '106') {
    $newversion = "1-06"
    Write-Host "Setting Terraform to $newversion"
 }
  elseif ($terraformversion -eq '107') {
    $newversion = "1-07"
    Write-Host "Setting Terraform to $newversion"
 }
  elseif ($terraformversion -eq '114') {
    $newversion = "1-14"
    Write-Host "Setting Terraform to $newversion"
 }
  elseif ($terraformversion -eq '116') {
    $newversion = "1-16"
    Write-Host "Setting Terraform to $newversion"
 }
  elseif ($terraformversion -eq '118') {
    $newversion = "1-18"
    Write-Host "Setting Terraform to $newversion"
 }

Remove-Item $terrapath\terraform.exe -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

Copy-Item $terrapath\terraform-$($newversion).exe $terrapath\terraform.exe

terraform.exe version
