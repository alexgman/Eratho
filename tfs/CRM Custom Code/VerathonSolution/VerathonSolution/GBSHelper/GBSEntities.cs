using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
using System.Runtime.Serialization;
using System.Web.Services.Protocols;

//Used only to generate Next Id using a stored procedure
using System.Data;
using System.Data.SqlClient;
//End Used only to generate Next Id using a stored procedure

namespace Verathon.Crm.Entities
{
    /// <summary>
    /// Custom Business Logic for Entity implemented by GBS.
    /// </summary>
    public partial class GBSEntity : Entity
    {
        /// <summary>
        /// This Method generates the Name of the attribute received from the unsecure configuration XML
        /// </summary>
        /// <param name="pConfigXml"></param>
        /// <param name="pContext"></param>
        /// <param name="pService"></param>
        public static void SetPrimaryAttribute(string pConfigXml, IPluginExecutionContext pContext, IOrganizationService pService)
        {
            // The InputParameters collection contains all the data passed in the message request.
            if (pContext.InputParameters.Contains("Target") && pContext.InputParameters["Target"] is Entity)
            {
                // Obtain the target entity from the input parmameters.
                Entity entity = (Entity)pContext.InputParameters["Target"];
                Entity preImage = new Entity();


                if (pContext.MessageName.Equals("Update"))
                {
                    if (pContext.PreEntityImages.Contains("PreImage") && pContext.PreEntityImages["PreImage"] is Entity)
                    {
                        preImage = (Entity)pContext.PreEntityImages["PreImage"];
                    }
                    else
                    {
                        throw new Exception("No Pre Image Entity in Plugin localContext for Message");
                    }
                }

                string AttributeToSetValue = string.Empty;
                XmlDocument config = new XmlDocument();
                config.LoadXml(pConfigXml);

                string AttributeToSet = config.SelectSingleNode("//attributeToSet").Attributes["name"].Value.ToString();
                int AttributeToSetLength = Int32.Parse(config.SelectSingleNode("//attributeToSet").Attributes["length"].Value);

                Helper.Helper helperMethods = new Helper.Helper();

                //get the expression
                XmlNode Expression = config.SelectSingleNode("//expression");
                foreach (XmlNode Segment in Expression.ChildNodes)
                {
                    if (Segment.Name == "text")
                    {
                        AttributeToSetValue += Segment.Attributes["value"].Value.ToString();
                    }
                    else if (Segment.Name == "guid")
                    {
                        AttributeToSetValue += System.Guid.NewGuid().ToString();
                    }
                    else if (Segment.Name == "attribute")
                    {
                        string AttributeType = Segment.Attributes["type"].Value.ToString();
                        string AttributeName = Segment.Attributes["name"].Value.ToString();

                        switch (AttributeType)
                        {

                            #region Picklist
                            case "picklist":
                                OptionSetValue oOption = entity.GetAttributeValue<OptionSetValue>(AttributeName);

                                //if it is null and this is an update then check the pre-image
                                if (oOption == null && pContext.MessageName.Equals("Update")) oOption = preImage.GetAttributeValue<OptionSetValue>(AttributeName);

                                if (oOption != null) AttributeToSetValue += helperMethods.getPicklistLabel(pContext.PrimaryEntityName, AttributeName, oOption.Value, pService);

                                break;
                            #endregion

                            #region Lookup
                            case "lookup":
                                //try to get the value from the dynamic context                           
                                EntityReference oLookup = entity.GetAttributeValue<EntityReference>(AttributeName);

                                //if we get a value in the dynamic context then we are done but in the dynamic context there is no name attribute passed so do a retrieve
                                if (oLookup != null)
                                {
                                    if (oLookup.Name != null)
                                    {
                                        AttributeToSetValue += oLookup.Name.ToString();
                                    }
                                    else
                                    {
                                        string LookupDescription = "";// getLookupPrimaryAttribute(oLookup, service);
                                        if (LookupDescription != null) AttributeToSetValue += LookupDescription;
                                    }
                                }

                                //if we didn't get a value in the lookup and this is an update then we need to check the preimage where the name attribute is passed
                                if (oLookup == null && pContext.MessageName.Equals("Update"))
                                {
                                    oLookup = preImage.GetAttributeValue<EntityReference>(AttributeName);
                                    if (oLookup != null && oLookup.Name != null) AttributeToSetValue += oLookup.Name.ToString();
                                }
                                break;
                            #endregion

                            #region PartyList
                            case "partylist":

                                EntityCollection partyList = entity.GetAttributeValue<EntityCollection>(AttributeName);

                                if (partyList == null && pContext.MessageName.Equals("Update"))
                                {
                                    partyList = preImage.GetAttributeValue<EntityCollection>(AttributeName);
                                }

                                foreach (Entity party in partyList.Entities)
                                {

                                    if (party.Contains("partyid"))
                                    {
                                        EntityReference partyLookup = party.GetAttributeValue<EntityReference>("partyid");
                                        if (partyLookup != null)
                                        {
                                            if (partyLookup.Name != null)
                                            {
                                                AttributeToSetValue += partyLookup.Name.ToString();
                                            }
                                            else
                                            {
                                                string LookupDescription = helperMethods.getLookupPrimaryAttribute(partyLookup, pService);
                                                if (LookupDescription != null) AttributeToSetValue += LookupDescription;

                                            }
                                        }

                                    }

                                    AttributeToSetValue += ",";
                                }

                                AttributeToSetValue = AttributeToSetValue.TrimEnd(new char[] { ',' });
                                break;
                            #endregion

                            #region Integer
                            case "int":
                                //try to get the value from the dynamic localContext
                                int? oNumber = entity.GetAttributeValue<int>(AttributeName);

                                //if it is null and this is an update then check the pre-image
                                if (oNumber == 0 && pContext.MessageName.Equals("Update")) oNumber = preImage.GetAttributeValue<int>(AttributeName);

                                if (oNumber != null && oNumber > 0) AttributeToSetValue += oNumber.ToString();
                                break;
                            #endregion

                            #region Text
                            case "nvarchar":
                                //try to get the value from the dynamic context
                                string oString = entity.GetAttributeValue<string>(AttributeName);

                                //if it is null and this is an update then check the pre-image
                                if (oString == null && pContext.MessageName.Equals("Update")) oString = preImage.GetAttributeValue<string>(AttributeName);

                                if (oString != null) AttributeToSetValue += oString;
                                break;
                            #endregion

                            #region DateTime
                            case "datetime":
                                string AttributePropertyDateTime = Segment.Attributes["property"].Value.ToString();

                                //try to get the value from the dynamic localContext
                                DateTime? oDateTime = entity.GetAttributeValue<DateTime>(AttributeName);

                                if (AttributeName == "createdon" && pContext.MessageName.Equals("Create"))
                                {
                                    oDateTime = DateTime.Now;
                                }

                                //if it is null and this is an update then check the pre-image
                                if (oDateTime.ToString().StartsWith("1/1/0001") && pContext.MessageName.Equals("Update")) oDateTime = preImage.GetAttributeValue<DateTime>(AttributeName);

                                if (oDateTime != null && !oDateTime.ToString().StartsWith("1/1/0001")) AttributeToSetValue += oDateTime.Value.ToString();
                                break;
                            #endregion

                            #region Money
                            case "money":
                                //try to get the value from the dynamic localContext
                                Money oMoney = entity.GetAttributeValue<Money>(AttributeName);

                                //if it is null and this is an update then check the pre-image
                                if (oMoney == null && pContext.MessageName.Equals("Update")) oMoney = preImage.GetAttributeValue<Money>(AttributeName);

                                if (oMoney != null) AttributeToSetValue += oMoney.Value.ToString();
                                break;
                            #endregion

                            #region Boolean
                            case "bit":
                                //try to get the value from the dynamic localContext
                                Boolean? oBoolean = entity.GetAttributeValue<Boolean>(AttributeName);

                                //if it is null and this is an update then check the pre-image
                                if (oBoolean == null && pContext.MessageName.Equals("Update")) oBoolean = preImage.GetAttributeValue<Boolean>(AttributeName); ;

                                if (oBoolean != null && oBoolean.HasValue) AttributeToSetValue += oBoolean.ToString();
                                break;
                            #endregion

                            #region Decimal
                            case "decimal":
                                //try to get the value from the dynamic localContext
                                decimal? oDecimal = entity.GetAttributeValue<decimal>(AttributeName);

                                //if it is null and this is an update then check the pre-image
                                if (oDecimal == null && pContext.MessageName.Equals("Update")) oDecimal = preImage.GetAttributeValue<decimal>(AttributeName);

                                if (oDecimal != null && oDecimal.HasValue) AttributeToSetValue += oDecimal.ToString();
                                break;
                            #endregion

                            #region Double
                            case "double":
                                //try to get the value from the dynamic localContext

                                double? oDouble = entity.GetAttributeValue<double>(AttributeName);

                                //if it is null and this is an update then check the pre-image
                                if (oDouble == null && pContext.MessageName.Equals("Update")) oDouble = preImage.GetAttributeValue<double>(AttributeName);

                                if (oDouble != null && oDouble.HasValue) AttributeToSetValue += oDouble.ToString();
                                break;
                            #endregion

                            #region Status
                            case "status":
                                OptionSetValue oStatus = entity.GetAttributeValue<OptionSetValue>(AttributeName);

                                //if it is null and this is an update then check the pre-image
                                if (oStatus == null && pContext.MessageName.Equals("Update")) oStatus = preImage.GetAttributeValue<OptionSetValue>(AttributeName);

                                if (oStatus != null) AttributeToSetValue += helperMethods.getStatusLabel(pContext.PrimaryEntityName, AttributeName, oStatus.Value, pService);

                                break;
                            #endregion

                            default:
                                break;
                        }
                    }
                }

                //update the attribute
                if (entity.Attributes.ContainsKey(AttributeToSet))
                {
                    entity.Attributes[AttributeToSet] = (AttributeToSetValue.Length > AttributeToSetLength ? AttributeToSetValue.Substring(0, AttributeToSetLength) : AttributeToSetValue);
                }
                else
                {
                    entity.Attributes.Add(AttributeToSet, (AttributeToSetValue.Length > AttributeToSetLength ? AttributeToSetValue.Substring(0, AttributeToSetLength) : AttributeToSetValue));
                }
            }
        }
    }
    
