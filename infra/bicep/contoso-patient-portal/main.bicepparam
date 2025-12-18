// ============================================================================
// Parameters File - Production Environment
// ============================================================================
// Purpose: Production deployment parameters for Contoso Healthcare Patient Portal

using './main.bicep'

// ============================================================================
// REQUIRED PARAMETERS
// ============================================================================

param location = 'swedencentral'
param environment = 'prod'
param projectName = 'contoso-patient-portal'

// SQL Server credentials - REPLACE WITH SECURE VALUES
param sqlAdminUsername = 'sqladmin'
param sqlAdminPassword = readEnvironmentVariable('SQL_ADMIN_PASSWORD', 'ChangeMe123!@#')

// ============================================================================
// OPTIONAL PARAMETERS (using defaults from main.bicep)
// ============================================================================

param tags = {
  Environment: 'prod'
  ManagedBy: 'Bicep'
  Project: 'PatientPortal'
  CostCenter: 'Healthcare-IT'
  Compliance: 'HIPAA'
  DeploymentDate: '2025-11-18'
}
