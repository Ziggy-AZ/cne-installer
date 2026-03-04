# Liferay Cloud Native - GCP Installer

## Welcome
Welcome to the Liferay Cloud Native GCP Installer. This guided tutorial will walk you through the installation process.

### 💡 Pro-Tips for Navigation
* **Don't Close This Sidebar:** If you need to open a link to the Console, **right-click and "Open in New Tab"** to keep this guide visible.
* **The "Resume" Icon:** If this panel disappears, look for the **Learn** (graduation cap) icon in the top-right header to bring it back.

To get started, click **Next**.

## Select GCP Project
Before running the installer, you need to select the Google Cloud project where you want to deploy Liferay.

<walkthrough-project-setup billing="true" required="true"></walkthrough-project-setup>

Once selected, click the button below to sync your terminal environment:

```sh
gcloud config set project <walkthrough-project-id/>
```

## Enable APIs
The installer requires several Google Cloud APIs to be enabled to automate the creation and management of your environment. 

> [!NOTE]
> This process can take 1-2 minutes. The "Infrastructure Manager" and "Cloud Build" APIs are essential for the next steps.

<walkthrough-enable-apis apis="cloudbuild.googleapis.com,config.googleapis.com,compute.googleapis.com,container.googleapis.com,cloudresourcemanager.googleapis.com,iam.googleapis.com,iamcredentials.googleapis.com,sts.googleapis.com,storage-api.googleapis.com,artifactregistry.googleapis.com,sqladmin.googleapis.com,secretmanager.googleapis.com,servicenetworking.googleapis.com,servicemanagement.googleapis.com,servicecontrol.googleapis.com">
</walkthrough-enable-apis>

## Configure Region
Choose the Google Cloud region where you want to deploy your infrastructure.

<walkthrough-editor-open-file filePath="./setup-region.sh">View setup-region.sh</walkthrough-editor-open-file>

```sh
source ./setup-region.sh <walkthrough-project-id/>
```

> [!IMPORTANT]
> We use `source` to ensure the region is saved as an environment variable in your current session. This script also updates your `terraform.tfvars` file automatically.

## Create Service Accounts
To run the terraform scripts with Infrastructure Manager and Cloud Build we need to create a service account and permissions for the cloud build runner. 

### 1. Run the IAM Setup
The script below will generate a service account and allow Cloud Build to run with the configured permissions. 

<walkthrough-editor-open-file filePath="./setup-iam.sh">View setup-iam.sh</walkthrough-editor-open-file>

```sh
./setup-iam.sh <walkthrough-project-id/>
```

