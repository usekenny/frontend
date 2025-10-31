# =============================================================================
# DATA SOURCE - Récupérer l'App ID Amplify existant par nom
# =============================================================================

data "external" "amplify_app_id" {
  program = ["bash", "-c", <<EOF
APP_NAME="${var.profile}-${var.project_name}"
APP_ID=$(aws amplify list-apps --query "apps[?name=='$APP_NAME'].appId" --output text)
if [ "$APP_ID" = "None" ] || [ -z "$APP_ID" ]; then
  echo '{"app_id": ""}' 
else
  echo "{\"app_id\": \"$APP_ID\"}"
fi
EOF
  ]

  # S'assurer que l'app Amplify est créée avant de récupérer son ID
  depends_on = [module.app]
}

module "app" {
  source = "github.com/kodylabs/terraform-resources//amplify-nextjs?ref=main"

  compute_role_arn = aws_iam_role.amplify_ssr_role.arn

  project_name           = var.project_name
  repo_url               = "https://github.com/Sendo-labs/frontend"
  oauth_token            = var.github_pat
  build_spec_path        = "${path.module}/amplify.yml"
  profile                = var.profile
  is_roots_domain        = true
  sub_domain             = null
  sub_sub_domain         = null
  enable_basic_auth      = false
  basic_auth_credentials = null
  root_domains = [
    "sendo.market",
  ]
  environment_variables = {
    _CUSTOM_IMAGE                = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-3.amazonaws.com/bun:latest"
    NEXT_PUBLIC_ELIZA_SERVER_URL = "exemple"
  }
  secrets = {
    NEXT_PUBLIC_ELIZA_SERVER_AUTH_TOKEN = {
      value       = var.next_public_eliza_server_auth_token
      description = "Eliza server auth token"
    }
    NEXT_PUBLIC_PRIVY_APP_ID = {
      value       = var.next_public_privy_app_id
      description = "Privy app ID"
    }
    PRIVY_APP_ID = {
      value       = var.privy_app_id
      description = "Privy app secret"
    }
    PRIVY_APP_SECRET = {
      value       = var.privy_app_secret
      description = "Custom image"
    }
  }
  branch_name = "main"
  environment = var.profile

  tags = merge(local.common_tags, {
    Project     = var.project_name
    Environment = var.profile
    CreatedBy   = "kenny"
    ManagedBy   = "terraform"
    UpdatedAt   = timestamp()
  })
}
