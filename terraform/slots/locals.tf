locals  {

    prefix = "${var.identifier}${var.region}${var.env}"
    rgName = "${var.rgPrefix}${var.identifier}${var.region}${var.env}"
    appSrvcPlanName = "appSrvcPlan-${var.identifier}-${var.region}-${var.env}"
    funcAppName = "funcApp${var.identifier}${var.region}${var.env}"
    funcAppUrl = "https://${local.funcAppName}.azurewebsites.net"
    webAppName = "webApp${var.identifier}${var.region}${var.env}"
    webAppUrl = "https://${local.webAppName}.azurewebsites.net"
    appSrvcBackEnd = "appSrvcBackEnd-${var.identifier}-${var.region}-${var.env}"
    appInsightName = "appInsights-${var.identifier}-${var.region}-${var.env}"
    saFuncAppName = lower("${var.globalPrefix}${var.identifier}${var.region}${var.env}appsa")
    cosmosdbName = "${var.globalPrefix}-${var.identifier}-${var.region}-${var.env}-cosmosdb"
  
  sqlContainers = {
        FlowEvents = {
            name    = "FlowEvents"
            keyPath = "/PolicyNumber"
        }
   }
}