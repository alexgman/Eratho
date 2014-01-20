using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Verathon.Crm.Entities;
using Microsoft.Xrm.Sdk;
using Microsoft.Xrm.Sdk.Query;
using Microsoft.Xrm.Sdk.Client;
using Microsoft.Xrm.Sdk.Metadata;
using Microsoft.Xrm.Sdk.Discovery;
using Microsoft.Xrm.Sdk.Messages;
using Microsoft.Crm.Sdk.Messages;
using System.Web.Services.Protocols;
using System.Xml;


namespace Verathon.Crm.Helper
{
    public class Helper 
    {
              
        /// <summary>
        /// This method retrieves the label of a Status value.
        /// </summary>
        /// <param name="entityName"></param>
        /// <param name="picklistName"></param>
        /// <param name="selectedValue"></param>
        /// <param name="service"></param>
        /// <returns></returns>
        public static string GetPickListValueOption(IOrganizationService service, string entityname, string attributename, OptionSetValue SelectedValue)
        {
            string strPickListText = "";

            // Create the request
            RetrieveAttributeRequest attributeRequest = new RetrieveAttributeRequest
            {
                EntityLogicalName = entityname,
                LogicalName = attributename,
                RetrieveAsIfPublished = true
            };

            // Execute the request
            RetrieveAttributeResponse attributeResponse = (RetrieveAttributeResponse)service.Execute(attributeRequest);
            //If a status type optionset change "StateAttributeMetadata" to StatusAttributeMetadata, if a state type optionset change "StateAttributeMetadata" toStateAttributeMetadata, if a picklist type optionset change "StateAttributeMetadata" toPicklistAttributeMetadata
            PicklistAttributeMetadata retrievedPicklistAttributeMetadata = (PicklistAttributeMetadata)attributeResponse.AttributeMetadata;
            OptionMetadata[] optionList = retrievedPicklistAttributeMetadata.OptionSet.Options.ToArray();

            foreach (OptionMetadata oMD in optionList)
            {
                if (oMD.Value == SelectedValue.Value)
                {
                    strPickListText = oMD.Value.ToString();
                    break;
                }
            }
            return strPickListText;
        }

        public static string GetPickListTextOption(IOrganizationService service, string entityname, string attributename, OptionSetValue SelectedValue)
        {
            string strPickListText = "";

            // Create the request
            RetrieveAttributeRequest attributeRequest = new RetrieveAttributeRequest
            {
                EntityLogicalName = entityname,
                LogicalName = attributename,
                RetrieveAsIfPublished = true
            };

            // Execute the request
            RetrieveAttributeResponse attributeResponse = (RetrieveAttributeResponse)service.Execute(attributeRequest);
            //If a status type optionset change "StateAttributeMetadata" to StatusAttributeMetadata, if a state type optionset change "StateAttributeMetadata" toStateAttributeMetadata, if a picklist type optionset change "StateAttributeMetadata" toPicklistAttributeMetadata
            PicklistAttributeMetadata retrievedPicklistAttributeMetadata = (PicklistAttributeMetadata)attributeResponse.AttributeMetadata;
            OptionMetadata[] optionList = retrievedPicklistAttributeMetadata.OptionSet.Options.ToArray();

            foreach (OptionMetadata oMD in optionList)
            {
                if (oMD.Value == SelectedValue.Value)
                {
                    strPickListText = oMD.Label.UserLocalizedLabel.Label;
                    break;
                }
            }
            return strPickListText;
        }

        public string getStatusLabel(string entityName, string picklistName, int selectedValue, IOrganizationService service)
            {
                string selectedOptionLabel;
                selectedOptionLabel = string.Empty;

                RetrieveAttributeRequest retrieveAttributeRequest =
                            new RetrieveAttributeRequest
                            {
                                EntityLogicalName = entityName,
                                LogicalName = picklistName,
                                RetrieveAsIfPublished = true
                            };

                // Execute the request.
                RetrieveAttributeResponse retrieveAttributeResponse =
                    (RetrieveAttributeResponse)service.Execute(
                    retrieveAttributeRequest);

                // Access the retrieved attribute.
                StatusAttributeMetadata retrievedPicklistAttributeMetadata =
                    (StatusAttributeMetadata)
                    retrieveAttributeResponse.AttributeMetadata;

                foreach (StatusOptionMetadata option in retrievedPicklistAttributeMetadata.OptionSet.Options)
                {
                    if (option.Value == selectedValue)
                    {
                        selectedOptionLabel = option.Label.UserLocalizedLabel.Label;
                        break;

                    }
                }
                return selectedOptionLabel;
            
        }

