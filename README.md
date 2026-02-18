# Azure AKS + ArgoCD GitOps Project

This project automates the deployment of a Kubernetes infrastructure on Azure (AKS) using **Terraform** and manages continuous application deployment via **Argo CD** following the GitOps methodology.

## 🚀 Project Architecture

* **Infrastructure:** Azure Kubernetes Service (AKS) and Azure Container Registry (ACR).
* **Infrastructure Management:** Terraform (IaC).
* **Continuous Deployment (CD):** Argo CD (GitOps).
* **Application:** FastAPI (Helm Chart).
* **CI/CD Pipeline:** GitHub Actions.

---

## 🛠️ Prerequisites

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) configured.
* [Terraform](https://developer.hashicorp.com/terraform/downloads) installed.
* [kubectl](https://kubernetes.io/docs/tasks/tools/) installed.
* A GitHub repository with the defined folder structure.

---

## 🏗️ Step 1: Infrastructure Deployment

1.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

2.  **Plan and Apply:**
    ```bash
    terraform apply
    ```
    *This will create the Resource Group, AKS, ACR, and install Argo CD using the Helm provider.*

---

## ⚓ Step 2: Argo CD Configuration

Once the cluster is ready, we must connect the Argo CD application to our repository.

1.  **Access Argo CD:**
    Run a port-forward to access the web interface:
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```

2.  **Application Setup:**
    The application is managed via Terraform pointing to the following path in the repository:
    * **Repo URL:** `https://github.com/OsvaldoMazza/azure-argocd.git`
    * **Path:** `infra/k8s/appfastapi`
    * **Branch:** `master`

---

## 🔄 Step 3: GitOps Workflow

The system operates under the "Single Source of Truth" principle:

1.  **Code Changes:** Any modification in the `/src` folder triggers the GitHub Actions pipeline.
2.  **Continuous Integration (CI):**
    * A new Docker image is built.
    * The image is pushed to the **Azure Container Registry (ACR)** with a unique tag (`github.sha`).
3.  **Manifest Update:**
    * The pipeline automatically edits the `infra/k8s/appfastapi/values.yaml` file, updating the image tag.
    * An automatic `git push` is performed back to the repository.
4.  **Synchronization:**
    * **Argo CD** detects the change in the Git repository.
    * It automatically applies the new configuration to the AKS cluster.

---

## 🔧 Maintenance

### Manual Application Update
If you wish to force an update or change Helm parameters:
```bash
# Modify files in:
infra/k8s/appfastapi/values.yaml
# Push to master
git add . && git commit -m "update config" && git push origin master
```

### Destroy Infraestructure
```bash
terraform destroy
```

### Repository Structure
```
.
├── infra/
│   ├── k8s/
│   │   └── appfastapi/      # Application Helm Chart
│   └── main.tf              # Terraform Code
├── src/                     # Source code (FastAPI)
├── .github/workflows/       # CI/CD Pipeline
└── README.md

```