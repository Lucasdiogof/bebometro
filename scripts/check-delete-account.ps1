# Checks that the delete-account Edge Function accepts a REAL session, without
# deleting anything (it sends {"dry_run": true}). Run it with YOUR OWN account:
#   powershell -File scripts/check-delete-account.ps1
# The e-mail and password are asked here, used for one sign-in request to the
# project below and never written to disk. Expected result: ok=True, dry_run=True.
param(
  [string]$ProjectRef = 'jiisoqkryhmtopaojyyu',
  [string]$PublishableKey = 'sb_publishable_DBavx37FFp9AjNIsovmnIQ_7XVYlPBa'
)

$base = "https://$ProjectRef.supabase.co"
Write-Host "Target project: $ProjectRef"
$email = Read-Host 'E-mail of your own Bebometro account'
$secure = Read-Host 'Password' -AsSecureString
$password = [System.Net.NetworkCredential]::new('', $secure).Password

$login = Invoke-RestMethod -Method Post -Uri "$base/auth/v1/token?grant_type=password" `
  -Headers @{ apikey = $PublishableKey } -ContentType 'application/json' `
  -Body (@{ email = $email; password = $password } | ConvertTo-Json)
$password = $null

try {
  $res = Invoke-RestMethod -Method Post -Uri "$base/functions/v1/delete-account" `
    -Headers @{ apikey = $PublishableKey; Authorization = "Bearer $($login.access_token)" } `
    -ContentType 'application/json' -Body '{"dry_run": true}'
  Write-Host ("Function answered: " + ($res | ConvertTo-Json -Compress))
} catch {
  Write-Host ("Function refused: HTTP " + [int]$_.Exception.Response.StatusCode)
}
