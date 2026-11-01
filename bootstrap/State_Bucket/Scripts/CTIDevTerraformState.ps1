
$Bucket = "cti-terraform-state-dev-ca-central-1"
$Region = "ca-central-1"
$Account = "959856141465"

# Confirm the AWS account
$CurrentAccount = aws sts get-caller-identity `
  --query Account --output text

if ($LASTEXITCODE -ne 0 -or $CurrentAccount -ne $Account) {
    throw "Wrong AWS account or AWS login failed."
}

# Create bucket
aws s3api create-bucket `
  --bucket $Bucket `
  --region $Region `
  --create-bucket-configuration "LocationConstraint=$Region"

if ($LASTEXITCODE -ne 0) {
    throw "S3 bucket creation failed. Check whether it already exists."
}

# Enable versioning
aws s3api put-bucket-versioning `
  --bucket $Bucket `
  --versioning-configuration "Status=Enabled"

if ($LASTEXITCODE -ne 0) { throw "Versioning failed." }

# Block public access
aws s3api put-public-access-block `
  --bucket $Bucket `
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

if ($LASTEXITCODE -ne 0) { throw "Public access configuration failed." }

# Enable SSE-S3 encryption
$Encryption = '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
$Encryption | Set-Content "$env:TEMP\cti-encryption.json" -Encoding ascii

aws s3api put-bucket-encryption `
  --bucket $Bucket `
  --server-side-encryption-configuration "file://$env:TEMP\cti-encryption.json"

if ($LASTEXITCODE -ne 0) { throw "Encryption configuration failed." }

Write-Host "CTI production state bucket created and secured." -ForegroundColor Green