    /// <summary>
    /// Custom Business Logic for ActivityPointer implemented by GBS.
    /// </summary>
    public partial class GBSActivityPointer : ActivityPointer
    {
        /// <summary>
        /// This Method is used to Calculate the next business day for the assigned Due Date.
        /// </summary>
        /// <param name="pEntity"></param>
        public static void BusinessDayCalculator(ref Entity pEntity)
        {
            if (pEntity.Attributes.Contains("scheduledend"))
            {
                DateTime dueDate = pEntity.GetAttributeValue<DateTime>("scheduledend");

                //Add two days if current day is satuday
                if (dueDate.DayOfWeek == DayOfWeek.Saturday)
                    dueDate = dueDate.AddDays(2.0);
                //Add one day if current day is satuday
                else if (dueDate.DayOfWeek == DayOfWeek.Sunday)
                    dueDate = dueDate.AddDays(1.0);

                pEntity.Attributes["scheduledend"] = dueDate;
            }
        }

    }


    /// <summary>
    /// Custom Business Logic for Plug-in Exception Log implemented by GBS.
    /// </summary>
    public partial class GBSPluginExceptionLog : gbs_pluginexceptionlog
    {
        /// <summary>
        /// This method creates a Plug-in Exception Log record in the CRM database and should be typically called when a plug-in exception is caught.
        /// </summary>
        /// <param name="pService">An instance of the Organization Service</param>
        /// <param name="pContext">The current plug-in execution context</param>
        /// <param name="pTracingService"></param>
        /// <param name="pPluginName"></param>
        /// <param name="pException">The exception that was encountered</param>
        public static void LogException(IOrganizationService pService, IPluginExecutionContext pContext, ITracingService pTracingService, string pPluginName, Exception pException)
        {
            try
            {
                gbs_pluginexceptionlog logEntry = new gbs_pluginexceptionlog();
                //logEntry.LogicalName = "gbs_pluginexceptionlog";
                logEntry.gbs_name = pPluginName;

                if (pException is SoapException)
                {
                    logEntry.gbs_ErrorMessage = pException.Message + Environment.NewLine + GetSoapExceptionDescription(pException) + Environment.NewLine + pException.StackTrace;
                }
                else
                {
                    logEntry.gbs_ErrorMessage = pException.Message + Environment.NewLine + pException.InnerException + Environment.NewLine + pException.StackTrace;
                }

                logEntry.gbs_PluginName = pPluginName;
                logEntry.gbs_MessageName = pContext.MessageName;
                logEntry.gbs_PrimaryEntityName = pContext.PrimaryEntityName;
                logEntry.gbs_PrimaryEntityId = pContext.PrimaryEntityId.ToString();
                logEntry.gbs_Stage = pContext.Stage;
                logEntry.gbs_OutputParameters = ReturnObjectasXMLString(pContext.OutputParameters, pContext);
                logEntry.gbs_InputParameters = ReturnObjectasXMLString(pContext.InputParameters, pContext);

                if (pContext.PreEntityImages.Count > 0)
                {
                    logEntry.gbs_PreImage = ReturnObjectasXMLString(pContext.PreEntityImages, pContext);
                }

                if (pContext.PostEntityImages.Count > 0)
                {
                    logEntry.gbs_PostImage = ReturnObjectasXMLString(pContext.PostEntityImages, pContext);
                }

                pService.Create(logEntry);

            }
            catch (Exception ex)
            {
                pTracingService.Trace("Error creating Plugin Execution Log entity: " + ex.Message);
            }
        }

