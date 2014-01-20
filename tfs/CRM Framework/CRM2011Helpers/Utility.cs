using System;
using Microsoft.Xrm.Sdk.Query;
using System.Diagnostics;
using System.Xml;
using System.Text.RegularExpressions;
using System.Data;
using Microsoft.Xrm.Sdk.Client;
using Microsoft.Crm.Sdk.Messages;
using System.Web.Services.Protocols;
using Microsoft.Xrm.Sdk;

namespace CRM2011Helpers
{
    /// <summary>
    /// Placeholder for various utility functions.
    /// </summary>
    public static class Utility
    {
        /// <summary>
        /// Return a conditionexpression for the condition 'statecode = 0' (active)  
        /// </summary>
        /// <returns></returns>
        public static ConditionExpression AddActiveFilter()
        {
            return AddSimpleFilter("statecode", ConditionOperator.Equal, 0);
        }

        /// <summary>
        /// Create a condition expression for an attribute/operator/value combination
        /// </summary>
        /// <param name="attributeName"></param>
        /// <param name="attributeOperator"></param>
        /// <param name="attributeCompare"></param>
        /// <returns></returns>
        public static ConditionExpression AddSimpleFilter(string attributeName, ConditionOperator attributeOperator, object attributeCompare)
        {
            return new ConditionExpression(attributeName, attributeOperator, attributeCompare);
        }


        /// <summary>
        /// Workaround for XPath problems when attribute string has ' or "
        /// </summary>
        /// <param name="s"></param>
        /// <returns>string with ' and " replaced by &apos; and &quot;</returns>
        public static string XpathAddSafeQuotes(string s)
        {
            return s.Replace("'", "&apos;").Replace("\"", "&quot;");
        }

        /// <summary>
        /// Workaround for XPath problems when attribute string has ' or "
        /// </summary>
        /// <param name="s"></param>
        /// <returns>string with &apos; and &quot; replaced by ' and "</returns>
        public static string XpathRemoveSafeQuotes(string s)
        {
            return s.Replace("&apos;", "'").Replace("&quot;", "\"");
        }

        /// <summary>
        /// Append the SOAP Exception detail message to the main exception message
        /// for more detailed error messages
        /// </summary>
        /// <param name="ex">Incoming Exception</param>
        /// <returns>new exception with SOAP Exception detail description appended (if applicable)</returns>
        public static string GetSoapExceptionDescription(Exception ex)
        {
            if (ex is SoapException)
            {
                XmlDocument errorXml = new XmlDocument();
                errorXml.LoadXml(((SoapException)ex).Detail.OuterXml);

                return " " + errorXml.SelectSingleNode("//description").InnerText;
            }
            return "";
        }

        /// <summary>
        /// Takes a domainLogonName string (domain\username), strips off the domain and returns just the username
        /// </summary>
        /// <param name="domainLogonName">domainLogonName string</param>
        /// <returns>username</returns>
        public static string GetUserIdFromDomainName(string domainLogonName)
        {
            return domainLogonName.Substring(domainLogonName.IndexOf("\\") + 1);
        }

        /// <summary>
        /// Convert the Guid to a standard format to make it suitable for string comparisons. This function
        /// converts the lower case characters in the Guid to upper case and also attaches braces if not already there.
        /// </summary>
        /// <param name="guid"></param>
        /// <returns></returns>
        public static string FormatGuid(string guid)
        {
            string formatguid;
            Regex pattern = new Regex("^\\{.*\\}$");
            if (pattern.IsMatch(guid))
            {
                formatguid = guid.ToUpper();
            }
            else
            {
                formatguid = String.Format("{{{0}}}", guid.ToUpper());
            }

            return formatguid;
        }

        /// <summary>
        /// Used to trigger execution of a given workflow on the selected entity.
        /// </summary>
        /// <param name="entityId">the guid of the entity to run the workflow on</param>
        /// <param name="workflowId">the guid of the workflow</param>
        /// <param name="serviceAdapter">organization service proxy that will execute the call</param>
        public static void InvokeWorkflow(Guid entityId, Guid workflowId, OrganizationServiceProxy serviceAdapter )
        {

            // Create an ExecuteWorkflow request.
            ExecuteWorkflowRequest request = new ExecuteWorkflowRequest();

            //Assign the ID of the workflow you want to execute to the request.         
            request.WorkflowId = workflowId;

            //Assign the ID of the entity to execute the workflow on to the request.
            request.EntityId = entityId;

            // Execute the workflow.
            ExecuteWorkflowResponse response = (ExecuteWorkflowResponse)serviceAdapter.Execute(request);
        }

