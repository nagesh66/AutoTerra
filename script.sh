export ORGANIZATION_ID=694849223307
export PROJECT_ID=nagesh-sandbox
export PROJECT_NUMBER=1081352067477
export REGION= us-central1-a
export SERVICE_ACCOUNT_NAME= auto-terra
export BUCKET_NAME= auto-tera-state1232311

# Create Bucket to store terraform state backend files.
gcloud storage buckets create gs://$BUCKET_NAME --location=$REGION

# Commands to create Service Account and garnt following permissions to Service account at Org level for WIF
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
  --description="This is for Just-In-Time Access" \
  --display-name="auto-terra"

# gcloud organizations add-iam-policy-binding $ORGANIZATION_ID \
#   --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
#   --role="roles/iam.securityAdmin"

gcloud organizations add-iam-policy-binding $ORGANIZATION_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

gcloud organizations add-iam-policy-binding $ORGANIZATION_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser"

gcloud organizations add-iam-policy-binding $ORGANIZATION_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectUser"

gcloud iam workload-identity-pools create "66deg-auto-wip" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Actions Pool"

gcloud iam workload-identity-pools providers create-oidc "jit-access" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="66deg-auto-wip" \
  --display-name="My GitHub repo Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --issuer-uri="https://token.actions.githubusercontent.com"

gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT_NAME@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/66deg-auto-wip/attribute.repository/66degrees/AutoTerra"