        #region helper methods for LogException
        /// <summary>
        /// Serializes the Target object into xml string
        /// </summary>
        /// <param name="target">The Target object.</param>
        private static string ReturnObjectasXMLString(object target, IPluginExecutionContext pContext)
        {
            System.Text.StringBuilder xmlstring = new System.Text.StringBuilder();

            try
            {
                //determine if we are in the sandbox or not - 
                //we have limited serialization capability in the sandbox due to partial trust
                //2 == sandbox
                //1 == full
                if (pContext.IsolationMode == 2)
                {
                    //sandbox serialization with XmlSerializer
                    try
                    {
                        XmlSerializer serializer;
                        System.IO.StringWriter stringWriter;
                        switch (target.GetType().ToString())
                        {
                            case "Microsoft.Xrm.Sdk.ParameterCollection":
                                ParameterCollection crmParams = (ParameterCollection)target;
                                foreach (var param in crmParams)
                                {
                                    xmlstring.Append(String.Format("<{0}>", param.Key));

                                    xmlstring.Append(ReturnObjectasXMLString(param.Value, pContext));

                                    xmlstring.Append(String.Format("</{0}>", param.Key));
                                }
                                break;

                            case "Microsoft.Xrm.Sdk.Entity":
                                Entity crmEntity = (Entity)target;
                                foreach (var attribute in crmEntity.Attributes)
                                {
                                    xmlstring.Append(String.Format("<{0}>", attribute.Key));

                                    if (attribute.Value != null)
                                    {
                                        xmlstring.Append(ReturnObjectasXMLString(attribute.Value, pContext));
                                    }
                                    xmlstring.Append(String.Format("</{0}>", attribute.Key));
                                }
                                break;

                            default:
                                xmlstring.Append(String.Format("<{0}>", target.GetType()));

                                try
                                {
                                    serializer = new XmlSerializer(target.GetType());
                                    stringWriter = new System.IO.StringWriter();
                                    serializer.Serialize(stringWriter, target);
                                    xmlstring.Append(stringWriter.ToString());
                                }
                                catch (Exception ex)
                                {
                                    xmlstring.Append("Could not serialize: " + ex.Message);
                                }
                                xmlstring.Append(String.Format("</{0}>", target.GetType()));
                                break;
                        }

                    }
                    catch (Exception)
                    {
                        xmlstring.Append("OUTER EXCEPTION");
                    }
                }
                else
                {
                    //full trust serialization with DataContractSerializer
                    MemoryStream testStream = new MemoryStream();
                    DataContractSerializer serializer = new DataContractSerializer(target.GetType());
                    XmlWriter stringWriter = XmlDictionaryWriter.CreateTextWriter(testStream);
                    serializer.WriteObject(stringWriter, target);

                    testStream.Seek(0, SeekOrigin.Begin);
                    byte[] jsonBytes = new byte[testStream.Length];
                    testStream.Read(jsonBytes, 0, (int)testStream.Length);
                    xmlstring.Append(Encoding.UTF8.GetString(jsonBytes));
                }


                return xmlstring.ToString().Substring(0, (xmlstring.Length < 10000) ? xmlstring.Length : 9999);
            }
            catch (Exception ex)
            {
                throw new Exception("Error returning target as xml:" + ex.Message);
            }
        }

