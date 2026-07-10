# Panduan Lengkap Deploy Aplikasi ke Google Cloud Platform (GCP)

> **Tanggal**: Juli 2026
> **Tujuan**: Panduan step-by-step komprehensif untuk mendeploy aplikasi ke GCP
> **Cakupan**: Cloud Run, Compute Engine, GKE, App Engine, CI/CD, Secrets, Terraform

---

## Daftar Isi

1. [Prasyarat](#1-prasyarat)
2. [Setup Awal GCP](#2-setup-awal-gcp)
3. [Instalasi & Konfigurasi Google Cloud SDK](#3-instalasi--konfigurasi-google-cloud-sdk)
4. [Identity & Access Management (IAM)](#4-identity--access-management-iam)
5. [Opsi Deployment](#5-opsi-deployment)
   - [5.1 Cloud Run (Serverless Containers)](#51-cloud-run-serverless-containers)
   - [5.2 Compute Engine (VM)](#52-compute-engine-vm)
   - [5.3 Google Kubernetes Engine (GKE)](#53-google-kubernetes-engine-gke)
   - [5.4 App Engine (PaaS)](#54-app-engine-paas)
6. [CI/CD dengan Cloud Build](#6-cicd-dengan-cloud-build)
7. [Secrets Management dengan Secret Manager](#7-secrets-management-dengan-secret-manager)
8. [Infrastructure as Code dengan Terraform](#8-infrastructure-as-code-dengan-terraform)
9. [Monitoring & Logging](#9-monitoring--logging)
10. [Best Practices & Keamanan](#10-best-practices--keamanan)
11. [Troubleshooting Umum](#11-troubleshooting-umum)

---

## 1. Prasyarat

Sebelum memulai, pastikan Anda memiliki:

- **Akun Google** (Gmail/Google Workspace)
- **Kartu Kredit/Rekening** untuk verifikasi billing (GCP menawarkan **$300 free credit**)
- **Domain** (opsional, untuk custom domain)
- **Docker** (untuk deployment container) — install dari [docker.com](https://docker.com)
- **Git** (untuk CI/CD) — `winget install git` atau dari [git-scm.com](https://git-scm.com)

---

## 2. Setup Awal GCP

### 2.1 Buat Akun GCP

1. Buka [console.cloud.google.com](https://console.cloud.google.com)
2. Klik **"Create Account"** / **"Free Trial"**
3. Ikuti wizard: setujui terms, masukkan detail billing
   - Anda tetap mendapat **$300 credit** selama 90 hari + **20+ produk gratis selamanya**
4. Setelah selesai, Anda masuk ke **Google Cloud Console**

### 2.2 Buat Project

Project adalah wadah semua resource GCP Anda.

**Via Console:**
1. Di console, klik dropdown project (atas) → **New Project**
2. Masukkan **Project name** (contoh: `konect-app`)
3. **Project ID** akan tergenerate otomatis (contoh: `konect-app-123456`) — catat ini
4. Klik **Create**

**Via gcloud CLI (setelah SDK terinstal):**
```bash
gcloud projects create KONECT-PROJECT --name="Konect App"
```

### 2.3 Aktifkan Billing

1. Di Console, buka **Billing** → **Link a billing account**
2. Buat billing account baru atau link ke yang sudah ada
3. Tanpa billing aktif, Anda tidak bisa menggunakan layanan GCP (kecuali free tier terbatas)

### 2.4 Aktifkan API yang Dibutuhkan

Setiap layanan GCP butuh API diaktifkan per project.

**Cloud Run + Cloud Build + Artifact Registry:**
```bash
gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  --project=PROJECT_ID
```

**Compute Engine:**
```bash
gcloud services enable compute.googleapis.com --project=PROJECT_ID
```

**GKE:**
```bash
gcloud services enable container.googleapis.com --project=PROJECT_ID
```

---

## 3. Instalasi & Konfigurasi Google Cloud SDK

### 3.1 Install gcloud CLI

**Windows (PowerShell):**
```powershell
(New-Object Net.WebClient).DownloadFile(
  "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe",
  "$env:Temp\GoogleCloudSDKInstaller.exe"
)
& $env:Temp\GoogleCloudSDKInstaller.exe
```
Jalankan installer dan ikuti wizard.

**macOS/Linux:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

**Verifikasi instalasi:**
```bash
gcloud --version
```

### 3.2 Inisialisasi & Autentikasi

```bash
gcloud init
```
Perintah interaktif ini akan:
1. Meminta login ke akun Google Anda (buka browser)
2. Memilih project default
3. Memilih region/zone default (contoh: `asia-southeast1` untuk Jakarta/Singapura)

Atau jalankan terpisah:
```bash
gcloud auth login          # Login user account
gcloud config set project PROJECT_ID
gcloud config set compute/region asia-southeast1
gcloud config set compute/zone asia-southeast1-a
```

### 3.3 Verifikasi Setup

```bash
gcloud info              # Tampilkan config
gcloud auth list         # Lihat account aktif
gcloud config list       # Lihat konfigurasi
gcloud compute zones list  # Tes akses API
```

---

## 4. Identity & Access Management (IAM)

IAM mengontrol **siapa** (identity) punya **akses apa** (role) ke **resource mana**.

### 4.1 Konsep Dasar IAM

| Istilah | Penjelasan |
|---------|-----------|
| **Principal** | User, group, service account (siapa) |
| **Role** | Kumpulan permissions (apa yang bisa dilakukan) |
| **Policy** | Binding antara principal + role + resource |
| **Service Account** | Identity untuk aplikasi/bukan manusia |

### 4.2 Service Account untuk Aplikasi

Service account adalah identity untuk aplikasi Anda. **Jangan gunakan user account untuk produksi.**

```bash
# Buat service account
gcloud iam service-accounts create konect-app-sa \
  --display-name="Konect App Service Account"

# Grant roles minimal
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:konect-app-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.invoker"

# Buat dan download key (JSON) — simpan aman!
gcloud iam service-accounts keys create ./sa-key.json \
  --iam-account=konect-app-sa@PROJECT_ID.iam.gserviceaccount.com
```

### 4.3 Roles yang Sering Digunakan

| Role | Kegunaan |
|------|----------|
| `roles/run.admin` | Admin Cloud Run |
| `roles/run.invoker` | Bisa invoke Cloud Run service |
| `roles/compute.instanceAdmin` | Admin Compute Engine VM |
| `roles/container.clusterAdmin` | Admin GKE cluster |
| `roles/cloudbuild.builds.editor` | Bisa submit builds |
| `roles/secretmanager.secretAccessor` | Baca secrets |
| `roles/iam.serviceAccountUser` | Bisa actAs service account |
| `roles/viewer` | Read-only semua resource |

### 4.4 Best Practices IAM

1. **Principle of Least Privilege** — beri role seminimal mungkin
2. **Gunakan Service Account** untuk aplikasi, jangan user account
3. **Jangan download key** jika tidak perlu — gunakan Workload Identity Federation
4. **Aktifkan MFA** untuk semua user
5. **Audit IAM policy** secara berkala:
   ```bash
   gcloud projects get-iam-policy PROJECT_ID
   gcloud organizations get-iam-policy ORGANIZATION_ID
   ```

---

## 5. Opsi Deployment

Berikut perbandingan opsi deployment utama di GCP:

| Kriteria | Cloud Run | Compute Engine | GKE | App Engine |
|----------|-----------|---------------|-----|------------|
| **Tipe** | Serverless (containers) | VM tradisional | Kubernetes | PaaS |
| **Skalabilitas** | Auto-scale to zero | Manual / Managed IG | Auto-scale (cluster) | Auto-scale |
| **Cold start** | ~detik (ada) | Tidak ada | Tidak ada | Minimal |
| **Cocok untuk** | API, web apps, microservices | Stateful apps, legacy | Microservices kompleks | Web apps standar |
| **Harga** | Per request + compute | Per VM (24/7) | Per node + workload | Per instance |
| **Stateful** | Tidak (stateless) | Ya | Ya (statefulset) | Terbatas |
| **Networking** | HTTP/gRPC saja | Full network | Full Kubernetes | HTTP saja |

### 5.1 Cloud Run (Serverless Containers)

**Cloud Run** adalah platform serverless untuk menjalankan container. Paling cepat dan termudah untuk deploy.

#### 5.1.1 Siapkan Aplikasi

Buat aplikasi yang listen di port dari env `PORT` (default 8080).

**Contoh Node.js (`server.js`):**
```javascript
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => res.send('Hello from Cloud Run!'));
app.get('/health', (req, res) => res.status(200).send('ok'));
app.listen(port, () => console.log(`Listening on ${port}`));
```

**Contoh Go (`main.go`):**
```go
package main

import (
    "fmt"
    "net/http"
    "os"
)

func main() {
    port := os.Getenv("PORT")
    if port == "" { port = "8080" }
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello from Cloud Run!")
    })
    http.ListenAndServe(":"+port, nil)
}
```

#### 5.1.2 Buat Dockerfile

```dockerfile
# Multi-stage build untuk ukuran kecil
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

FROM node:20-alpine
WORKDIR /app
COPY --from=build /app /app
EXPOSE 8080
CMD ["node", "server.js"]
```

#### 5.1.3 Build & Deploy ke Cloud Run

**Cara 1 — Deploy langsung dari source (termudah):**
```bash
gcloud run deploy konect-app \
  --source . \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --concurrency 80 \
  --timeout 300
```

**Cara 2 — Build dulu ke Artifact Registry:**
```bash
# Buat repository
gcloud artifacts repositories create my-app-repo \
  --repository-format=docker \
  --location=asia-southeast1

# Build dengan Cloud Build (tidak perlu Docker lokal)
gcloud builds submit --tag asia-southeast1-docker.pkg.dev/PROJECT_ID/my-app-repo/konect-app:v1

# Deploy
gcloud run deploy konect-app \
  --image asia-southeast1-docker.pkg.dev/PROJECT_ID/my-app-repo/konect-app:v1 \
  --region asia-southeast1 \
  --allow-unauthenticated
```

#### 5.1.4 Konfigurasi Cloud Run

```bash
# Set environment variables
gcloud run services update konect-app \
  --update-env-vars DB_HOST=mydb,DATABASE_URL=postgres://...

# Set secrets dari Secret Manager
gcloud run services update konect-app \
  --update-secrets=DB_PASSWORD=my-password-secret:latest

# Set service account
gcloud run services update konect-app \
  --service-account=konect-app-sa@PROJECT_ID.iam.gserviceaccount.com

# Atur scaling
gcloud run services update konect-app \
  --min-instances 1 \
  --max-instances 20

# Custom domain
gcloud beta run domain-mappings create \
  --service konect-app \
  --domain app.konect.example.com \
  --region asia-southeast1
```

#### 5.1.5 Verifikasi

```bash
# Dapatkan URL
gcloud run services describe konect-app --format="value(status.url)"

# Test
curl https://konect-app-xyz-asianortheast1.a.run.app
```

### 5.2 Compute Engine (VM)

Untuk aplikasi yang butuh kontrol penuh atas OS dan infrastruktur.

#### 5.2.1 Buat VM Instance

```bash
# Buat instance dasar
gcloud compute instances create konect-vm \
  --zone=asia-southeast1-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --boot-disk-type=pd-standard \
  --tags=http-server,https-server \
  --service-account=konect-app-sa@PROJECT_ID.iam.gserviceaccount.com

# Buat firewall rule untuk HTTP/HTTPS
gcloud compute firewall-rules create allow-http \
  --allow=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server \
  --description="Allow HTTP traffic"

gcloud compute firewall-rules create allow-https \
  --allow=tcp:443 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=https-server \
  --description="Allow HTTPS traffic"
```

#### 5.2.2 SSH & Deploy Aplikasi

```bash
# SSH ke instance
gcloud compute ssh konect-vm --zone=asia-southeast1-a

# Di dalam VM: install Node.js dan deploy
sudo apt update && sudo apt install -y nodejs npm
git clone https://github.com/your-repo/konect-app.git
cd konect-app
npm install
npm start
```

#### 5.2.3 Startup Script (Deploy Otomatis)

Buat VM dengan startup script untuk auto-deploy:

```bash
gcloud compute instances create konect-vm \
  --zone=asia-southeast1-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --metadata=startup-script='#!/bin/bash
    apt update
    apt install -y nodejs npm git
    git clone https://github.com/your-repo/konect-app.git /opt/app
    cd /opt/app && npm install
    npm install -g pm2
    pm2 start server.js
    pm2 save
    pm2 startup'
```

### 5.3 Google Kubernetes Engine (GKE)

Untuk microservices kompleks yang butuh orchestrasi penuh Kubernetes.

#### 5.3.1 Buat GKE Cluster

```bash
# Buat cluster Autopilot (managed, rekomendasi)
gcloud container clusters create-auto konect-cluster \
  --region=asia-southeast1

# Atau buat Standard cluster (lebih banyak kontrol)
gcloud container clusters create konect-cluster \
  --zone=asia-southeast1-a \
  --num-nodes=3 \
  --machine-type=e2-standard-2 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=5
```

#### 5.3.2 Konfigurasi kubectl

```bash
gcloud container clusters get-credentials konect-cluster \
  --region=asia-southeast1

# Verifikasi
kubectl get nodes
kubectl get pods --all-namespaces
```

#### 5.3.3 Deploy Aplikasi ke GKE

**Buat deployment YAML (`deployment.yaml`):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: konect-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: konect-app
  template:
    metadata:
      labels:
        app: konect-app
    spec:
      containers:
      - name: app
        image: asia-southeast1-docker.pkg.dev/PROJECT_ID/my-app-repo/konect-app:v1
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
---
apiVersion: v1
kind: Service
metadata:
  name: konect-app-service
spec:
  type: LoadBalancer
  selector:
    app: konect-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

**Deploy:**
```bash
kubectl apply -f deployment.yaml
kubectl get service konect-app-service  # Dapatkan external IP
```

### 5.4 App Engine (PaaS)

Paling sederhana — upload kode, Google urus sisanya.

#### 5.4.1 Buat app.yaml

```yaml
runtime: nodejs20
env: standard
instance_class: F1

env_variables:
  NODE_ENV: production

automatic_scaling:
  min_instances: 0
  max_instances: 10
  target_cpu_utilization: 0.8

handlers:
- url: /.*
  script: auto
  secure: always
```

#### 5.4.2 Inisialisasi & Deploy App Engine

```bash
# Inisialisasi App Engine (pertama kali)
gcloud app create --region=asia-southeast1

# Deploy
gcloud app deploy app.yaml --project=PROJECT_ID

# Lihat aplikasi
gcloud app browse
```

**Catatan**: App Engine memiliki **standard** dan **flexible environment**. Standard lebih murah dengan auto-scale, flexible bisa custom Dockerfile.

---

## 6. CI/CD dengan Cloud Build

Cloud Build adalah fully-managed CI/CD pipeline dari Google.

### 6.1 Cloud Build YAML

Buat `cloudbuild.yaml` di root project:

```yaml
steps:
  # Step 1: Build container image
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'build'
      - '-t'
      - 'asia-southeast1-docker.pkg.dev/$PROJECT_ID/my-app-repo/konect-app:$COMMIT_SHA'
      - '.'

  # Step 2: Push ke Artifact Registry
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'asia-southeast1-docker.pkg.dev/$PROJECT_ID/my-app-repo/konect-app:$COMMIT_SHA'

  # Step 3: Deploy ke Cloud Run
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - 'konect-app'
      - '--image'
      - 'asia-southeast1-docker.pkg.dev/$PROJECT_ID/my-app-repo/konect-app:$COMMIT_SHA'
      - '--region'
      - 'asia-southeast1'

# Simpan images di Artifact Registry
images:
  - 'asia-southeast1-docker.pkg.dev/$PROJECT_ID/my-app-repo/konect-app:$COMMIT_SHA'

options:
  machineType: 'E2_HIGHCPU_8'
  logging: CLOUD_LOGGING_ONLY

timeout: '1200s'
```

### 6.2 Submit Build Manual

```bash
gcloud builds submit --config cloudbuild.yaml
```

### 6.3 Trigger dari GitHub

1. Buka Console → **Cloud Build** → **Triggers** → **Create Trigger**
2. Hubungkan ke repository GitHub Anda
3. Konfigurasi:
   - **Event**: Push to branch (main)
   - **Config file**: `cloudbuild.yaml`
   - **Service account**: Pilih yang punya permission Cloud Run deploy
4. Klik **Create**

Atau via CLI:
```bash
gcloud builds triggers create github \
  --name=konect-deploy \
  --repo-owner=your-org \
  --repo-name=konect \
  --branch-pattern=^main$ \
  --build-config=cloudbuild.yaml
```

### 6.4 Approvals untuk Production

```bash
# Butuh approval sebelum deploy
gcloud builds triggers update konect-deploy --require-approval

# Approve build
gcloud builds approve BUILD_ID
```

---

## 7. Secrets Management dengan Secret Manager

Jangan pernah simpan secrets (password, API key) di kode atau environment variables yang terlihat.

### 7.1 Buat Secret

```bash
# Via file
echo -n "s3cur3-db-p@ssword" | gcloud secrets create db-password \
  --data-file=- \
  --project=PROJECT_ID

# Atau interaktif
gcloud secrets create db-password --data-file=password.txt

# Tambah version baru
echo -n "new-password-2026" | gcloud secrets versions add db-password --data-file=-
```

### 7.2 IAM untuk Secrets

```bash
# Beri akses ke service account
gcloud secrets add-iam-policy-binding db-password \
  --member="serviceAccount:konect-app-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

### 7.3 Gunakan Secrets di Cloud Run

```bash
gcloud run services update konect-app \
  --update-secrets=DB_PASSWORD=db-password:latest,DATABASE_URL=db-url:1
```

### 7.4 Akses dari Aplikasi

**Node.js:**
```javascript
const {SecretManagerServiceClient} = require('@google-cloud/secret-manager');
const client = new SecretManagerServiceClient();

async function getSecret() {
  const [version] = await client.accessSecretVersion({
    name: 'projects/PROJECT_ID/secrets/db-password/versions/latest'
  });
  return version.payload.data.toString();
}
```

**Python:**
```python
from google.cloud import secretmanager

client = secretmanager.SecretManagerServiceClient()
response = client.access_secret_version(
    request={"name": "projects/PROJECT_ID/secrets/db-password/versions/latest"}
)
password = response.payload.data.decode("UTF-8")
```

---

## 8. Infrastructure as Code dengan Terraform

Untuk mengelola infrastruktur GCP secara reproducible.

### 8.1 Setup Terraform

```bash
# Install Terraform (Windows)
winget install Hashicorp.Terraform

# atau download dari terraform.io
```

### 8.2 Contoh Terraform untuk Cloud Run

Buat `main.tf`:

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-southeast1"
}

# Enable APIs
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"
}

resource "google_project_service" "artifact_api" {
  service = "artifactregistry.googleapis.com"
}

# Artifact Registry repo
resource "google_artifact_registry_repository" "app_repo" {
  location      = var.region
  repository_id = "konect-app-repo"
  format        = "DOCKER"
  depends_on    = [google_project_service.artifact_api]
}

# Deploy Cloud Run service
resource "google_cloud_run_service" "konect_app" {
  name     = "konect-app"
  location = var.region

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.repository_id}/konect-app:latest"
        ports {
          container_port = 8080
        }
        env {
          name  = "NODE_ENV"
          value = "production"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.run_api]
}

# Allow public access
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.konect_app.location
  project  = google_cloud_run_service.konect_app.project
  service  = google_cloud_run_service.konect_app.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

# Output
output "service_url" {
  value = google_cloud_run_service.konect_app.status[0].url
}
```

Buat `terraform.tfvars`:
```hcl
project_id = "konect-app-123456"
region     = "asia-southeast1"
```

### 8.3 Apply Terraform

```bash
terraform init
terraform plan
terraform apply   # atau: terraform apply -auto-approve
```

### 8.4 Terraform State

**Jangan simpan state file lokal untuk production!** Gunakan GCS bucket:

```hcl
terraform {
  backend "gcs" {
    bucket = "konect-terraform-state"
    prefix = "prod"
  }
}
```

```bash
# Buat bucket untuk state
gsutil mb gs://konect-terraform-state
gsutil versioning set on gs://konect-terraform-state
```

---

## 9. Monitoring & Logging

### 9.1 Cloud Logging

Log dari Cloud Run, GKE, Compute Engine otomatis masuk ke Cloud Logging.

```bash
# Lihat logs real-time
gcloud logging tail "resource.type=cloud_run_revision AND resource.labels.service_name=konect-app"

# Query logs
gcloud logging read "resource.type=cloud_run_revision AND severity>=ERROR" \
  --limit 10 \
  --format json
```

### 9.2 Cloud Monitoring

Buat dashboard dan alert:

```bash
# Buat alert policy via gcloud (contoh: error rate > 5%)
gcloud alpha monitoring policies create \
  --display-name="Cloud Run Error Rate" \
  --condition-filter='resource.type="cloud_run_revision" AND metric.type="run.googleapis.com/request_count" AND metric.labels.response_code_class="5xx"' \
  --condition-threshold-value=0.05 \
  --condition-threshold-duration=300s \
  --notification-channels=CHANNEL_ID
```

### 9.3 Dasbor Cepat di Console

1. Buka **Cloud Console** → **Monitoring** → **Dashboards**
2. Pilih template atau buat custom
3. Tambahkan widget: CPU, Memory, Request count, Error rate

---

## 10. Best Practices & Keamanan

### 10.1 Arsitektur

| Praktik | Keterangan |
|---------|-----------|
| **Stateless** | Cloud Run dan App Engine mengharuskan stateless; simpan state di DB/Redis |
| **Health checks** | Selalu sediakan endpoint `/health` untuk liveness probe |
| **Graceful shutdown** | Tangani sinyal SIGTERM di aplikasi |
| **Multi-region** | Untuk HA, deploy ke ≥2 region |
| **VPC** | Gunakan VPC untuk isolasi network |

### 10.2 Keamanan

- **Aktifkan MFA** untuk semua akun admin
- **Jangan gunakan roles Owner/Editor** untuk aplikasi — pakai custom roles
- **Gunakan Secret Manager** — jangan hardcode secrets
- **Scan container images** — aktifkan Container Analysis
- **Limit network access** — gunakan VPC firewall rules
- **Audit logs** — aktifkan Data Access logs untuk secrets
- **Workload Identity Federation** — hindari download service account key

### 10.3 Optimasi Biaya

- Gunakan **Cloud Run** daripada VM untuk workload intermittent
- Set **min-instances=0** untuk development (scale to zero)
- Gunakan **e2-micro** atau **e2-small** untuk VM development
- Aktifkan **committed use discounts** untuk workload 24/7
- Pantau biaya via **Billing Reports** dan set **budget alerts**

### 10.4 CI/CD

- Build image sekali, deploy ke mana-mana (promote image, bukan rebuild)
- Gunakan **Cloud Build** dengan **kaniko** atau **BuildKit** untuk build aman
- Set **require-approval** untuk deploy ke production
- Simpan **cloudbuild.yaml** di repository

---

## 11. Troubleshooting Umum

### Cloud Run

| Masalah | Solusi |
|---------|--------|
| `Permission denied` | Pastikan Cloud Run API enabled dan service account punya role `run.invoker` |
| `Container failed to start` | Cek log: `gcloud logging tail "resource.type=cloud_run_revision"` |
| `Port not listening` | Aplikasi harus listen di port dari env `PORT` |
| `Cold start lambat` | Set `--min-instances 1` untuk production |
| `Billing account not found` | Aktifkan billing di console |

### gcloud CLI

| Masalah | Solusi |
|---------|--------|
| `gcloud: command not found` | Re-run `./google-cloud-sdk/install.sh` atau restart terminal |
| `Unauthorized` | `gcloud auth login` |
| `Project not set` | `gcloud config set project PROJECT_ID` |
| `API not enabled` | `gcloud services enable SERVICE.googleapis.com` |
| `Quota exceeded` | Minta peningkatan quota di Console → IAM & Admin → Quotas |

### Compute Engine

| Masalah | Solusi |
|---------|--------|
| `Cannot SSH` | Cek firewall rule `default-allow-ssh` (tcp:22) |
| `Instance doesn't start` | Cek serial console output di Console |
| `Disk full` | Resize disk: `gcloud compute disks resize DISK --size=50GB` |

### GKE

| Masalah | Solusi |
|---------|--------|
| `kubectl: command not found` | Install: `gcloud components install kubectl` |
| `Error from server (Forbidden)` | Cek kubeconfig: `gcloud container clusters get-credentials` |
| `CrashLoopBackOff` | `kubectl logs POD_NAME` dan `kubectl describe pod POD_NAME` |
| `ImagePullBackOff` | Pastikan image ada di Artifact Registry dan pull access benar |

---

## Referensi

- [Google Cloud SDK Documentation](https://cloud.google.com/sdk/docs)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [App Engine Documentation](https://cloud.google.com/appengine/docs)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [IAM Documentation](https://cloud.google.com/iam/docs)
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)

---

> **Panduan ini disusun dari dokumentasi resmi Google Cloud dan praktik terbaik industri per Juli 2026.**
> Untuk informasi terbaru, kunjungi [cloud.google.com/docs](https://cloud.google.com/docs).
