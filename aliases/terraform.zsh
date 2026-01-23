# ========================================
# Terraform
# ========================================
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfaa="terraform apply -auto-approve"
alias tfd="terraform destroy"
alias tfda="terraform destroy -auto-approve"
alias tfv="terraform validate"
alias tff="terraform fmt"
alias tffr="terraform fmt -recursive"
alias tfs="terraform state"
alias tfsl="terraform state list"
alias tfss="terraform state show"
alias tfo="terraform output"
alias tfw="terraform workspace"
alias tfwl="terraform workspace list"
alias tfws="terraform workspace select"
alias tfwn="terraform workspace new"
alias tfr="terraform refresh"
alias tfg="terraform graph"

# ========================================
# AWS
# ========================================
alias awswho="aws sts get-caller-identity"
alias awsregions="aws ec2 describe-regions --output table"
alias awsprofile="export AWS_PROFILE="  # 使用例: awsprofile dev