        /// <summary>
        /// Append the SOAP Exception detail message to the main exception message
        /// for more detailed error messages
        /// </summary>
        /// <param name="ex">Incoming Exception</param>
        /// <returns>new exception with SOAP Exception detail description appended (if applicable)</returns>
        private static string GetSoapExceptionDescription(Exception ex)
        {
            if (ex is SoapException)
            {
                XmlDocument errorXml = new XmlDocument();
                errorXml.LoadXml(((SoapException)ex).Detail.OuterXml);

                return " " + errorXml.SelectSingleNode("//description").InnerText;
            }
            return "";
        }
        #endregion
    }

    /// <summary>
    /// Custom Business Logic for System Parameters implemented by GBS.
    /// </summary>
    public partial class GBSSystemParameter : gbs_systemparameter
    {
        /// <summary>
        /// Creates an instance of the system parameter based on the specified parameter name and populates the gbs_value attribute. This
        /// attribute will always be a string. If a different data type is needed, you need to cast the string value to the needed data type
        /// </summary>
        /// <param name="pService"></param>
        /// <param name="pParameterName"></param>
        public GBSSystemParameter(IOrganizationService pService, string pName)
        {
            QueryExpression query = new QueryExpression();
            query.EntityName = "gbs_systemparameter";
            query.ColumnSet = new ColumnSet("gbs_systemparameterid", "gbs_name", "gbs_value", "gbs_description");

            //condition based on Entity Name
            ConditionExpression condition = new ConditionExpression();
            condition.AttributeName = "gbs_name";
            condition.Operator = ConditionOperator.Equal;
            condition.Values.Add(pName);

            FilterExpression filter = new FilterExpression();
            filter.FilterOperator = LogicalOperator.And;
            filter.Conditions.Add(condition);

            query.Criteria.AddFilter(filter);

            var items = pService.RetrieveMultiple(query);
            if (items == null ||
                items.Entities == null ||
                items.Entities.Count == 0)
            {
                throw new InvalidPluginExecutionException("System Parameter with name '" + pName + "' does not exist in the system.");
            }
            else if (items.Entities.Count != 1)
            {
                throw new InvalidPluginExecutionException("More than one System Parameter with name '" + pName + "' exists in the system.");
            }

            Entity SystemParameter = items.Entities[0];
            if (SystemParameter.Attributes.Contains("gbs_value")){
                this.gbs_Value = SystemParameter.Attributes["gbs_value"].ToString();
            }
        }
    }

