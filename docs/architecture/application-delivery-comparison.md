# Application Delivery Comparison (Helm)

## Executive Summary
This report compares the Liferay Helm chart implementations for Google Cloud Platform (`liferay-gcp`) and Amazon Web Services (`liferay-aws`), including their shared foundation (`liferay-default`).

## 1. Technical Comparison

| Feature | GCP Implementation (`liferay-gcp`) | AWS Implementation (`liferay-aws`) |
| :--- | :--- | :--- |
| **Object Storage** | **GCS:** Uses `GCSStore` with `gke-gcsfuse` annotations for native mounting. | **S3:** Uses `S3Store` configured via environment variables and IAM (IRSA). |
| **Search Engine** | **Elasticsearch:** Configured for remote ES instances via GKE networking. | **OpenSearch:** Configured for AWS OpenSearch Service with authentication. |
| **Versioning** | `0.1.6` (Core), `0.1.5` (Default) | `0.3.0` (Core), `0.3.0` (Default) |
| **Injected Config** | Uses `customEnvFrom` for `liferay-company-domain-config`. | Uses direct `configmap.data` overrides for OS/S3 connection strings. |
| **Overlay Support** | Handled via custom init containers and GCS fuse. | Handled via shared EBS volumes or S3 mountpoint. |

## 2. Key Differences & Observations

### 2.1 Storage Drivers
The **GCP Implementation** heavily leverages the `gke-gcsfuse` CSI driver. This allows GCS buckets to be mounted directly as filesystems, which is reflected in the `podAnnotations` and `overlay` configuration.

The **AWS Implementation** relies on the `S3Store` implementation within Liferay DXP itself, using the AWS SDK to communicate with S3 rather than a filesystem mount (though Mountpoint for S3 is available as an alternative).

### 2.2 Search Backend
AWS has standardized on **OpenSearch 2.x**, which requires specific Liferay OSGi configurations (`com.liferay.portal.search.opensearch2`). GCP remains on **Elasticsearch 7.x**, using the standard ES configuration patterns.

### 2.3 Version Drift
The AWS Team is currently ahead in versioning (`0.3.0` vs `0.1.6`). This indicates that some features or bug fixes present in the AWS "default" chart may not yet have been ported to the GCP "default" chart.

## 3. Recommendations for GCP Harmonization
1.  **Version Alignment:** Plan a synchronization task to port architectural improvements from `liferay-default:0.3.0` (AWS) to the GCP implementation.
2.  **Naming Consistency:** Rename `x-liferay-gcp` keys in `values.yaml` to more generic names if possible, or ensure they follow the `Brand Integrity` underscore rule consistently.
3.  **Property Abstraction:** Adopt the AWS pattern of using `$[env:VARIABLE_NAME]` for sensitive or dynamic properties within the `portal-ext.properties` block to improve portability.