> [!TIP]
> You can verify the created service account and its permissions in the [IAM Service Accounts Console](https://console.cloud.google.com/iam-admin/serviceaccounts?project=<walkthrough-project-id/>).

## Prepare GitOps Repository
Before deploying the GitOps platform, you need to create your own repository from the Liferay Cloud Native template.

### 1. Create Repository from Template
Click the link below to create a new repository in your GitHub account using the boilerplate:

[Create Repository from Template](https://github.com/LiferayCloud/cloud-native-gitops-boilerplate/generate)

> [!IMPORTANT]
> Once created, copy your repository URL and add it to the `liferay_git_repo_url` variable in your `terraform.tfvars` file.

### 2. Configure GitHub App
To allow ArgoCD to sync from your new repository and provide SSO for your team, we recommend using the [GitHub App Manifest Tool](https://ziggy-az.github.io/cne-installer/) to automate the setup with the correct permissions.

**Steps:**
1. **Enter Details**: Provide your GitHub Organization and ArgoCD Base URL.
2. **Register**: Click **Register GitHub App** to be redirected to GitHub.
3. **Install**: After creating the app, navigate to **Install App** in the GitHub settings and install it on your organization.
4. **Finalize**: After installation, follow the success page to retrieve your **App ID**, **Installation ID**, and **Private Key**.

> [!TIP]
> You will store these credentials securely in the next step using a helper script.

### 3. (Optional) Prepare Workspace Repository
If you have a separate Liferay Workspace repository for overlays and custom logic, we recommend using our "Self-Initialization" workflow:

1.  **Create a Blank Repo**: Create a new private repository in your GitHub organization (do not initialize it with a README or license).
2.  **Add Initialization Workflow**: 
    *   Create a file at `.github/workflows/init.yml`.
    *   Paste the content of our [Workspace Init Template](https://raw.githubusercontent.com/Ziggy-AZ/cne-installer/main/docs/templates/init-workspace.yml).
    *   Commit this file to the `main` branch.
3.  **Run the Workflow**:
    *   Navigate to the **Actions** tab in your **new** repository.
    *   Select **Initialize Liferay Workspace**.
    *   Click **Run workflow** and enter your desired Liferay version (e.g., `dxp-2024.q1.11`).
4.  **Result**: The workflow will automatically install Liferay Blade, initialize the workspace, and add the GCP deployment logic for you.

**C. Connect to GCP**
1.  **Update Variables**: Copy your Workspace repository path (e.g., `my-org/liferay-workspace`) and add it to `liferay_workspace_git_repo_path` in `terraform.tfvars`.
2.  **Configure App Access**: Ensure the GitHub App you created in the previous step is installed on this repository.

> [!NOTE]
> **Zero-Touch Configuration**: When you run the deployment, Terraform will automatically sign into your repository and configure all required GitHub Actions Variables (`GCP_REGION`, `GCP_WIF_PROVIDER`, etc.) for you.

**D. Deploying**
When you push your code to GitHub, the action will automatically authenticate via **Workload Identity Federation (WIF)**, build your Java modules and Client Extensions, and push them to your private Registry and Storage buckets in GCP.

## Optional: Advanced Configuration
Before running the deployment, you can customize your environment by editing the Terraform variables file directly.

### Required Secrets
Some features require secrets to be stored in Google Secret Manager before deployment.

*   **Liferay DXP License:** (Mandatory for DXP)
    1.  Upload your license XML file to Cloud Shell (use the **⋮ (three dots)** menu > **Upload**).
    2.  Run the script pointing to your file:
    ```sh
    ./setup-secret.sh <walkthrough-project-id/> liferay-cloud-native-liferay-license-xml path/to/your/license.xml
    ```

*   **GitOps Repository Credentials:** (Mandatory for GitOps)
    Store your GitHub credentials so ArgoCD can sync with your repository. Choose **one** method:

    **A. HTTPS (Default):**
    Provide a JSON string containing `git_access_token` and `git_machine_user_id`.
    ```sh
    ./setup-secret.sh <walkthrough-project-id/> liferay-cloud-native-gitops-repo-credentials
    ```

    **B. SSH:**
    Provide the `git_ssh_private_key`. Set `liferay_git_repo_auth_method = "ssh"` in `terraform.tfvars`.
    ```sh
    ./setup-secret.sh <walkthrough-project-id/> liferay-cloud-native-gitops-repo-credentials
    ```

    **C. GitHub App:**
    Use this method if you want ArgoCD to use short-lived tokens. 
    1. Set `liferay_git_repo_auth_method = "github_app"` in `terraform.tfvars`.
    2. Run the helper script to format and store the secret:
    ```sh
    ./setup-github-app-secret.sh <walkthrough-project-id/>
    ```
    > [!TIP]
    > If you are using a separate Liferay Workspace repository with its own GitHub App or Installation ID, you can store a separate secret:
    > ```sh
    > ./setup-github-app-secret.sh <walkthrough-project-id/> liferay-workspace-repo-credentials
    > ```
    > [!TIP]
    > **How to find your Installation ID:**
    > 1. Go to your **Repository Settings** (the tab at the top of your repo).
    > 2. Click **GitHub Apps** in the left sidebar.
    > 3. Click **Configure** next to your app.
    > 4. The **Installation ID** is the number at the end of the URL: `.../installations/12345678`.

*   **Cloudflare Integration:**
    To use Cloudflare, store your API Token in Secret Manager:
    ```sh
    ./setup-secret.sh <walkthrough-project-id/> cloudflare-api-token
    ```

*   **NetBird Integration:**
    To use NetBird Reverse Proxy, store your Proxy Token in Secret Manager:
    ```sh
    ./setup-secret.sh <walkthrough-project-id/> netbird-proxy-token
    ```
    > [!TIP]
    > Set `enable_netbird = true` in `terraform.tfvars`. You can generate a Proxy Token in the NetBird Dashboard under **Reverse Proxy > Proxy Tokens**.

*   **GitHub SSO/GitOps Secrets:**
    If you plan to use GitHub for ArgoCD authentication or Webhooks, store these secrets:
    ```sh
    ./setup-secret.sh <walkthrough-project-id/> github-webhook-secret
    ./setup-secret.sh <walkthrough-project-id/> github-client-id
    ./setup-secret.sh <walkthrough-project-id/> github-client-secret
    ```

### Edit Variables
Click the button below to open the variables file in the editor:

<walkthrough-editor-open-file filePath="terraform.tfvars">Open terraform.tfvars</walkthrough-editor-open-file>

> [!IMPORTANT]
> You **must** provide values for `liferay_git_repo_url` and `root_domain` in the file before starting the build.

### Common Settings
You can copy/paste these examples into the file:

*   **Authorized Networks:**
    `authorized_ipv4_cidr_block = "YOUR_IP/32"`
*   **Custom Domains:**
    `domains = ["example.com", "myportal.io"]`
    `argo_cd_domain = "argocd.example.com"`
*   **ArgoCD GitHub SSO:**
    ```hcl
    argo_cd_auth_config = {
      enable_sso = true
      github = {
        org   = "your-github-org"
        teams = ["your-admin-team"]
      }
      rbac = {
        admins = ["your-github-username"]
      }
    }
    ```
*   **Cloudflare Integration:**
    ```hcl
    enable_cloudflare     = true
    cloudflare_account_id = "your-id"
    cloudflare_zone_id    = "your-zone"
    ```

> [!TIP]
> **Why edit the file?** Editing `terraform.tfvars` makes your settings "permanent" for the life of this project. Any settings you provide in the file will be used during the build. Essential settings (Project ID, Region) are automatically handled by the installer.

## Kick off the build
Now we can invoke Cloud Build and Infrastructure Manager to actually run the build!

### 1. Run the build
The script below will actually invoke the terraform build

<walkthrough-editor-open-file filePath="./submit_build.sh">View submit_build.sh</walkthrough-editor-open-file>
<walkthrough-editor-open-file filePath="./cloudbuild.yaml">View cloudbuild.yaml</walkthrough-editor-open-file>

```sh
./submit_build.sh <walkthrough-project-id/>
```

### 2. Monitor Progress
Once the build is submitted, you can track its progress and view logs in the Google Cloud Console.

*   [View Build History in Console](https://console.cloud.google.com/cloud-build/builds?project=<walkthrough-project-id/>)
*   [View Infrastructure Manager Deployments](https://console.cloud.google.com/infra-manager/deployments?project=<walkthrough-project-id/>)

## Verify the Cluster
After the Infrastructure Manager deployment finishes, your GKE cluster will be ready.

### View GKE Cluster
You can inspect the cluster nodes, workloads, and services in the Kubernetes Engine dashboard.

*   [View GKE Clusters](https://console.cloud.google.com/kubernetes/list/overview?project=<walkthrough-project-id/>)

Congratulations! You have successfully initiated the Liferay Cloud Native deployment on GCP.