        /// <summary>
        /// This method retrieves the label of a Picklist value
        /// </summary>
        /// <param name="entityName"></param>
        /// <param name="picklistName"></param>
        /// <param name="selectedValue"></param>
        /// <param name="service"></param>
        /// <returns></returns>
        public string getPicklistLabel(string entityName, string picklistName, int selectedValue, IOrganizationService service)
        {
            string selectedOptionLabel;
            selectedOptionLabel = string.Empty;

            RetrieveAttributeRequest retrieveAttributeRequest =
                        new RetrieveAttributeRequest
                        {
                            EntityLogicalName = entityName,
                            LogicalName = picklistName,
                            RetrieveAsIfPublished = true
                        };

            // Execute the request.
            RetrieveAttributeResponse retrieveAttributeResponse =
                (RetrieveAttributeResponse)service.Execute(
                retrieveAttributeRequest);

            // Access the retrieved attribute.
            PicklistAttributeMetadata retrievedPicklistAttributeMetadata =
                (PicklistAttributeMetadata)
                retrieveAttributeResponse.AttributeMetadata;

            // Get the current options list for the retrieved attribute.
            OptionMetadata[] optionList =
                retrievedPicklistAttributeMetadata.OptionSet.Options.ToArray();

            foreach (OptionMetadata option in optionList)
            {
                if (option.Value == selectedValue)
                {
                    selectedOptionLabel = option.Label.UserLocalizedLabel.Label;
                    break;

                }
            }
            return selectedOptionLabel;
        }

        /// <summary>
        /// This method retrieves primary attribute value of a Lookup
        /// </summary>
        /// <param name="pLookup"></param>
        /// <param name="service"></param>
        /// <returns></returns>
        public string getLookupPrimaryAttribute(EntityReference pLookup, IOrganizationService service)
        {
            Entity Lookup = new Entity();
            RetrieveEntityRequest request = new RetrieveEntityRequest()
            {
                EntityFilters = EntityFilters.Entity,
                LogicalName = pLookup.LogicalName
            };

            // Retrieve the MetaData and find the primary attribute
            RetrieveEntityResponse response = (RetrieveEntityResponse)service.Execute(request);
            string primaryAttribute = response.EntityMetadata.PrimaryNameAttribute.ToString();
            ColumnSet primaryAttributeCS = new ColumnSet(primaryAttribute);

            Lookup = service.Retrieve(pLookup.LogicalName, pLookup.Id, primaryAttributeCS);
            return Lookup.GetAttributeValue<string>(primaryAttribute);
        }
        /// <summary>
        /// This method shares a record with a user
        /// </summary>
        /// <param name="service">An instance of the organization service</param>
        ///  <param name="PrincipalType">User or Team, i.e. SystemUser.EntityLogicalName or Team.EntityLogicalName<param>
        /// <param name="SharedPrincipalId">GUID of the user/team to whom access is being granted</param>
        /// <param name="SharedEntityId">Guid of record to share</param>
        /// <param name="SharedEntityName">The schema name of the entity, e.g. incident.EntityLogicalName</param>                        
        /// <param name="ReadOnly">Assign User Read Only share rights?</param>
        public void ShareRecord(IOrganizationService service, string PrincipalType, Guid SharedPrincipalId, Guid SharedEntityId, string SharedEntityName, bool ReadOnly)
        {
            try
            {
                EntityReference principal = new EntityReference(PrincipalType, SharedPrincipalId);
                // Create the PrincipalAccess object.
                PrincipalAccess principalAccess = new PrincipalAccess();
                // Set the properties of the PrincipalAccess object.
                principalAccess.Principal = principal;

                EntityReference target = new EntityReference(SharedEntityName, SharedEntityId);

                // Create the request object.
                GrantAccessRequest grant = new GrantAccessRequest();

                // Set the properties of the request object.
                grant.Target = target;

                //If not read only, give user full access except for Delete
                if (!ReadOnly)
                {
                    foreach (AccessRights right in Enum.GetValues(typeof(AccessRights)))
                    {
                        // Give the principal access to full access except DELETE
                        principalAccess.AccessMask = right;
                        grant.PrincipalAccess = principalAccess;
                        // Execute the request.
                        service.Execute(grant);
                    }
                }
                else
                {
                    // Give the principal access to read only
                    principalAccess.AccessMask = AccessRights.ReadAccess;
                    grant.PrincipalAccess = principalAccess;
                    // Execute the request.
                    GrantAccessResponse granted = (GrantAccessResponse)service.Execute(grant);
                }
            }
            catch (SoapException soapEx)
            {
                throw new SoapException("Unable to share " + SharedEntityName + "with Id" + SharedEntityId + "  with user" + SharedPrincipalId.ToString(), soapEx.Code, soapEx);
            }
            catch (Exception ex)
            {
                throw new Exception("Unable to share " + SharedEntityName + "with Id" + SharedEntityId + "  with user " + SharedPrincipalId.ToString(), ex);
            }
        }

