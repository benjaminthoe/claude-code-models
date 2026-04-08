#!/usr/bin/env bash
set -euo pipefail

# ============================================================
#  Benjamin Thoe — Personal Website Deployment
#  AWS S3 + CloudFront (one-command deploy)
# ============================================================

STACK_NAME="benjamin-thoe-website"
REGION="${AWS_REGION:-us-east-1}"
TEMPLATE="infra/cloudformation.yaml"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
DIM='\033[0;90m'
NC='\033[0m'

log()  { echo -e "${BLUE}▸${NC} $1"; }
ok()   { echo -e "${GREEN}✓${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1" >&2; }

# ── Pre-flight checks ──────────────────────────────────────
command -v aws >/dev/null 2>&1 || { err "AWS CLI not found. Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"; exit 1; }
aws sts get-caller-identity >/dev/null 2>&1 || { err "AWS credentials not configured. Run: aws configure"; exit 1; }

# ── Parse args ──────────────────────────────────────────────
DOMAIN=""
CERT_ARN=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --domain)  DOMAIN="$2"; shift 2 ;;
        --cert)    CERT_ARN="$2"; shift 2 ;;
        --region)  REGION="$2"; shift 2 ;;
        --destroy) DESTROY=1; shift ;;
        *)         shift ;;
    esac
done

# ── Destroy mode ────────────────────────────────────────────
if [[ "${DESTROY:-0}" == "1" ]]; then
    log "Destroying stack ${STACK_NAME}..."
    BUCKET=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" \
        --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' --output text 2>/dev/null || true)
    if [[ -n "$BUCKET" ]]; then
        log "Emptying bucket: $BUCKET"
        aws s3 rm "s3://${BUCKET}" --recursive --region "$REGION"
    fi
    aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION"
    aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION"
    ok "Stack destroyed."
    exit 0
fi

# ── Deploy CloudFormation ───────────────────────────────────
log "Deploying infrastructure to ${REGION}..."

PARAMS="ParameterKey=DomainName,ParameterValue=${DOMAIN} ParameterKey=CertificateArn,ParameterValue=${CERT_ARN}"

aws cloudformation deploy \
    --template-file "$TEMPLATE" \
    --stack-name "$STACK_NAME" \
    --parameter-overrides $PARAMS \
    --region "$REGION" \
    --no-fail-on-empty-changeset

ok "Infrastructure deployed."

# ── Get outputs ─────────────────────────────────────────────
OUTPUTS=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" \
    --query 'Stacks[0].Outputs')

BUCKET=$(echo "$OUTPUTS" | python3 -c "import sys,json; o={i['OutputKey']:i['OutputValue'] for i in json.load(sys.stdin)}; print(o['BucketName'])")
DIST_ID=$(echo "$OUTPUTS" | python3 -c "import sys,json; o={i['OutputKey']:i['OutputValue'] for i in json.load(sys.stdin)}; print(o['DistributionId'])")
SITE_URL=$(echo "$OUTPUTS" | python3 -c "import sys,json; o={i['OutputKey']:i['OutputValue'] for i in json.load(sys.stdin)}; print(o['WebsiteURL'])")

# ── Upload files to S3 ─────────────────────────────────────
log "Uploading website to S3..."

aws s3 sync . "s3://${BUCKET}" \
    --region "$REGION" \
    --delete \
    --exclude ".*" \
    --exclude "infra/*" \
    --exclude "deploy.sh" \
    --exclude "README.md" \
    --exclude "SpeakerSwap/*" \
    --exclude "SpeedBoost/*" \
    --exclude "ppt-engine/*" \
    --exclude "ppt-studio-src/*" \
    --exclude "AI-Image-Prompt-Engineering-Guide.md" \
    --exclude "apple-scroll-animation-techniques.html" \
    --include "index.html" \
    --cache-control "public, max-age=3600, s-maxage=86400"

ok "Files uploaded."

# ── Invalidate CloudFront cache ─────────────────────────────
log "Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
    --distribution-id "$DIST_ID" \
    --paths "/*" \
    --region "$REGION" > /dev/null

ok "Cache invalidated."

# ── Done ────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Deployment complete!${NC}"
echo -e "${DIM}  URL: ${NC}${SITE_URL}"
echo -e "${DIM}  S3:  ${NC}${BUCKET}"
echo -e "${DIM}  CDN: ${NC}${DIST_ID}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