    /// <summary>
    /// Custom Business Logic for the NextId entity implemented by GBS.
    /// </summary>
    public partial class GBSNextId : gbs_nextid
    {
        /// <summary>
        /// This method will generate a unique integer id and populate the Integer Id column of the passed-in entity with it
        /// </summary>
        /// <param name="pEntity"></param>
        /// <param name="pService"></param>
        public static int GetNextIntegerId(Guid sequence, IOrganizationService pService)
        {
            int newNextId;                            //
            string newDummy = new Guid().ToString();  //Used for updating dummy element, essentially lock the needed row for the rest of transaction

            //lock the record that stores the auto numbering, based on guid *no DB activity - deadlock*
            //this entity should only have the dummy field for locking 
            gbs_nextid AutoIdEntity = new gbs_nextid();
            AutoIdEntity.Id = sequence;
            AutoIdEntity.gbs_Dummy = newDummy;

            //updating that specific row. This will lock that specific row
            pService.Update(AutoIdEntity);
    
            //DEBUG - wait 5 seconds to prove concurrency with transactions.
            //System.Threading.Thread.Sleep(5000);

            //Retrieve the current next ID stored in the AutoIDEntity
            gbs_nextid member = pService.Retrieve(AutoIdEntity.LogicalName, sequence, new ColumnSet(true)).ToEntity<gbs_nextid>();
            newNextId = (int)member.gbs_NextId;
            int rvId = newNextId;
            //increment by one
            ++newNextId;
            AutoIdEntity.Attributes.Add("gbs_nextid",newNextId);
            //update the system
            pService.Update(AutoIdEntity);

            return rvId;
        }
        ///// <summary>
        ///// This helper method is used to retrieve the next available Integer Id from the Organization Service
        ///// </summary>
        ///// <param name="service"></param>
        ///// <param name="entityName"></param>
        ///// <returns></returns>
        //private static gbs_nextid GetAutoIdEntity(IOrganizationService service, string entityName)
        //{
        //    QueryExpression query = new QueryExpression();
        //    query.EntityName = "gbs_nextid";
        //    query.ColumnSet = new ColumnSet(new[] { "gbs_entityname", "gbs_entityidfieldname", "gbs_dummy", "gbs_alternatenextidentityname", "gbs_alternatenextidentityfieldname", "gbs_usealternatenextid" });