        /// <summary>
        /// Revoke Sharing with a User/Team
        /// </summary>
        /// <param name="service"></param>
        ///  <param name="PrincipalType">User or Team, i.e. SystemUser.EntityLogicalName or Team.EntityLogicalName<param>
        /// <param name="RevokePrincipalId">GUID of the user/team to whom access is being revoked</param>        
        /// <param name="RevokeEntityName">The schema name of the entity, e.g. incident.EntityLogicalName</param>                
        /// <param name="RevokedEntityId">The Id of the entity to which access is being revoked</param>
        /// <param name="EntityOwnerId">The owner of the record</param>
        private void RevokeAccessToRecord(IOrganizationService service, string PrincipalType, Guid RevokePrincipalId, string RevokeEntityName, Guid RevokedEntityId, Guid EntityOwnerId)
        {
            try
            {
                //Do not try to revoke owner's access
                if (RevokePrincipalId != EntityOwnerId)
                {
                    EntityReference principal = new EntityReference(PrincipalType, RevokePrincipalId);
                    // Create the PrincipalAccess object.
                    PrincipalAccess principalAccess = new PrincipalAccess();
                    // Set the properties of the PrincipalAccess object.
                    principalAccess.Principal = principal;

                    EntityReference target = new EntityReference(RevokeEntityName, RevokedEntityId);

                    // Create the request object.
                    RevokeAccessRequest revoke = new RevokeAccessRequest();

                    // Set the properties of the request object.
                    revoke.Revokee = principal;
                    revoke.Target = target;

                    // Execute the request.
                    RevokeAccessResponse revoked = (RevokeAccessResponse)service.Execute(revoke);
                }
            }
            catch (SoapException soapEx)
            {
                throw new SoapException("Unable to revoke sharing right to " + RevokeEntityName + " with Id: " + RevokedEntityId + " from " + PrincipalType + " with Id: " + RevokedEntityId, soapEx.Code, soapEx);
            }
            catch (Exception ex)
            {
                throw new Exception("Unable to revoke sharing right to " + RevokeEntityName + " with Id: " + RevokedEntityId + " from " + PrincipalType + " with Id: " + RevokedEntityId, ex);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="target"></param>
        /// <param name="service"></param>
        /// <param name="preImageEntity"></param>
        /// <param name="unsecureConfig"></param>
        public static void GetOrderNumber(Entity target, IOrganizationService service, Entity preImageEntity, out string strOrderType, out string strDestination, out string strOrderNumber, out int intOrderTypeValue, out int intDestination)
        {
            strOrderNumber = string.Empty;
            strOrderType = string.Empty;
            strDestination = string.Empty;
            intOrderTypeValue = 0;
            intDestination = 0;

            if (target.Contains("vth_originalorderid") || target.Contains("vth_ordertype") || target.Contains("vth_destination"))
            {
                //If Order Type has changed or passed in then Get the Order type label description.
                if (target.Contains("vth_ordertype") || preImageEntity != null)
                {
                    //Get the OptionSet label
                    if (target.Contains("vth_ordertype"))
                        strOrderType = Verathon.Crm.Helper.Helper.GetPickListTextOption(service, "salesorder", "vth_ordertype", (OptionSetValue)target.Attributes["vth_ordertype"]);
                    else
                        strOrderType = Verathon.Crm.Helper.Helper.GetPickListTextOption(service, "salesorder", "vth_ordertype", (OptionSetValue)preImageEntity.Attributes["vth_ordertype"]);
                    
                    //Parse out the order type abbreviation
                    string[] arrOrderType = strOrderType.Split(' ', '-');
                    strOrderType = arrOrderType[0].ToString();

                    if (target.Contains("vth_ordertype"))
                        intOrderTypeValue = ((OptionSetValue)(target["vth_ordertype"])).Value;
                    else
                        intOrderTypeValue = ((OptionSetValue)(preImageEntity["vth_ordertype"])).Value;
                }


                if (target.Contains("vth_destination") || preImageEntity != null)
                {
                    if (target.Contains("vth_destination"))
                        strDestination = Verathon.Crm.Helper.Helper.GetPickListTextOption(service, "salesorder", "vth_destination", (OptionSetValue)target.Attributes["vth_destination"]);
                    else
                        strDestination = Verathon.Crm.Helper.Helper.GetPickListTextOption(service, "salesorder", "vth_destination", (OptionSetValue)preImageEntity.Attributes["vth_destination"]);

                    string[] arrDestination = strDestination.Split(' ', '-');
                    strDestination = arrDestination[0].ToString();

                    if (target.Contains("vth_destination"))
                        intDestination = ((OptionSetValue)(target["vth_destination"])).Value;
                    else
                        intDestination = ((OptionSetValue)(preImageEntity["vth_destination"])).Value;
                }
                
                if (target.Contains("vth_originalorderid") && target["vth_originalorderid"] != null)
                {                   
                    Guid guidOrderSearch = ((EntityReference)target["vth_originalorderid"]).Id;
                    ColumnSet originalOrderColumns = new ColumnSet(new string[] { "vth_ordernumber", "vth_ordertype", "vth_destination" });
                    SalesOrder originalOrder = (SalesOrder)service.Retrieve("salesorder", guidOrderSearch, originalOrderColumns);
                    strOrderNumber = originalOrder.vth_OrderNumber.ToString();
                }
            }
        }

        public static string GetMaxSuffix(Entity target, IOrganizationService service, Entity preImageEntity, string strOrderNumber, int intOrderTypeValue, int intDestination)
        {

            string strSuffix = "000";

            //if (target.Contains("vth_originalorderid") || preImageEntity.Contains("vth_originalorderid"))
            //{
                string fetchOrderSuffixes = "<fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='false'>";
                fetchOrderSuffixes += "<entity name='salesorder'>";
                fetchOrderSuffixes += "<attribute name='salesorderid' />";
                fetchOrderSuffixes += "<attribute name='vth_ordersuffix' />";
                fetchOrderSuffixes += "<attribute name='vth_ordertype' />";
                fetchOrderSuffixes += "<attribute name='vth_destination' />";
                fetchOrderSuffixes += "<order attribute='vth_ordersuffix' descending='true' />";
                fetchOrderSuffixes += "<filter type='and'>";
                fetchOrderSuffixes += "<filter type='and'>";
                fetchOrderSuffixes += "<condition attribute='vth_ordernumber' operator='eq' value='" + strOrderNumber + "' />";
                fetchOrderSuffixes += "<condition attribute='vth_ordertype' operator='eq' value='" + intOrderTypeValue + "' />";//strOrderTypeforQuery + "' />";
                fetchOrderSuffixes += "<condition attribute='vth_destination' operator='eq' value='" + intDestination + "' />";//strDestinationforQuery + "' />";
                fetchOrderSuffixes += "</filter>";
                fetchOrderSuffixes += "</filter>";
                fetchOrderSuffixes += "</entity>";
                fetchOrderSuffixes += "</fetch>";

                EntityCollection resultsOfSuffixSearch = service.RetrieveMultiple(new FetchExpression(fetchOrderSuffixes));

                int maxSuffix = 0;
                if (resultsOfSuffixSearch.Entities.Count > 0)
                {
                    SalesOrder orderWithMaxSuffix = (SalesOrder)resultsOfSuffixSearch[0];
                    maxSuffix = (int)orderWithMaxSuffix.vth_OrderSuffix + 1;
                }

                strSuffix = maxSuffix.ToString();
                if (strSuffix.Length < 3)
                {
                    if (strSuffix.Length == 1)
                        strSuffix = "00" + strSuffix;

                    if (strSuffix.Length == 2)
                        strSuffix = "0" + strSuffix;
                }
            //}

            return strSuffix;
        }
        public static string GetUserRegion(IOrganizationService service, XrmServiceContext crm, Guid guidCurrentUser)
        {
            string strUserRegion = "";
            IEnumerable<OptionSetValue> opRegion = from u in crm.SystemUserSet
                                                   where u.SystemUserId == guidCurrentUser
                                                   select u.vth_VisualBusinessEntity;
            /*foreach (OptionSetValue osv in opRegion)
            {
                GetPickListValueOption(service, "systemuser", osv, osv);
            }*/
            return strUserRegion;
        }
        public static string GetDescription(XrmServiceContext crm, Guid guidProdId)
        {
            string description = "";

            IEnumerable<Product> strDescription = from c in crm.ProductSet
                                                  where c.ProductId == guidProdId
                                                  select c;
            foreach (Product prod in strDescription)
            {
                if (prod.Contains("name"))
                {
                    string strName = prod["name"].ToString();
                    description = strName;
                }
            }
            return description;
        }
        public static decimal GetPricePerUnit(XrmServiceContext crm, Guid guidOppOrQuoteId, EntityReference erProdId, string entityType)
        {
            decimal price = 0;
            IEnumerable<EntityReference> erPriceLevel = null;

            if (entityType == "opportunityproduct")
            {
                erPriceLevel = from a in crm.OpportunitySet
                               where a.OpportunityId == guidOppOrQuoteId
                               select a.PriceLevelId;
            }
            else if (entityType == "quotedetail")
            {
                erPriceLevel = from a in crm.QuoteSet
                               where a.QuoteId == guidOppOrQuoteId
                               select a.PriceLevelId;
            }

                foreach (EntityReference pricelevel in erPriceLevel)
                {
                    EntityReference guidPriceLevel = (EntityReference)pricelevel;

                    IEnumerable<ProductPriceLevel> entProductPriceLevel = from c in crm.ProductPriceLevelSet
                                                                          where c.ProductId == erProdId
                                                                          where c.PriceLevelId == guidPriceLevel
                                                                          select c;

                    foreach (ProductPriceLevel ppl in entProductPriceLevel)
                    {
                        price = ppl.Amount.Value;
                    }
                }
            return price;
        }
        public static void ProcessProduct(IOrganizationService service, Entity postImageEntity, Entity target, XrmServiceContext crm, string entityType)
        {
            
            Entity prod = new Entity(entityType);
            string entityTypeId = entityType + "id";
            prod[entityTypeId] = (Guid)postImageEntity[entityTypeId];

            //Set description
            Guid guidProdId = ((EntityReference)postImageEntity["productid"]).Id;
            EntityReference erProdId = (EntityReference)postImageEntity["productid"];
            Guid guidOppOrQuoteId = new Guid();

            if (entityType == "opportunityproduct")
            {
                guidOppOrQuoteId = ((EntityReference)postImageEntity["opportunityid"]).Id;
            }
            else if (entityType == "quotedetail")
            {
                guidOppOrQuoteId = ((EntityReference)postImageEntity["quoteid"]).Id;
            }

            string description = GetDescription(crm, guidProdId);
            if (description != "")
            {
                if (entityType == "opportunityproduct")
                {
                    prod["description"] = description;
                }
                else if (entityType == "quotedetail")
                {
                    prod["vth_productdescription"] = description;
                }
            }

            //Get variable data
            decimal decDiscountPercent = 0;
            if (target.Contains("vth_discountpercent"))
            {
                decDiscountPercent = (decimal)target["vth_discountpercent"];
            }
            else if (postImageEntity.Contains("vth_discountpercent"))
            {
                decDiscountPercent = (decimal)postImageEntity["vth_discountpercent"];
            }
            decimal decDiscountAmount = 0;
            if (target.Contains("manualdiscountamount"))
            {
                Money monDiscountAmount = (Money)target["manualdiscountamount"];
                decDiscountAmount = monDiscountAmount.Value;
            }
            else if (postImageEntity.Contains("manualdiscountamount"))
            {
                Money monDiscountAmount = (Money)postImageEntity["manualdiscountamount"];
                decDiscountAmount = monDiscountAmount.Value;
            }
            decimal decQuantity = 0;
            if (target.Contains("quantity"))
            {
                decQuantity = (decimal)target["quantity"];
            }
            else
            {
                decQuantity = (decimal)postImageEntity["quantity"];
            }
            decimal decPricePerUnit = 0;
            if (target.Contains("ispriceoverridden"))
            {
                if ((bool)target["ispriceoverridden"] == true)
                {
                    if (target.Contains("priceperunit"))
                    {
                        Money monPricePerUnit = (Money)target["priceperunit"];
                        decPricePerUnit = monPricePerUnit.Value;
                    }
                    else if (postImageEntity.Contains("priceperunit"))
                    {
                        Money monPricePerUnit = (Money)postImageEntity["priceperunit"];
                        decPricePerUnit = monPricePerUnit.Value;
                    }
                }
                else
                {
                    decPricePerUnit = GetPricePerUnit(crm, guidOppOrQuoteId, erProdId, entityType);
                }
            }
            else
            {
                if ((bool)postImageEntity["ispriceoverridden"] == true)
                {
                    if (target.Contains("priceperunit"))
                    {
                        Money monPricePerUnit = (Money)target["priceperunit"];
                        decPricePerUnit = monPricePerUnit.Value;
                    }
                    else if (postImageEntity.Contains("priceperunit"))
                    {
                        Money monPricePerUnit = (Money)postImageEntity["priceperunit"];
                        decPricePerUnit = monPricePerUnit.Value;
                    }
                }
                else
                {
                    decPricePerUnit = GetPricePerUnit(crm, guidOppOrQuoteId, erProdId, entityType);
                }
            }

            decimal decDiscountPercentConverted = decDiscountPercent * .01M;
            decimal decAmount = 0;


                string strDiscountType = "";
                if (target.Contains("vth_discounttype"))
                {
                    strDiscountType = GetPickListValueOption(service, "opportunityproduct", "vth_discounttype", (OptionSetValue)target["vth_discounttype"]);
                }
                else
                {
                    strDiscountType = GetPickListValueOption(service, "opportunityproduct", "vth_discounttype", (OptionSetValue)postImageEntity["vth_discounttype"]);
                }


                switch (strDiscountType)
                {
                    case "958560000":
                        if (decDiscountAmount != 0)
                        {
                            decAmount = decDiscountAmount;
                            prod["vth_discountpercent"] = null;
                        }
                        break;

                    case "958560001":
                        if (decDiscountPercent != 0)
                        {
                            decAmount = ((decPricePerUnit * decQuantity) * decDiscountPercentConverted);
                        }
                        break;

                    default:
                        break;
                }


                prod["manualdiscountamount"] = new Money(decAmount);
                service.Update(prod);
        }

    }
}
