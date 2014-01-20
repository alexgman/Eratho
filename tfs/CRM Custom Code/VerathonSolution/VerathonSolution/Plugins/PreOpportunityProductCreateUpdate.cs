// <copyright file="PreOpportunityProductCreateUpdate.cs" company="Microsoft">
// Copyright (c) 2012 All Rights Reserved
// </copyright>
// <author>Microsoft</author>
// <date>10/30/2012 11:20:23 AM</date>
// <summary>Implements the PreOpportunityProductCreateUpdate Plugin.</summary>
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.1
// </auto-generated>
namespace VerathonSolution.Plugins
{
    using System;
    using System.ServiceModel;

    using Microsoft.Xrm.Sdk;

    using Verathon.Crm.Helper;

    /// <summary>
    /// PreOpportunityProductCreateUpdate Plugin.
    /// </summary>    
    public class PreOpportunityProductCreateUpdate: Plugin
    {
        //private IPluginExecutionContext m_context = null;

        /// <summary>
        /// Initializes a new instance of the <see cref="PreOpportunityProductCreateUpdate"/> class.
        /// </summary>
        public PreOpportunityProductCreateUpdate()
            : base(typeof(PreOpportunityProductCreateUpdate))
        {
            base.RegisteredEvents.Add(new Tuple<int, string, string, Action<LocalPluginContext>>(20, "Create", "opportunityproduct", new Action<LocalPluginContext>(ExecutePreOpportunityProductCreateUpdate)));
            //base.RegisteredEvents.Add(new Tuple<int, string, string, Action<LocalPluginContext>>(21, "Update", "opportunityproduct", new Action<LocalPluginContext>(ExecutePreOpportunityProductCreateUpdate)));

            // Note : you can register for more events here if this plugin is not specific to an individual entity and message combination.
            // You may also need to update your RegisterFile.crmregister plug-in registration file to reflect any change.
        }

        /// <summary>
        /// Executes the plug-in.
        /// </summary>
        /// <param name="localContext">The <see cref="LocalPluginContext"/> which contains the
        /// <see cref="IPluginExecutionContext"/>,
        /// <see cref="IOrganizationService"/>
        /// and <see cref="ITracingService"/>
        /// </param>
        /// <remarks>
        /// For improved performance, Microsoft Dynamics CRM caches plug-in instances.
        /// The plug-in's Execute method should be written to be stateless as the constructor
        /// is not called for every invocation of the plug-in. Also, multiple system threads
        /// could execute the plug-in at the same time. All per invocation state information
        /// is stored in the context. This means that you should not use global variables in plug-ins.
        /// </remarks>
        //IServiceProvider serviceProvider;
        protected void ExecutePreOpportunityProductCreateUpdate(LocalPluginContext localContext)
        {
            
            //m_context = (IPluginExecutionContext)serviceProvider.GetService(typeof(IPluginExecutionContext));
            //if (m_context.Depth > 2)
            //{
            //    return;
            //}
            if (localContext == null)
            {
                throw new ArgumentNullException("localContext");
            }

            try
            {
                //As of 10/29/12 this code handles three processes: 1.) Creates an original Opportunity ID, 2.) Sets the Close Probability field to a fixed number, and
                //3.) 
                IOrganizationService service = localContext.OrganizationService;
                Entity target = (Entity)localContext.PluginExecutionContext.InputParameters["Target"];
                
                //Get variable data
                decimal decDiscountPercent = 0;
                if (target.Contains("vth_discountpercent"))
                {
                    decDiscountPercent = (decimal)target["vth_discountpercent"];
                }
                else
                {
                    decDiscountPercent = (decimal)target["vth_discountpercent"];
                }
                decimal decDiscountAmount = 0;
                if (target.Contains("manualdiscountamount"))
                {
                    Money monDiscountAmount = (Money)target["manualdiscountamount"];
                    decDiscountAmount = monDiscountAmount.Value;
                }
                decimal decPricePerUnit = 0;
                if (target.Contains("priceperunit"))
                {
                    Money monPricePerUnit = (Money)target["priceperunit"];
                    decPricePerUnit = monPricePerUnit.Value;
                }
                decimal decQuantity = 0;
                if (target.Contains("quantity"))
                {
                    decQuantity = (decimal)target["quantity"];
                }
                decimal decDiscountPercentConverted = decDiscountPercent * .01M;
                decimal decAmount = 0;

                if (target.Contains("vth_discounttype"))
                {
                    string strDiscountType = Helper.GetPickListValueOption(service, "opportunityproduct", "vth_discounttype", (OptionSetValue)target["vth_discounttype"]);

                    switch (strDiscountType)
                    {
                        case "958560000":
                            if (decDiscountAmount != 0)
                            {
                                decAmount = decDiscountAmount;
                                target["vth_discountpercent"] = null;
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
                    target["manualdiscountamount"] = new Money(decAmount);
                }
            }
            catch
            {
            }
        }
    }
}