        //    //condition based on Entity Name
        //    ConditionExpression condition = new ConditionExpression();
        //    condition.AttributeName = "gbs_entityname";
        //    condition.Operator = ConditionOperator.Equal;
        //    condition.Values.Add(entityName);

        //    //condition based on Alternate Entity Name
        //    ConditionExpression altcondition = new ConditionExpression();
        //    altcondition.AttributeName = "gbs_alternatenextidentityname";
        //    altcondition.Operator = ConditionOperator.Equal;
        //    altcondition.Values.Add(entityName);

        //    query.Criteria.FilterOperator = LogicalOperator.Or;
        //    query.Criteria.AddCondition(condition);
        //    query.Criteria.AddCondition(altcondition);
                    
        //    var items = service.RetrieveMultiple(query);
        //    if (items == null ||
        //        items.Entities == null ||
        //        items.Entities.Count == 0)
        //    {
        //        throw new InvalidPluginExecutionException("No entry was found in Auto Generated Ids entity for the entity: " + entityName);
        //    }
        //    else if (items.Entities.Count != 1)
        //    {
        //        throw new InvalidPluginExecutionException("More than one entry were found in Auto Generated Ids entity for the entity: " + entityName);
        //    }

        //    //need more intelligent query to detect if not found, a mechanism to insert a new instance of sequencing entry 
        //    gbs_nextid NextId = items.Entities[0].ToEntity<gbs_nextid>();
                       
        //    return NextId;
        //}

        /// <summary>
        /// This method will generate a unique integer id by calling a stored procedure and populate the 
        /// Integer Id column of the passed-in entity with it.
        /// Assumptions:
        ///     1. The gbs_NextId entity contains a configuration record for the Entity that is saved.
        ///     2. The CustomDBConnection system parameter is populated with a connection string to a database
        ///     that contains the gbssp_get_nextid stored procedure
        /// </summary>
        /// <param name="pEntity">The instance of the Entity that is created</param>
        /// <param name="pService">An instance of the Organization Service</param>
        public static void GetNextIntegerIdFromDB(ref Entity pEntity, IOrganizationService pService) {
            SqlConnection conn = null;
            try
            {
                conn = new SqlConnection();
                //Get the Connection String from the "CustomDBConnection" System Parameter. 
                GBSSystemParameter sysparam = new GBSSystemParameter(pService, "CustomDBConnection");
                conn.ConnectionString = sysparam.gbs_Value;
                conn.Open();

                SqlCommand cmd = conn.CreateCommand();

                string sNextId;
                string sEntityFieldName;

                cmd = new SqlCommand("gbssp_get_nextid");
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add(new SqlParameter("@entitySchemaName", pEntity.LogicalName));

                using (SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            sNextId = reader["nextId"].ToString().Trim();
                            sEntityFieldName = reader["gbs_EntityIdFieldName"].ToString().Trim();
                            //Add the Next Id attribute to the Attributes of the Entity and set it to the generated Next Id
                            pEntity.Attributes.Add(sEntityFieldName, sNextId);
                        }
                    }
                    else
                    {
                        throw new Exception("gbssp_get_nextid failed to retrieve the Next Id from the gbs_NextId entity.");
                    }
                }                
            }
            catch (Exception ex)
            {
                throw new Exception("Error setting Next Id. Error Details: " + ex.Message, ex);
            }
            finally
            {
                if (conn != null)
                {
                    conn.Close();
                }
            }
        }        
    }
}
