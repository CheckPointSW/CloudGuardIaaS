# China Azure Resource Manager templates
# 中国 Azure ARM 部署模板
This directory contains the CloudGuard IaaS solution templates published in the [China Azure Marketplace](https://market.azure.cn/marketplace/apps/1740992136172.checkpoint--cloudguard-iaas?tab=Overview).

该目录包含在[中国Azure市场](https://market.azure.cn/marketplace/apps/1740992136172.checkpoint--cloudguard-iaas?tab=Overview)发布的CloudGuard IaaS解决方案模板。
# How to deploy templates manually
# 如何手动部署模板
To deploy the ARM templates manually without using the Azure Marketplace, follow these instructions:  
要在不使用 Azure 市场的情况下手动部署 ARM 模板，请按照以下说明操作：
1. Log in to the [Microsoft China Azure Portal](https://portal.azure.cn)  
   登录[微软中国Azure门户](https://portal.azure.cn)
2. Click "*Create a resource*"  
   点击“*创建资源*”
3. Search for "*Template deployment (deploy using custom templates)*" and click "*Create*"  
   搜索“*模板部署（使用自定义模板部署）*”，点击“*创建*”
4. Click "*Build your own template in the editor*"  
   点击“*在编辑器中生成自己的模板*”
5. Load the "*mainTemplate.json*" file of the desired template and click "*Save*"  
   点击“*加载文件*”加载所需模板的“*mainTemplate.json*”文件，然后点击“*保存*”
6. Enter the desired template parameters  
   输入所需的模板参数
   - Replace the "*_artifacts Location*" property with:
      ```
      https://raw.githubusercontent.com/CheckPointSW/CloudGuardIaaS/master/China/azure/templates/
      ```
7. Click *Purchase* to deploy the solution  
   单击*购买*以部署解决方案