# Create RG for functions app
resource "azurerm_resource_group" "funcdeploy" {
	name = "infrasys-ibmilic-rg"
	location = "West US"
}


# Create a azure storage account
resource "azurerm_storage_account" "funcdeploy" {
	name            			= "infrasysstorageact01"
	resource_group_name 		= azurerm_resource_group.funcdeploy.name
	location            		= azurerm_resource_group.funcdeploy.location
	account_tier        		= "Standard"
	account_replication_type 	= "LRS"
}



# Create azure storage container
resource "azurerm_storage_container" "funcdeploy" {
	name       				= "contents"
	storage_account_name 	= azurerm_storage_account.funcdeploy.name
	container_access_type 	= "private"
}


# Create azurerm App insight
resource "azurerm_application_insights" "funcdeploy" {
	name 					= "funcapp-insights-001"
	location 				= azurerm_resource_group.funcdeploy.location
	resource_group_name 	= azurerm_resource_group.funcdeploy.name
	application_type 		= "web"
	tags = {
	   "Monitoring" = "functionApp"
	}

}

# Create Azure app service plan
resource "azurerm_app_service_plan" "funcdeploy" {
	name            = "ibmilic-funcapp-asp"
	location            		= azurerm_resource_group.funcdeploy.location
	resource_group_name 		= azurerm_resource_group.funcdeploy.name
	kind              = "FunctionApp"
	reserved          = true

	sku {
	   tier = "Dynamic"
	   size = "Y1"

	}
}



# Create AzureRM function app
resource "azurerm_function_app" "funcdeploy" {
	name        = "ibmilic-funcapp-01"
	location            		= azurerm_resource_group.funcdeploy.location
	resource_group_name 		= azurerm_resource_group.funcdeploy.name
	app_service_plan_id         = azurerm_app_service_plan.funcdeploy.id
	storage_account_name 	= azurerm_storage_account.funcdeploy.name
	storage_account_access_key 	= azurerm_storage_account.funcdeploy.primary_access_key
	https_only = true
	version   = "~3"
	os_type = "linux"	
	app_settings = {
		"WEBSITE_RUN_FROM_PACKAGE" = "1"
		"FUNCTIONS_WORKER_RUNTIME" = "python"
		"APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.funcdeploy.instrumentation_key}"
		"APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.funcdeploy.instrumentation_key}"
	}

    site_config {
        linux_fx_version = "Python|3.9"
        ftps_state = "Disabled"
        always_on = true
    }   
    identity {
        type = "SystemAssigned"
    }

}


# Create an Azure Function App on Linux
resource azurerm_function_app "primary" {
  name                       = local.function_app_name
  resource_group_name        = azurerm_resource_group.primary.name
  location                   = azurerm_resource_group.primary.location

  app_service_plan_id        = azurerm_app_service_plan.primary.id
  
  storage_account_name       = azurerm_storage_account.primary.name
  storage_account_access_key = azurerm_storage_account.primary.primary_access_key
  
  os_type                    = "linux"
  version                    = "~3"

  site_config {
    always_on = true
  }
}