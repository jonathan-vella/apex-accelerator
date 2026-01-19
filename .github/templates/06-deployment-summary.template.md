# Step 6: Deployment Summary - {project-name}

> Generated: {date}  
> Status: **{STATUS}** (Succeeded/Failed/Simulated)

## Deployment Details

| Field               | Value |
| ------------------- | ----- |
| **Deployment Name** |       |
| **Resource Group**  |       |
| **Location**        |       |
| **Duration**        |       |
| **Status**          |       |

## Deployed Resources

| Resource   | Name | Type | Status   |
| ---------- | ---- | ---- | -------- |
| Resource 1 |      |      | ✅/❌/⏸️ |
| Resource 2 |      |      | ✅/❌/⏸️ |

## Outputs (Expected)

```json
{
  "output1": "value1",
  "output2": "value2"
}
```

## To Actually Deploy

```powershell
# Navigate to Bicep directory
cd infra/bicep/{project-name}

# Preview changes
./deploy.ps1 -WhatIf

# Deploy
./deploy.ps1
```

## Post-Deployment Tasks

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

---

_Deployment summary for {project-name}._