        /// <summary>
        /// Determines if the current user has the specified role
        /// </summary>
        /// <param name="serviceAdapter">CRM Service Adapter</param>
        /// <param name="roleName">The name of the role to check for.</param>
        /// <returns>True/False</returns>
        public static bool UserHasRole(OrganizationServiceProxy serviceAdapter, string roleName)
        {
            try
            {
                bool hasRole = false;

                string fetchXml = "";
                fetchXml = @"<fetch mapping='logical' count='50'>
	                    <entity name='role'>
		                    <attribute name='name' />
		                    <attribute name='roleid' />
		                    <filter>
			                    <condition attribute='name' operator='eq' value='" + roleName + @"' />
		                    </filter>
		                    <link-entity name='systemuserroles' from='roleid' to='roleid'>
			                    <filter>
				                    <condition attribute='systemuserid' operator='eq-userid' />
			                    </filter>
		                    </link-entity>
	                    </entity>
                    </fetch>";


                EntityCollection result = serviceAdapter.RetrieveMultiple(new FetchExpression(fetchXml));

                hasRole = (result.TotalRecordCount > 0);

                return hasRole;
            }
            catch (Exception ex)
            {
                throw new Exception("Error getting the current User roles: " + ex.Message);
            }
        }

        /// <summary>
        /// Determines if a specified user has the specified role
        /// </summary>
        /// <param name="serviceAdapter">CRM Service Adapter</param>
        /// <param name="roleName">The name of the role to check for</param>
        /// <param name="systemuserId">The guid of the user to check for</param>
        /// <returns>True/False</returns>
        public static bool UserHasRole(OrganizationServiceProxy serviceAdapter, string roleName, Guid systemuserId)
        {
            try
            {
                bool hasRole = false;

                string fetchXml = "";
                fetchXml = @"<fetch mapping='logical' count='50'>
	                    <entity name='role'>
		                    <attribute name='name' />
		                    <attribute name='roleid' />
		                    <filter>
			                    <condition attribute='name' operator='eq' value='" + roleName + @"' />
		                    </filter>
		                    <link-entity name='systemuserroles' from='roleid' to='roleid'>
			                    <filter>
				                    <condition attribute='systemuserid' operator='eq' value='" + systemuserId.ToString() + @"' />
			                    </filter>
		                    </link-entity>
	                    </entity>
                    </fetch>";

                EntityCollection result = serviceAdapter.RetrieveMultiple(new FetchExpression(fetchXml));

                hasRole = (result.TotalRecordCount > 0);

                return hasRole;
            }
            catch (Exception ex)
            {
                throw new Exception("Error getting the current User roles: " + ex.Message);
            }
        }

        /// <summary>
        /// Determines if a specified user has the specified role
        /// </summary>
        /// <param name="serviceAdapter">CRM Service Adapter</param>
        /// <param name="roleName">The name of the role to check for</param>
        /// <param name="domainName">The domain\name of the user to check for</param>
        /// <returns>True/False</returns>
        public static bool UserHasRole(OrganizationServiceProxy serviceAdapter, string roleName, string domainName)
        {
            try
            {
                bool hasRole = false;

                string fetchXml = "";
                fetchXml = @"<fetch mapping='logical' count='50'>
	                    <entity name='role'>
		                    <attribute name='name' />
		                    <attribute name='roleid' />
		                    <filter>
			                    <condition attribute='name' operator='eq' value='" + roleName + @"' />
		                    </filter>
		                    <link-entity name='systemuserroles' from='roleid' to='roleid'>
			                    <filter>
				                    <condition attribute='domainname' operator='eq' value='" + domainName + @"' />
			                    </filter>
		                    </link-entity>
	                    </entity>
                    </fetch>";

                EntityCollection result = serviceAdapter.RetrieveMultiple(new FetchExpression(fetchXml));

                hasRole = (result.TotalRecordCount > 0);

                return hasRole;
            }
            catch (Exception ex)
            {
                throw new Exception("Error getting the current User roles: " + ex.Message);
            }
        }

    }
}
